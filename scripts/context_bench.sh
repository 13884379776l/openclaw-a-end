#!/bin/bash
# Context Length Benchmark for qwen3.6:latest
# Hardware: RTX 3090 (24GB) + RTX 5070 Ti (16GB)
# Date: 2026-06-02 15:34

RESULTS_FILE="$HOME/.openclaw/workspace/memory/2026-06-02-context-bench.md"
MODEL="qwen3.6:latest"
PROMPTS=(
"请回答：好的"  # ~100 context
"请总结以下文本：$(python3 -c "print(' '.join(['测试数据' for _ in range(100)]))") 请回答：好的"  # ~500 context
"请总结以下文本：$(python3 -c "print(' '.join(['测试数据' for _ in range(200)]))") 请回答：好的"  # ~1000 context
"请总结以下文本：$(python3 -c "print(' '.join(['测试数据' for _ in range(400)]))") 请回答：好的"  # ~2000 context
"请总结以下文本：$(python3 -c "print(' '.join(['测试数据' for _ in range(600)]))") 请回答：好的"  # ~3000 context
"请总结以下文本：$(python3 -c "print(' '.join(['测试数据' for _ in range(800)]))") 请回答：好的"  # ~4000 context
)

echo "=== Context Length Benchmark ==="
echo "Model: $MODEL"
echo "Date: 2026-06-02 15:34"
echo ""

for i in "${!PROMPTS[@]}"; do
    ctx=$(( (i+1) * 100 ))
    echo "Testing: ${ctx} tokens context..."
    
    start_time=$(date +%s%N)
    output=$(curl -s http://localhost:11434/api/generate -d "{\"model\":\"$MODEL\",\"prompt\":\"${PROMPTS[$i]}\",\"stream\":false,\"options\":{\"num_ctx\":${ctx}}}" 2>/dev/null)
    end_time=$(date +%s%N)
    
    # Calculate timing
    elapsed_ms=$(( (end_time - start_time) / 1000000 ))
    elapsed_s=$(echo "scale=2; $elapsed_ms / 1000" | bc)
    
    # Count tokens
    output_text=$(echo "$output" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response',''))" 2>/dev/null)
    token_count=$(echo "$output_text" | python3 -c "import sys; print(len(sys.stdin.read()))" 2>/dev/null)
    
    if [ -n "$token_count" ] && [ "$token_count" != "0" ]; then
        tps=$(echo "scale=2; $token_count / $elapsed_s" | bc)
        echo "  Context: ${ctx} | Time: ${elapsed_s}s | Output: ${token_count} | TPS: ${tps}"
    else
        echo "  Context: ${ctx} | Time: ${elapsed_s}s | Output: N/A | TPS: N/A"
    fi
done

echo ""
echo "=== Test Complete ==="
