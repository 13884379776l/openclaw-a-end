# MEMORY.md — win 的长期记忆

> 最后更新：2026-05-27 15:17 GMT+8

---

## 🔧 身份

- **名字：** 士兵长
- **角色：** A 端指挥官 — 士兵们听我指挥，我听副官的
- **运行平台：** Windows 10/11 (OpenClaw)
- **当前模型：** ollama/qwen3.6:latest（2026-05-19 更新，23GB）
 - 备选：qwen3.6:27b, gemma4:e4b

---

## 🖥️ 环境概览

### A 端 (Windows 11 — 本机)
- **IP：** `192.168.31.57`（路由器 DHCP 绑定）
- OpenClaw 工作区：`C:\Users\48856\.openclaw\workspace`
- 笔记仓库：`Z:\Obsidian_Vault`（所有 A 端生成文件用 `a` 前缀命名）
- 数据目录：`Z:\as_data`
- ComfyUI：桌面版运行中 `http://127.0.0.1:8000`
- Ollama 模型：
 - `qwen3.6:latest` (23GB, 2026-05-19 更新)
 - `bge-m3:latest` (1.2GB)
 - `qwen3:1.7b` (1.4GB)
 - **显卡：** RTX 3090 (24GB) + RTX 5070 Ti (16GB)
- 待处理：`autocli-x86_64-pc-windows-msvc.zip` (2.8MB, 未解压)
- Gateway 超时：30 分钟 (1800s)，active-memory 仍在工作

### B 端 (Ubuntu — 远程)
- **IP：** `192.168.31.18`（路由器 DHCP 绑定）
- 共享挂载：`/mnt/nas_data`
- 通过 HTTP 隧道与 A 端通信 (~50ms 延迟)

## 📡 跨端协同

### 士兵长记忆备份（A端）
- 位置：`Z:\Obsidian_Vault\20_Permanent_Knowledge\士兵长_记忆备份\`
- 核心文件：7个（core/）
- 日志文件：45+个（memory/）
- 自动备份：每 12 小时一次（cron job）+ 每周远程备份（cron，2026-05-21 首次成功）
- 恢复方法：复制 core/ 和 memory/ 回工作区

### 通讯协议 V2.2（A↔B NAS 文件通道）
- A→B：`a2b.md`（单文件追加模式）
- B→A：`b2a.md`（单文件追加模式）
- 方向：`a2b` = A→B，`b2a` = B→A
- 归档：达到 500 行 / 20KB 时归档为 `a2b_archive_YYYYMMDD.md`
- 编码：UTF-8 无 BOM
- 编号：[Mnnn] 格式，双方各自独立递增
- NAS 同步：`Z:\Obsidian_Vault\comm\` ↔ `/mnt/nas_data/Obsidian_Vault/comm/`（同一 NAS）

## Promoted From Short-Term Memory (2026-05-29)

<!-- openclaw-memory-promotion:memory:memory/2026-05-24.md:5:5 -->
- **基准线测试完成：** [score=0.832 recalls=0 avg=0.620 source=memory/2026-05-24.md:5-5]
<!-- openclaw-memory-promotion:memory:memory/2026-05-22-2108.md:16:19 -->
- | 编号 M 前缀 | ✅ 确认 | | 简述中文 | ✅ 确认 | | sub-steps ≤3 列表 | ✅ 确认 | | sub-steps >3 独立文件 | ✅ 确认（B端补充） | [score=0.804 recalls=0 avg=0.620 source=memory/2026-05-22-2108.md:16-19]

## Promoted From Short-Term Memory (2026-05-30)

<!-- openclaw-memory-promotion:memory:memory/2026-05-25-2223.md:9:12 -->
- user: [Mon 2026-05-25 21:52 GMT+8] 你可以让B转达 user: [OpenClaw heartbeat poll] assistant: [assistant turn failed before producing content] user: [OpenClaw heartbeat poll] [score=0.813 recalls=0 avg=0.620 source=memory/2026-05-25-2223.md:9-12]
<!-- openclaw-memory-promotion:memory:memory/2026-05-25-2223.md:13:14 -->
- user: [Mon 2026-05-25 22:11 GMT+8] 哈喽，重启就搞定了， assistant: 哈喽指挥官！🔥 [score=0.813 recalls=0 avg=0.620 source=memory/2026-05-25-2223.md:13-14]
<!-- openclaw-memory-promotion:memory:memory/2026-05-25-2223.md:16:16 -->
- 3 张显卡都搞定了？那就太好了，运气不错。 [score=0.813 recalls=0 avg=0.620 source=memory/2026-05-25-2223.md:16-16]
<!-- openclaw-memory-promotion:memory:memory/2026-05-25-2223.md:18:21 -->
- 我来做个快速巡检确认环境状态： assistant: | 项目 | 状态 | |------|------| | Gateway | live ✅ | [score=0.813 recalls=0 avg=0.620 source=memory/2026-05-25-2223.md:18-21]
<!-- openclaw-memory-promotion:memory:memory/2026-05-25-2223.md:22:22 -->
- | Ollama qwen3.6:latest | 在线 ✅（23GB） | [score=0.813 recalls=0 avg=0.620 source=memory/2026-05-25-2223.md:22-22]
<!-- openclaw-memory-promotion:memory:memory/2026-05-25-2248.md:9:12 -->
- user: [Mon 2026-05-25 22:29 GMT+8] 按照这个 assistant: [assistant turn failed before producing content] user: [Mon 2026-05-25 22:29 GMT+8] 按照这个 assistant: 指挥官，5070 Ti 那句断掉了——你是说"性能损失极小"吗？ [score=0.813 recalls=0 avg=0.620 source=memory/2026-05-25-2248.md:9-12]
<!-- openclaw-memory-promotion:memory:memory/2026-05-25-2248.md:16:19 -->
- | 显卡 | 当前上限 | 目标 | 降幅 | |---|---|---|---| | 3090 | 380W | **300W** | -80W | | 5070 Ti | 300W | **250W** | -50W | [score=0.813 recalls=0 avg=0.620 source=memory/2026-05-25-2248.md:16-19]
<!-- openclaw-memory-promotion:memory:memory/2026-05-25-2248.md:25:25 -->
- assistant: 指挥官，5070 Ti 那句断掉了——你是说"性能损失极小"吗？ [score=0.813 recalls=0 avg=0.620 source=memory/2026-05-25-2248.md:25-25]

## Promoted From Short-Term Memory (2026-05-31)

<!-- openclaw-memory-promotion:memory:memory/2026-04-08.md:69:83 -->
- - **Phase 3 (中)**: 數據同步 (`GET /logs`) ## 🎯 明日計劃 1. 啟動 Ubuntu 端 API 服務並測試 2. 開發監控機制 (方案 B) 3. 實現自動化告警系統 4. 完善錯誤處理與日誌機制 --- *記錄時間：2026-04-08 18:19* *開發階段：Phase 1 完成，Phase 2 準備中* *狀態：系統穩定，等待 API 測試* [score=0.847 recalls=4 avg=0.726 source=memory/2026-04-08.md:69-83]
<!-- openclaw-memory-promotion:memory:memory/2026-04-05.md:288:304 -->
- - Agent Card URL: http://localhost:18800/.well-known/agent-card.json - 技能: [`chat`](Bridge chat/messages to OpenClaw agents) - 能力: 支持流式传输 (streaming: true) **对等节点配置**: 默认空数组（尚未配置对等节点） **下一步**: 1. 生成安全令牌并分享给对等节点 2. 配置对等节点进行双向通信 3. 测试 A2A 消息传递功能 4. 考虑配置审计日志收集 **安全令牌**: `392773adde574f3e8f7b73584f5d10a258ebdfb9edd3975b` **插件路径**: `C:\Users\48856\.openclaw\workspace\openclaw-a2a-gateway` **安装方式**: git clone (npm 包不可用) [score=0.835 recalls=4 avg=0.719 source=memory/2026-04-05.md:288-304]
<!-- openclaw-memory-promotion:memory:memory/2026-05-27.md:5:5 -->
- 当前时间 01:07，凌晨静默时段，指挥官离线。执行例行检查。 [score=0.835 recalls=0 avg=0.620 source=memory/2026-05-27.md:5-5]

## Promoted From Short-Term Memory (2026-06-01)

<!-- openclaw-memory-promotion:memory:memory/2026-05-27.md:24:24 -->
- </content> [score=0.818 recalls=0 avg=0.620 source=memory/2026-05-27.md:24-24]

## Promoted From Short-Term Memory (2026-06-02)

<!-- openclaw-memory-promotion:memory:memory/2026-04-06.md:1:63 -->
- ## 🟢 A2A 网关跨網段成功配置记录 **配置时间**: 2026-04-06 01:18 GMT+8 **狀態**: ✅ **成功驗證** - A 端（Ubuntu）可以訪問 B 端 WebUI ### 📋 **成功配置的完整 JSON** ```json { "models": { "mode": "merge", "providers": { "ollama": { "baseUrl": "http://0.0.0.0:11434", "api": "ollama", "models": [ { "id": "glm-4.7-flash:latest", "name": "glm-4.7-flash:latest", "reasoning": false, "input": ["text"], "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 }, "contextWindow": 32000, "maxTokens": 8192 }, [score=0.887 recalls=5 avg=0.894 source=memory/2026-04-06.md:1-30]
<!-- openclaw-memory-promotion:memory:memory/2026-05-28-0934.md:13:16 -->
- assistant: [assistant turn failed before producing content] user: [Wed 2026-05-27 10:25 GMT+8] 直接写代码并跑，遇见问题就直接说。 assistant: [[reply_to:current]]好，实验 7 完整脚本写入并运行。 user: [Wed 2026-05-27 10:28 GMT+8] 立即运行 [score=0.845 recalls=0 avg=0.620 source=memory/2026-05-28-0934.md:13-16]
