#!/usr/bin/env node
// Matrix Bridge v1 - OpenClaw (A端)
// 通过 Synapse Client API 桥接 Matrix 到 OpenClaw

const http = require('http');
const fs = require('fs');
const path = require('path');

const CONFIG = {
    homeServer: 'http://192.168.31.18:8008',
    proxy: 'http://127.0.0.1:10809',
    roomId: '!WXyqvGnGVJGsgSODSR',
    user: 'commander',
    pass: 'Cmd@123456!'
};

const TOKEN_FILE = path.join(__dirname, 'token.json');
const LAST_FILE = path.join(__dirname, 'last-msg-ts.json');
const BRIDGE_DIR = path.join(__dirname);

function httpGet(urlPath, token) {
    return new Promise((resolve, reject) => {
        const parsed = new URL(CONFIG.homeServer + urlPath);
        const opts = {
            hostname: parsed.hostname,
            port: parsed.port || 80,
            path: parsed.pathname + parsed.search,
            method: 'GET',
            headers: token ? { 'Authorization': `Bearer ${token}` } : {}
        };
        
        const req = http.request(opts, (res) => {
            let data = '';
            res.on('data', c => data += c);
            res.on('end', () => resolve({ status: res.statusCode, body: data }));
        });
        req.on('error', reject);
        req.end();
    });
}

function httpPut(urlPath, token, bodyStr) {
    return new Promise((resolve, reject) => {
        const parsed = new URL(CONFIG.homeServer + urlPath);
        const body = Buffer.from(bodyStr);
        const opts = {
            hostname: parsed.hostname,
            port: parsed.port || 80,
            path: parsed.pathname + parsed.search,
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
                'Content-Length': body.length
            }
        };
        
        const req = http.request(opts, (res) => {
            let data = '';
            res.on('data', c => data += c);
            res.on('end', () => resolve({ status: res.statusCode, body: data }));
        });
        req.on('error', reject);
        req.write(body);
        req.end();
    });
}

function proxyFetch(urlPath, token, method, bodyStr) {
    // Use proxy via http proxy-agent approach
    // For simplicity, use curl via child_process
    return require('child_process').execFileSync(
        'curl.exe',
        ['-s', '-x', CONFIG.proxy, CONFIG.homeServer + urlPath,
         '-X', method, '-H', `Authorization: Bearer ${token}`]
            .concat(bodyStr ? ['-H', 'Content-Type: application/json', '-d', bodyStr] : []),
        { encoding: 'utf8' }
    );
}

function refreshToken() {
    const lb = JSON.stringify({
        type: 'm.login.password',
        identifier: { type: 'm.id.user', user: CONFIG.user },
        password: CONFIG.pass
    });
    const result = proxyFetch('/_matrix/client/v3/login', null, 'POST', lb);
    const obj = JSON.parse(result);
    if (obj.access_token) {
        fs.writeFileSync(TOKEN_FILE, JSON.stringify({ token: obj.access_token, ts: new Date().toISOString() }));
        return obj.access_token;
    }
    return null;
}

function loadToken() {
    try {
        const data = fs.readFileSync(TOKEN_FILE, 'utf8');
        const obj = JSON.parse(data);
        if (obj.token && obj.ts) {
            const ts = new Date(obj.ts);
            if (Date.now() - ts.getTime() < 86400000) { // 24h cache
                return obj.token;
            }
        }
    } catch (e) {}
    return refreshToken();
}

function loadLastTs() {
    try {
        const data = fs.readFileSync(LAST_FILE, 'utf8');
        return JSON.parse(data).ts;
    } catch (e) {
        return 0;
    }
}

async function main() {
    const args = process.argv.slice(2);
    const action = args[0] || 'poll';
    const message = args[1] || '';
    
    let token = loadToken();
    
    switch (action) {
        case 'poll': {
            const lastTs = loadLastTs();
            const path = `/_matrix/client/v3/rooms/${encodeURIComponent(CONFIG.roomId)}/messages?dir=b&limit=50&timeout=0`;
            const result = proxyFetch(path, token, 'GET', null);
            const obj = JSON.parse(result);
            
            const msgs = (obj.chunk || [])
                .filter(m => m.type === 'm.room.message')
                .sort((a, b) => a.origin_server_ts - b.origin_server_ts);
            
            const filtered = lastTs > 0
                ? msgs.filter(m => m.origin_server_ts > lastTs)
                : msgs;
            
            if (filtered.length === 0) {
                console.log('NO_MESSAGES');
            } else {
                for (const m of filtered) {
                    const body = m.content?.body || m.content?.['m.body'] || '[富文本]';
                    console.log(`MSG|${m.sender}|${body}|${m.origin_server_ts}`);
                }
                fs.writeFileSync(LAST_FILE, JSON.stringify({ ts: Date.now() }));
            }
            break;
        }
        case 'send': {
            const txnId = Math.floor(Math.random() * 4294967296).toString(16);
            const body = JSON.stringify({ msgtype: 'm.text', body: message });
            const path = `/_matrix/client/v3/rooms/${encodeURIComponent(CONFIG.roomId)}/send/m.room.message/${txnId}`;
            const result = proxyFetch(path, token, 'PUT', body);
            if (result.startsWith('{')) {
                console.log('OK');
            } else {
                console.log('ERR|' + result);
            }
            break;
        }
        case 'login': {
            const newToken = refreshToken();
            console.log('TOKEN|' + newToken);
            break;
        }
        case 'rooms': {
            const path = '/_matrix/client/v3/joined_rooms';
            const result = proxyFetch(path, token, 'GET', null);
            const rooms = JSON.parse(result).joined_rooms;
            for (const r of rooms) {
                try {
                    const n = proxyFetch(`/_matrix/client/v3/rooms/${encodeURIComponent(r)}/state/m.room.name`, token, 'GET', null);
                    console.log(`${r} | ${(JSON.parse(n)).name}`);
                } catch (e) {
                    console.log(`${r} | (unknown)`);
                }
            }
            break;
        }
        default:
            console.log('Actions: poll send login rooms');
    }
}

main().catch(e => {
    console.error(e.message);
    process.exit(1);
});
