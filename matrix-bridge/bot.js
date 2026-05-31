#!/usr/bin/env node
// Matrix Bot v7 - 小脑袋（含语音功能）
const cp = require('child_process');
const fs = require('fs');
const path = require('path');
const http = require('http');

const CFG = {
    homeserver: 'http://192.168.31.18:8008',
    proxy: 'http://127.0.0.1:10809',
    roomId: '!mPDLgwreaBeBbOsABm:b-matrix-server',
    botUser: '@commander:b-matrix-server',
    model: 'qwen3:1.7b',
    ttsEnabled: true,
    sttEnabled: true
};

const DIR = path.join(__dirname);
const TOKEN_FILE = path.join(DIR, 'token.json');
const LAST_FILE = path.join(DIR, 'last-msg-ts.json');
const SEEN_FILE = path.join(DIR, 'seen-events.json');
const LOG_FILE = path.join(DIR, 'bot.log');
const PID_FILE = path.join(DIR, 'bot.pid');

function log(msg) {
    const line = '[' + new Date().toISOString() + '] ' + msg + '\n';
    fs.appendFileSync(LOG_FILE, line);
    process.stdout.write(line);
}

function loadJSON(file, fb) { try { return JSON.parse(fs.readFileSync(file, 'utf8')); } catch { return fb; } }
function saveJSON(file, data) { fs.writeFileSync(file, JSON.stringify(data)); }

function getToken() {
    const cached = loadJSON(TOKEN_FILE, null);
    if (cached && cached.token) {
        if (cached.ts && (Date.now() - new Date(cached.ts).getTime() < 86400000)) return cached.token;
    }
    const lb = JSON.stringify({
        type: 'm.login.password',
        identifier: { type: 'm.id.user', user: 'commander' },
        password: 'Cmd@123456!'
    });
    const r = cp.execFileSync('curl.exe', ['-s','-x',CFG.proxy,CFG.homeserver+'/login','-X','POST','-H','Content-Type: application/json','-d',lb], { encoding: 'utf8' });
    const obj = JSON.parse(r);
    saveJSON(TOKEN_FILE, { token: obj.access_token, ts: new Date().toISOString() });
    return obj.access_token;
}

function curl(method, urlPath, bodyStr) {
    const token = getToken();
    const args = ['-s','-x',CFG.proxy,CFG.homeserver + urlPath, '-X', method, '-H', 'Authorization: Bearer ' + token];
    if (bodyStr) { args.push('-H','Content-Type: application/json','-d',bodyStr); }
    return cp.execFileSync('curl.exe', args, { encoding: 'utf8' });
}

// === TTS（语音输出）===
function speak(text) {
    if (!CFG.ttsEnabled) return;
    try {
        const safeText = text.replace(/'/g, "''").substring(0, 400);
        cp.execFileSync('powershell.exe', [
            '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-Command',
            "[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
            + "$voice=New-Object -ComObject SAPI.SpVoice;"
            + "$voice.SSpeak(\"" + safeText.replace(/"/g, '\"') + "\", 1);"
            + "[Console]::OutputEncoding=[System.Text.Encoding]::WindowsANSI;"
        ], { timeout: 10000, stdio: 'ignore' });
        log('TTS: ' + text.substring(0, 40));
    } catch (e) {
        log('TTS 失败: ' + e.message);
    }
}

// === STT（语音输入）===
function sttConvert(audioBase64) {
    return new Promise((resolve) => {
        const tmpFile = path.join(DIR, 'stt_input.wav');
        const buf = Buffer.from(audioBase64, 'base64');
        fs.writeFileSync(tmpFile, buf);
        log('STT 收到语音，正在识别...');
        cp.execFile('ollama', ['run', 'whisper', tmpFile], { timeout: 60000 }, (err, stdout) => {
            fs.unlinkSync(tmpFile);
            if (err) { log('STT 失败: ' + err.message); resolve(null); return; }
            const text = stdout.toString().trim();
            log('STT 结果: ' + text.substring(0, 80));
            resolve(text);
        });
    });
}

// === Ollama ===
function ollamaRequest(prompt) {
    return new Promise((resolve) => {
        const data = JSON.stringify({
            model: CFG.model,
            messages: [{ role: 'user', content: prompt }],
            stream: false,
            options: { temperature: 0.7, num_predict: 512, num_ctx: 4096 }
        });
        const req = http.request({
            hostname: '127.0.0.1', port: 11434, path: '/api/chat',
            method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) }
        }, (res) => {
            let body = '';
            res.on('data', c => body += c);
            res.on('end', () => {
                try {
                    const obj = JSON.parse(body);
                    const reply = obj.message?.content || obj.message?.thinking || null;
                    resolve(reply ? reply.replace(/[\u2580-\u259F\u2592-\u2593]/g, '').trim().substring(0, 500) : null);
                } catch { resolve(null); }
            });
        });
        req.on('error', () => resolve(null));
        req.on('timeout', () => { req.destroy(); resolve(null); });
        req.setTimeout(30000);
        req.write(data);
        req.end();
    });
}

async function ollamaGenerate(prompt) {
    for (let i = 0; i < 3; i++) {
        const reply = await ollamaRequest(prompt);
        if (reply) return reply;
        log('Ollama 返回空，重试 ' + (i + 1) + '/3...');
        await new Promise(r => setTimeout(r, 3000));
    }
    return null;
}

function getNewMessages() {
    const seen = loadJSON(SEEN_FILE, []);
    const lastTs = loadJSON(LAST_FILE, { ts: 0 }).ts || 0;
    const url = '/_matrix/client/v3/rooms/' + encodeURIComponent(CFG.roomId) + '/messages?dir=b&limit=10&timeout=0';
    const resp = curl('GET', url);
    const obj = JSON.parse(resp);
    const msgs = (obj.chunk || [])
        .filter(m => m.type === 'm.room.message' && m.sender !== CFG.botUser)
        .sort((a,b) => a.origin_server_ts - b.origin_server_ts);
    const reallyNew = msgs.filter(m => !seen.includes(m.event_id));
    return { messages: reallyNew, lastTs: msgs.length ? msgs[msgs.length-1].origin_server_ts : lastTs, eventIds: msgs.map(m => m.event_id) };
}

function sendReply(text) {
    const txnId = Math.floor(Math.random()*4294967296).toString(16);
    const url = '/_matrix/client/v3/rooms/' + encodeURIComponent(CFG.roomId) + '/send/m.room.message/' + txnId;
    const body = JSON.stringify({ msgtype: 'm.text', body: text });
    const r = curl('PUT', url, body);
    try { return JSON.parse(r).event_id ? 'OK' : 'ERR:' + r.substring(0,50); }
    catch { return 'ERR:' + r.substring(0,50); }
}

async function processMessage(msg) {
    const body = msg.content?.body || msg.content?.['m.body'] || '';
    const sender = msg.sender;
    const msgType = msg.content?.msgtype || '';
    
    if (!body.trim() && msgType !== 'm.voice' && msgType !== 'm.audio' && msgType !== 'm.file') {
        return;
    }

    log('[' + sender + '] type=' + msgType + ' body=' + body.substring(0, 80));
    
    let userInput = body;
    
    if ((msgType === 'm.voice' || msgType === 'm.audio') && CFG.sttEnabled) {
        const audioContent = msg.content?.file?.url;
        if (audioContent && audioContent.startsWith('mxc://')) {
            const mediaUrl = audioContent.replace('mxc://', CFG.homeserver + '/_matrix/media/r0/download/');
            const token = getToken();
            try {
                const mediaData = cp.execFileSync('curl.exe', ['-s','-x',CFG.proxy,mediaUrl,'-H','Authorization: Bearer ' + token], { encoding: 'utf8' });
                if (mediaData) {
                    const base64 = Buffer.from(mediaData).toString('base64');
                    const transcribed = await sttConvert(base64);
                    if (transcribed) {
                        userInput = transcribed;
                    }
                }
            } catch (e) {
                log('下载语音失败: ' + e.message);
            }
        }
    }
    
    const prompt = userInput.includes('请用简洁') ? userInput : '请用简洁自然的中文回复用户，像聊天室的朋友：' + userInput;
    const replyText = await ollamaGenerate(prompt);
    
    if (!replyText) {
        await sendReply('小脑袋打瞌睡去了 😴');
        log('  → 打瞌睡 (全部重试失败)');
    } else {
        const sent = await sendReply(replyText);
        log('  → ' + replyText.substring(0, 60) + ' (' + sent + ')');
        speak(replyText);
    }
    await new Promise(r => setTimeout(r, 3000));
}

async function processMessages() {
    const result = getNewMessages();
    if (result.messages.length === 0) return;
    log('Found ' + result.messages.length + ' new messages');
    for (const msg of result.messages) {
        await processMessage(msg);
    }
    saveJSON(LAST_FILE, { ts: result.lastTs });
    const seen = loadJSON(SEEN_FILE, []);
    saveJSON(SEEN_FILE, [...new Set([...seen, ...result.eventIds])]);
    log('Done: processed ' + result.messages.length + ' messages');
}

fs.writeFileSync(PID_FILE, process.pid.toString());
log('Bot v7 started (PID: ' + process.pid + ')');
log('TTS: ' + (CFG.ttsEnabled ? 'ON' : 'OFF') + ' | STT: ' + (CFG.sttEnabled ? 'ON' : 'OFF'));

setInterval(async () => {
    try { await processMessages(); } catch (e) { log('Error: ' + e.message); }
}, 60000);

process.on('SIGTERM', () => { fs.unlinkSync(PID_FILE); process.exit(0); });
process.on('SIGINT', () => { fs.unlinkSync(PID_FILE); process.exit(0); });
