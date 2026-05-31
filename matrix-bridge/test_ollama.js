// 直接测试 Ollama，输出原始返回
const http = require('http');
const data = JSON.stringify({
    model: 'qwen3:1.7b',
    messages: [{ role: 'user', content: '你好，请说一句话' }],
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
        const obj = JSON.parse(body);
        console.log('=== RAW RESPONSE ===');
        console.log(JSON.stringify(obj, null, 2));
        console.log('=== FIELD CHECK ===');
        console.log('has message:', !!obj.message);
        console.log('has content:', !!obj.message?.content);
        console.log('has thinking:', !!obj.message?.thinking);
        console.log('content value:', obj.message?.content);
        console.log('thinking value:', obj.message?.thinking);
        const reply = obj.message?.content || obj.message?.thinking || null;
        console.log('reply:', reply);
    });
});
req.on('error', e => console.error('ERROR:', e.message));
req.on('timeout', () => { console.log('TIMEOUT'); req.destroy(); });
req.setTimeout(30000);
req.write(data);
req.end();
