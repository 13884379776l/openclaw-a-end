import { writeFileSync } from 'fs';

// Simple benchmark: measure context processing time by comparing
// response time with different system message lengths
// Key insight: context processing happens DURING model's thinking/parsing phase

const contextSizes = [0, 500, 1000, 2000, 4000, 6000, 8000, 10000, 15000, 20000];
const RUNS = 2;

console.log('=== Context Length Benchmark ===');
console.log('Model: qwen3.6:latest (23GB)');
console.log('GPU: RTX 3090 (24GB)');
console.log('Date: 2026-06-02 15:34\n');

let allResults = [];

// Test prompt (same for all runs - just "好的")
const testPrompt = '请简单回答这个问题。';

// System messages of varying lengths
function makeSystem(size) {
  if (size === 0) return '';
  let parts = [];
  for (let i = 0; i < size / 50; i++) {
    parts.push('这是一段测试文本，用于模拟长上下文场景。每段约50个汉字字符。第' + (i+1) + '条记录。');
  }
  return parts.join('\n');
}

for (const ctxSize of contextSizes) {
  console.log(`\nTesting context: ${ctxSize} tokens...`);
  
  const systemText = makeSystem(ctxSize);
  const results = [];
  
  for (let r = 0; r < RUNS; r++) {
    const start = Date.now();
    try {
      const res = await fetch('http://localhost:11434/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: 'qwen3.6:latest',
          messages: [
            { role: 'system', content: systemText },
            { role: 'user', content: testPrompt }
          ],
          stream: false,
          options: { num_ctx: Math.max(ctxSize + 500, 32768) }
        })
      });
      const data = await res.json();
      const elapsed = Date.now() - start;
      
      if (data.message && data.message.content) {
        const outTokens = Math.round(data.message.content.length / 4.5);
        results.push({ time: elapsed, tokens: outTokens });
        console.log(`  Run ${r+1}: ${elapsed}ms | ${outTokens} tokens`);
      } else {
        console.log(`  Run ${r+1}: Empty response`);
      }
    } catch (e) {
      console.log(`  Run ${r+1}: Error - ${e.message}`);
    }
    await new Promise(r => setTimeout(r, 1000));
  }
  
  if (results.length > 0) {
    const avgTime = Math.round(results.reduce((a, b) => a + b.time, 0) / results.length);
    const avgTokens = Math.round(results.reduce((a, b) => a + b.tokens, 0) / results.length);
    const tps = (avgTokens / (avgTime / 1000)).toFixed(2);
    allResults.push({ ctx: ctxSize, time: avgTime, tokens: avgTokens, tps });
    console.log(`  => Avg: ${avgTime}ms | ${avgTokens} tokens | TPS: ${tps}`);
  }
}

// Save results
let md = `## Context Length Benchmark Test
**Date:** 2026-06-02 15:34
**Model:** qwen3.6:latest (23GB)
**GPU:** RTX 3090 (24GB)
**Method:** chat API, ${RUNS} runs per size, averaged

| Context (tokens) | Avg Time (ms) | Output Tokens | TPS |
|--|--|--|--|`;

for (const r of allResults) {
  md += `\n|${r.ctx}|${r.time}|${r.tokens}|${r.tps}`;
}

writeFileSync('C:/Users/48856/.openclaw/workspace/memory/2026-06-02-context-bench.md', md, 'utf8');
console.log('\n\nResults saved to memory/2026-06-02-context-bench.md');
console.log('=== Benchmark Complete ===');
