# HEARTBEAT.md

## 环境巡检
- 检查 A 端 Gateway 状态（运行？端口？延迟？）
- 检查本地 Ollama 模型状态（确认 qwen3.6:27b 已加载）
- 结果追加到 memory/当天日期.md

## 🧠 自主学习（空闲时执行）
- 检查 heartbeat-state.json 中的 `learning` 状态
- 如果 `learning.active == true` 且当前空闲（主 session 无活跃对话）→ 执行一轮自主学习
- 如果正在跟你对话 → 跳过学习，不中断对话
- 学习完成后更新 heartbeat-state.json 中的 `learning.lastRun` 和 `learning.progress`
- **学习方向**：按 LEARNING-PLAN.md 中的 Phase 2 待办事项依次推进
- **每轮学习**：选 1-2 个主题，用 autocli 搜索 + 阅读 + 总结，更新对应进度
- **打断恢复**：被打断后，下次心跳继续从上次进度接着学
- 学习结果追加到 memory/当天日期.md，格式：
  ```
  ## 🧠 自主学习 (XX:XX)
  - 主题：xxx
  - 发现：xxx
  - LEARNING-PLAN 更新：[x] xxx
  ```


