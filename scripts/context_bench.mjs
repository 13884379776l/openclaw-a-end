import { writeFileSync } from 'fs';

// Run 3 times per context size and average the results
const contextSizes = [100, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000];
const RUNS_PER_CTX = 3;
let allResults = [];

console.log('=== Context Length Benchmark ===');
console.log('Model: qwen3.6:latest (23GB)');
console.log('GPU: RTX 3090 (24GB)');
console.log('Date: 2026-06-02 15:34\n');

async function runTest(ctxSize) {
  // Use system prompt to inject context
  const systemPrompt = '你是一个中文助手。请分析以下文本：' + '测试数据 '.repeat(ctxSize / 4);
  const userPrompt = '\n\n请回答：好的';
  
  const res = await fetch('http://localhost:11434/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: 'qwen3.6:latest',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ],
      stream: false,
      options: { num_ctx: ctxSize + 200 }
    })
  });
  const data = await res.json();
  return data;
}

for (const ctxSize of contextSizes) {
  console.log(`Testing context: ${ctxSize} tokens (running ${RUNS_PER_CTX}x)...`);
  
  let totalTime = 0;
  let totalTokens = 0;
  let successCount = 0;
  
  for (let r = 0; r < RUNS_PER_CTX; r++) {
    try {
      const start = Date.now();
      const data = await runTest(ctxSize);
      const elapsedMs = Date.now() - start;
      
      if (data.message && data.message.content && data.message.content.length > 0) {
        const outputTokens = Math.round(data.message.content.length / 4.5);
        totalTime += elapsedMs;
        totalTokens += outputTokens;
        successCount++;
      } else {
        console.log(`  Run ${r+1}: Empty response (skipped)`);
      }
    } catch (e) {
      console.log(`  Run ${r+1}: Error - ${e.message}`);
    }
    
    // Wait 1s between runs
    await new Promise(r => setTimeout(r, 1000));
  }
  
  if (successCount > 0) {
    const avgTime = totalTime / successCount;
    const avgTokens = totalTokens / successCount;
    const tps = ((avgTokens / (avgTime / 1000))).toFixed(2);
    
    console.log(`  Avg: Time: ${(avgTime/1000).toFixed(2)}s | Tokens: ${avgTokens.toFixed(0)} | TPS: ${tps}`);
    
    allResults.push({
      ctx: ctxSize,
      time: avgTime,
      tokens: Math.round(avgTokens),
      tps
    });
  } else {
    console.log(`  Result: FAILED`);
    allResults.push({
      ctx: ctxSize,
      time: -1,
      tokens: 0,
      tps: 0
    });
  }
  
  // Wait 2s between context sizes
  await new Promise(r => setTimeout(r, 2000));
}

// Save results
let output = `## Context Length Benchmark Test
**Date:** 2026-06-02 15:34
**Model:** qwen3.6:latest (23GB)
**GPU:** RTX 3090 (24GB)
**Method:** chat API, ${RUNS_PER_CTX} runs per context size, averaged

| Context Length | Avg Time (ms) | Output Tokens | TPS |
|--------|-------|------|-|`;

for (const r of allResults) {
  if (r.time > 0) {
    output += `\n|${r.ctx}|${r.time.toFixed(0)}|${r.tokens}|${r.tps}`;
  } else {
    output += `\n|${r.ctx}|FAILED|0|0`;
  }
}

output += '\n\n## 结果\n';

if (allResults.some(r => r.time > 0)) {
  const valid = allResults.filter(r => r.time > 0);
  const maxTPS = Math.max(...valid.map(r => r.tps));
  const minTPS = Math.min(...valid.map(r => r.tps));
  const avgTPS = (valid.reduce((a, b) => a + b.tps, 0) / valid.length).toFixed(2);
  
  output += `- 最高 TPS: ${maxTPS}\n`;
  output += `- 最低 TPS: ${minTPS}\n`;
  output += `- 平均 TPS: ${avgTPS}\n`;
}

writeFileSync('C:/Users/48856/.openclaw/workspace/memory/2026-06-02-context-bench.md', output, 'utf8');
console.log('\nResults saved to memory/2026-06-02-context-bench.md');
console.log('=== Benchmark Complete ===');
