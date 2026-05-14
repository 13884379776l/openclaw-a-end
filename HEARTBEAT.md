# HEARTBEAT.md

## 环境巡检
- 检查 A 端 Gateway 状态（运行？端口？延迟？）
- 检查本地 Ollama 模型状态（curl http://127.0.0.1:11434/api/tags，确认 qwen3.6:27b 已加载）
- 如果 qwen3.6:27b 未加载，发送预热请求：curl http://127.0.0.1:11434/api/generate -d '{"model":"qwen3.6:27b","prompt":".","stream":false,"options":{"keep_alive":"10m"}}'
- 结果追加到 memory/2026-05-13.md


