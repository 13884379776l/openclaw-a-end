const http = require('http');

const data = JSON.stringify({
    jsonrpc: "2.0",
    id: 1,
    method: "message/send",
    params: {
        message: {
            messageId: "a2a-test-" + Date.now(),
            parts: [{
                type: "text",
                text: "B端副官，我是 A 端 win！这是 A→B 直接 HTTP JSON-RPC 测试消息！🛡️"
            }]
        }
    }
});

const options = {
    hostname: '192.168.31.18',
    port: 18800,
    path: '/a2a/jsonrpc',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
        'Authorization': 'Bearer 5ff5b9c0'
    },
    timeout: 10000
};

const req = http.request(options, (res) => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => {
        console.log('Status:', res.statusCode);
        console.log('Response:', body);
    });
});

req.on('error', (e) => console.log('ERROR:', e.message));
req.on('timeout', () => { req.destroy(); console.log('TIMEOUT'); });
req.write(data);
req.end();
