#!/bin/bash
# Ollama inference speed test - write and run on B-end

echo "=== Ollama Inference Speed Test ==="
echo "Date: $(date)"
echo "Model: qwen3.6:latest"
echo ""

# Check model info
echo "--- Model Info ---"
curl -s http://127.0.0.1:11434/api/tags | python3 -c "
import sys, json
data = json.load(sys.stdin)
for model in data.get('models', []):
    print(f\"Name: {model['name']}\")
    print(f\"Size: {model.get('size', 'N/A')}\")
" 2>/dev/null

# Test 1: Short response (64 tokens)
echo ""
echo "--- Test 1: Short response (64 tokens) ---"
START=$(date +%s%N)
RESP=$(curl -s http://127.0.0.1:11434/api/chat -H 'Content-Type: application/json' -d '{
  "model": "qwen3.6:latest",
  "messages": [{"role": "user", "content": "Say hello in one sentence"}],
  "stream": false,
  "options": {"num_predict": 64}
}' 2>/dev/null)
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
TOKENS=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message',{}).get('token_count',0))" 2>/dev/null)
echo "Duration: ${DURATION}ms"
echo "Tokens: $TOKENS"
if [ "$DURATION" -gt 0 ] && [ ! -z "$TOKENS" ]; then
  TPS=$(echo "scale=2; $TOKENS * 1000 / $DURATION" | bc 2>/dev/null)
  echo "Tokens/sec: $TPS"
fi

# Test 2: Medium response (256 tokens)
echo ""
echo "--- Test 2: Medium response (256 tokens) ---"
START=$(date +%s%N)
RESP=$(curl -s http://127.0.0.1:11434/api/chat -H 'Content-Type: application/json' -d '{
  "model": "qwen3.6:latest",
  "messages": [{"role": "user", "content": "Explain GPU memory management in 256 words or less"}],
  "stream": false,
  "options": {"num_predict": 256}
}' 2>/dev/null)
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
TOKENS=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message',{}).get('token_count',0))" 2>/dev/null)
echo "Duration: ${DURATION}ms"
echo "Tokens: $TOKENS"
if [ "$DURATION" -gt 0 ] && [ ! -z "$TOKENS" ]; then
  TPS=$(echo "scale=2; $TOKENS * 1000 / $DURATION" | bc 2>/dev/null)
  echo "Tokens/sec: $TPS"
fi

echo ""
echo "=== Test Complete ==="
