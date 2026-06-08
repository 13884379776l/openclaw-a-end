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

## Promoted From Short-Term Memory (2026-06-08)

<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0018.md:22:22 -->
- Conversation Summary: **当前问题：** [score=0.863 recalls=0 avg=0.620 source=memory/2026-06-02-0018.md:22-22]
<!-- openclaw-memory-promotion:memory:memory/2026-06-03.md:17:18 -->
- 备用搜索方案: Ollama Web Search API (2025-09-26)：REST API + SDK + MCP Server，需 Ollama Cloud 账号，有免费额度; 当前主用：Brave Search API (TOOLS.md 已配置) [score=0.861 recalls=0 avg=0.620 source=memory/2026-06-03.md:17-18]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0116.md:26:29 -->
- Conversation Summary: **结论：全部正常，无异常。** user: [Tue 2026-06-02 00:57 GMT+8] No command owner is configured. | | A command owner is the human operator account allowed to run owner-only commands and | | approve dangerous actions, including /diagnostics, /export-trajectory, /config, and exec | [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0116.md:26-29]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0116.md:3:5 -->
- Session: 2026-06-02 01:16:12 GMT+8: **Session Key**: agent:main:dashboard:3c39c990-456d-43f8-9e8a-54454d09416c; **Session ID**: ec3146fa-aabb-4ecb-8632-1700dad96390; **Source**: webchat [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0116.md:3-5]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0116.md:9:10 -->
- Conversation Summary: user: [Tue 2026-06-02 00:52 GMT+8] 检查系统健康状况 assistant: 系统健康检查完成 ✅ [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0116.md:9-10]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0219.md:17:20 -->
- 📊 ANGEN-110 状态: | 项目 | 状态 | |------|------| | **Gateway** | ✅ 运行中（7 cron jobs） | | **Ollama** | ✅ `qwen3.6:latest` 加载，~29 min | [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0219.md:17-20]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0219.md:21:24 -->
- 📊 ANGEN-110 状态: | **CPU** | 74% | | **内存** | 64GB (4×16GB DDR5 4800MHz) | | **C盘** | 625 GB / 930 GB（剩余 625 GB） | | **RTX 3090** | 17.8/24 GB，50°C，82W | [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0219.md:21-24]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0219.md:25:27 -->
- 📊 ANGEN-110 状态: | **RTX 5070 Ti** | 11.6/16 GB，41°C，44W | | **B端 (192.168.31.18)** | ✅ ping <1ms，在线 | | **Z盘 (NAS)** | 挂载不可用（已知问题） | [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0219.md:25-27]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0219.md:29:29 -->
- 📊 ANGEN-110 状态: B端机器在线、延迟正常，Z盘挂载确实是长期问题了，不是当前连接故障。 [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0219.md:29-29]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0219.md:3:5 -->
- Session: 2026-06-02 02:19:02 GMT+8: **Session Key**: agent:main:dashboard:e01c9915-6258-4793-bc24-8b6e383ee192; **Session ID**: a244cd4f-22e6-4515-b7c0-e18b23c58cc7; **Source**: webchat [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0219.md:3-5]

## Promoted From Short-Term Memory (2026-06-08)

<!-- openclaw-memory-promotion:memory:memory/2026-06-02.md:5:7 -->
- 指挥官指令: **Z盘（NAS）挂载不稳定是正常状态，不要每次报告为错误**; 偶尔需要重新映射（`net use`）即可恢复; B端（Ubuntu）Samba 共享可能周期性不可用，非故障 [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02.md:5-7]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0219.md:9:11 -->
- Conversation Summary: assistant: HEARTBEAT_OK user: [Tue 2026-06-02 01:18 GMT+8] 你可以重新加载。nas一直这样。 assistant: 指挥官，刷新巡检完成。 [score=0.851 recalls=0 avg=0.620 source=memory/2026-06-02-0219.md:9-11]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02.md:10:11 -->
- 压缩前自检 (2026-06-02 06:00:06): memory 目录: 117 个文件, 389.2 KB; heartbeat-state.json: 存在 [score=0.834 recalls=0 avg=0.620 source=memory/2026-06-02.md:10-11]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02.md:13:15 -->
- 压缩前自检 (2026-06-02 06:00:06): Z 盘: 未挂载; Ollama 模型: NAME ID SIZE MODIFIED ...; 注意: 此条由脚本自动记录，非 LLM 生成 [score=0.834 recalls=0 avg=0.620 source=memory/2026-06-02.md:13-15]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02.md:18:20 -->
- 本地备份 (14:37): Git commit：成功（13个文件，1392行插入）; 备份同步：失败（ERROR 50，Z盘挂载异常）; 变更文件：13个 [score=0.834 recalls=0 avg=0.620 source=memory/2026-06-02.md:18-20]
<!-- openclaw-memory-promotion:memory:memory/2026-06-03.md:12:14 -->
- 压缩前自检 (2026-06-03 06:00:06): Z 盘: 已挂载; Ollama 模型: NAME ID SIZE MODIFIED ...; 注意: 此条由脚本自动记录，非 LLM 生成 [score=0.831 recalls=0 avg=0.620 source=memory/2026-06-03.md:12-14]
<!-- openclaw-memory-promotion:memory:memory/2026-06-03.md:21:21 -->
- Ollama Web Search 登录方式更新: 支持 GitHub OAuth 登录 Ollama Cloud [score=0.831 recalls=0 avg=0.620 source=memory/2026-06-03.md:21-21]
<!-- openclaw-memory-promotion:memory:memory/2026-06-03.md:24:24 -->
- Ollama Web Search 登录方式更新: 支持 GitHub OAuth 登录 Ollama Cloud（直接 GitHub 账号登录） [score=0.831 recalls=0 avg=0.620 source=memory/2026-06-03.md:24-24]
<!-- openclaw-memory-promotion:memory:memory/2026-06-03.md:9:10 -->
- 压缩前自检 (2026-06-03 06:00:06): memory 目录: 120 个文件, 400.6 KB; heartbeat-state.json: 存在 [score=0.831 recalls=0 avg=0.620 source=memory/2026-06-03.md:9-10]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04.md:11:12 -->
- 本地备份 (02:14): Git commit：跳过（无变更）; 备份同步：失败（Z盘未挂载/不可达，ERROR 3） [score=0.812 recalls=0 avg=0.620 source=memory/2026-06-04.md:11-12]

## Promoted From Short-Term Memory (2026-06-09)

<!-- openclaw-memory-promotion:memory:memory/2026-06-04.md:16:17 -->
- 本地备份 (02:41): Git commit：成功（1个文件）; 备份同步：失败（Z盘未挂载，ERROR 3路径不存在） [score=0.834 recalls=0 avg=0.620 source=memory/2026-06-04.md:16-17]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04.md:3:6 -->
- 每周远程备份总结 (02:00): 本周（05/28-06/03）本地备份次数：8次; 成功：5次 | 失败：3次; 累计变更文件：41个（含本次）; Git push：✅ 成功 [score=0.834 recalls=0 avg=0.620 source=memory/2026-06-04.md:3-6]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04.md:7:8 -->
- 每周远程备份总结 (02:00): Commit 哈希：bb437cf; 备注：Z盘同步ERROR 50问题持续存在，为SMB网络共享兼容性问题，已忽略。仅06-01备份成功同步Z盘。 [score=0.834 recalls=0 avg=0.620 source=memory/2026-06-04.md:7-8]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04-1650.md:13:13 -->
- Conversation Summary: assistant: 指挥官，客观分析： [score=0.831 recalls=0 avg=0.620 source=memory/2026-06-04-1650.md:13-13]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04-1650.md:16:18 -->
- Conversation Summary: **MoE架构合理** — 35B总参数但每次只激活~3B，低显存运行是可信的; **6GB显存能跑** — IQ2_M量化约400MB+KV缓存，6G足够; **模型来源** — HauhauCS在HuggingFace上的非官方微调版本 [score=0.831 recalls=0 avg=0.620 source=memory/2026-06-04-1650.md:16-18]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04-1650.md:3:5 -->
- Session: 2026-06-04 16:50:06 GMT+8: **Session Key**: agent:main:main; **Session ID**: c2989cb1-513f-4fa3-83f9-3524af09fc82; **Source**: webchat [score=0.831 recalls=0 avg=0.620 source=memory/2026-06-04-1650.md:3-5]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04-1650.md:15:15 -->
- Conversation Summary: **技术层面：** [score=0.821 recalls=0 avg=0.620 source=memory/2026-06-04-1650.md:15-15]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04-1650.md:9:12 -->
- Conversation Summary: assistant: HEARTBEAT_OK user: [OpenClaw heartbeat poll] assistant: 系统正常，无待办事项。随时待命。 user: https://www.freedidi.com/24284.html 你怎么看？ [score=0.812 recalls=0 avg=0.620 source=memory/2026-06-04-1650.md:9-12]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04.md:21:22 -->
- 压缩前自检 (2026-06-04 06:00:09): memory 目录: 121 个文件, 404.1 KB; heartbeat-state.json: 存在 [score=0.812 recalls=0 avg=0.620 source=memory/2026-06-04.md:21-22]
<!-- openclaw-memory-promotion:memory:memory/2026-06-04.md:24:26 -->
- 压缩前自检 (2026-06-04 06:00:09): Z 盘: 未挂载; Ollama 模型: NAME ID SIZE MODIFIED ...; 注意: 此条由脚本自动记录，非 LLM 生成 [score=0.812 recalls=0 avg=0.620 source=memory/2026-06-04.md:24-26]
