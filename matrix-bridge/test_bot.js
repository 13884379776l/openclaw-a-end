// 完整测试 bot 的 ollamaGenerate 功能
const http = require('http');

const CFG = {
    homeserver: 'http://192.168.31.18:8008',
    proxy: 'http://127.0.0.1:10809',
    roomId: '!mPDLgwreaBeBbOsABm:b-matrix-server',
    botUser: '@commander:b-matrix-server',
    model: 'qwen3:1.7b'
};

const fs = require('fs');
const path = require('path');
const DIR = path.join(__dirname);
const TOKEN_FILE = path.join(DIR, 'token.json');
const LAST_FILE = path.join(DIR, 'last-msg-ts.json');
const SEEN_FILE = path.join(DIR, 'seen-events.json');
const LOG_FILE = path.join(DIR, 'test.log');

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
    const r = require('child_process').execFileSync('curl.exe', ['-s','-x',CFG.proxy,CFG.homeserver+'/login','-X','POST','-H','Content-Type: application/json','-d',lb], { encoding: 'utf8' });
    const obj = JSON.parse(r);
    saveJSON(TOKEN_FILE, { token: obj.access_token, ts: new Date().toISOString() });
    return obj.access_token;
}

function curl(method, urlPath, bodyStr) {
    const token = getToken();
    const args = ['-s','-x',CFG.proxy,CFG.homeserver + urlPath, '-X', method, '-H', 'Authorization: Bearer ' + token];
    if (bodyStr) { args.push('-H','Content-Type: application/json','-d',bodyStr); }
    return require('child_process').execFileSync('curl.exe', args, { encoding: 'utf8' });
}

function ollamaGenerate(prompt) {
    return new Promise((resolve) => {
        const data = JSON.stringify({
            model: CFG.model,
            messages: [{ role: 'user', content: prompt }],
            stream: false,
            options: { temperature: 0.7, num_predict: 512, num_ctx: 4096 }
        });
        
        log('=== OLLAMA TEST ===');
        log('prompt: ' + prompt);
        log('data length (chars): ' + data.length);
        log('data length (bytes): ' + Buffer.byteLength(data));
        log('request payload: ' + data);
        
        const req = http.request({
            hostname: '127.0.0.1', port: 11434, path: '/api/chat',
            method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) }
        }, (res) => {
            let body = '';
            res.on('data', c => body += c);
            res.on('end', () => {
                log('response: ' + body);
                try {
                    const obj = JSON.parse(body);
                    const reply = obj.message?.content || obj.message?.thinking || null;
                    log('has message: ' + !!obj.message);
                    log('has content: ' + !!obj.message?.content);
                    log('has thinking: ' + !!obj.message?.thinking);
                    log('content value: ' + obj.message?.content);
                    log('thinking value: ' + obj.message?.thinking);
                    log('Final reply: ' + reply);
                    resolve(reply ? reply.replace(/[\u2580-\u259F\u2592-\u2593]/g, '').trim().substring(0, 500) : null);
                } catch (e) {
                    log('Parse error: ' + e.message);
                    resolve(null);
                }
            });
        });
        req.on('error', (e) => { log('Req error: ' + e.message); resolve(null); });
        req.on('timeout', () => { log('Timeout'); resolve(null); });
        req.setTimeout(30000);
        req.write(data);
        req.end();
    });
}

async function main() {
    const seen = loadJSON(SEEN_FILE, []);
    const lastTs = loadJSON(LAST_FILE, { ts: 0 }).ts || 0;
    
    // 获取新消息
    const url = '/_matrix/client/v3/rooms/' + encodeURIComponent(CFG.roomId) + '/messages?dir=b&limit=10&timeout=0';
    const resp = curl('GET', url);
    const obj = JSON.parse(resp);
    const msgs = (obj.chunk || [])
        .filter(m => m.type === 'm.room.message' && m.sender !== CFG.botUser)
        .sort((a,b) => a.origin_server_ts - b.origin_server_ts);
    const reallyNew = msgs.filter(m => !seen.includes(m.event_id));
    
    log('Found ' + reallyNew.length + ' new messages (total ' + msgs.length + ')');
    
    for (const msg of reallyNew) {
        const body = msg.content?.body || msg.content?.['m.body'] || '[富文本]';
        const sender = msg.sender;
        
        log('[' + sender + '] ' + body);
        const reply = await ollamaGenerate('请用简洁自然的中文回复用户，像聊天室的朋友：' + body);
        
        if (reply) {
            log('SUCCESS: ' + reply);
        } else {
            log('FAILURE: 小脑袋打瞌睡去了 😴');
        }
    }
    
    log('=== TEST COMPLETE ===');
}

main().catch(e => { log('Fatal: ' + e.message); });
