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

## Promoted From Short-Term Memory (2026-06-04)

<!-- openclaw-memory-promotion:memory:memory/2026-05-29-1400.md:16:16 -->
- **不是因为信息多，而是因为信息需要**筛选**。 [score=0.864 recalls=0 avg=0.620 source=memory/2026-05-29-1400.md:16-16]

## Promoted From Short-Term Memory (2026-06-06)

<!-- openclaw-memory-promotion:memory:memory/2026-05-30-learning-synapse-api.md:13:13 -->
- 端口发现: | 9090 | Synapse Admin API | ❌ 不可达（需开启） | [score=0.862 recalls=0 avg=0.620 source=memory/2026-05-30-learning-synapse-api.md:13-13]
<!-- openclaw-memory-promotion:memory:memory/2026-05-30-learning-synapse-api.md:15:15 -->
- 端口发现: **关键发现：Client API 走 8008 端口，不需要 admin_api_enabled。** [score=0.862 recalls=0 avg=0.620 source=memory/2026-05-30-learning-synapse-api.md:15-15]
<!-- openclaw-memory-promotion:memory:memory/2026-06-01.md:13:16 -->
- 每周远程备份总结 (02:01): 本周本地备份次数：10次（7次 daily-backup + 3次 weekly-summary）; 成功：10次 | 失败：0次; 累计变更文件：17个 commit; Git push：✅ 成功 [score=0.861 recalls=0 avg=0.620 source=memory/2026-06-01.md:13-16]
<!-- openclaw-memory-promotion:memory:memory/2026-06-01.md:17:17 -->
- 每周远程备份总结 (02:01): Commit 哈希：0ed01d2 [score=0.861 recalls=0 avg=0.620 source=memory/2026-06-01.md:17-17]
<!-- openclaw-memory-promotion:memory:memory/2026-06-01.md:20:21 -->
- 压缩前自检 (2026-06-01 06:00:22): memory 目录: 112 个文件, 375.7 KB; heartbeat-state.json: 存在 [score=0.861 recalls=0 avg=0.620 source=memory/2026-06-01.md:20-21]
<!-- openclaw-memory-promotion:memory:memory/2026-05-30-learning-synapse-api.md:21:21 -->
- 登录: POST http://192.168.31.18:8008/_matrix/client/v3/login [score=0.854 recalls=0 avg=0.620 source=memory/2026-05-30-learning-synapse-api.md:21-21]
<!-- openclaw-memory-promotion:memory:memory/2026-05-30-learning-synapse-api.md:23:25 -->
- 登录: "type": "m.login.password", "identifier": {"type": "m.id.user", "user": "commander"}, "password": "Cmd@123456!" [score=0.854 recalls=0 avg=0.620 source=memory/2026-05-30-learning-synapse-api.md:23-25]
<!-- openclaw-memory-promotion:memory:memory/2026-05-30-learning-synapse-api.md:3:3 -->
- Synapse Client API 学习（通过 8008 端口）: **学习时间：2026-05-30 23:28 GMT+8** [score=0.854 recalls=0 avg=0.620 source=memory/2026-05-30-learning-synapse-api.md:3-3]
<!-- openclaw-memory-promotion:memory:memory/2026-05-30-learning-synapse-api.md:9:12 -->
- 端口发现: | 端口 | 服务 | 可达性 | |------|------|--------| | 8088 | Element Web | ✅ 可达 | | 8008 | Synapse Client API | ✅ 可达 | [score=0.854 recalls=0 avg=0.620 source=memory/2026-05-30-learning-synapse-api.md:9-12]
<!-- openclaw-memory-promotion:memory:memory/2026-05-30.md:11:14 -->
- Matrix 通讯部署 (2026-05-30 18:00): B 端已更新通讯，指令 A 端安装 Element Desktop; 服务器地址：`http://192.168.31.18:8088`; A 端（士兵长）登录凭据：; 服务器地址：`http://192.168.31.18:8088` [score=0.854 recalls=0 avg=0.620 source=memory/2026-05-30.md:11-14]

## Promoted From Short-Term Memory (2026-06-07)

<!-- openclaw-memory-promotion:memory:memory/2026-06-01.md:3:5 -->
- 本地备份 (13:53): Git commit：成功（13 个文件变更）; 备份同步：失败（Z: 盘属性设置错误）; 变更文件：13 个 [score=0.870 recalls=0 avg=0.620 source=memory/2026-06-01.md:3-5]
<!-- openclaw-memory-promotion:memory:memory/2026-06-03.md:4:6 -->
- 本地备份 (02:14): Git commit：成功（7 个文件，479 行新增）; 备份同步：失败（Z 盘 ERROR 50：不支持文件属性操作，可能为网络挂载/特殊卷）; 变更文件：7 个 [score=0.863 recalls=0 avg=0.620 source=memory/2026-06-03.md:4-6]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0018.md:13:14 -->
- Conversation Summary: assistant: 找到了！昨天的学习记录里有关键发现。让我查看： assistant: 指挥官，昨天的记录找到了： [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0018.md:13-14]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0018.md:16:16 -->
- Conversation Summary: **5月30-31日士兵长的学习成果：** [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0018.md:16-16]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0018.md:17:20 -->
- Conversation Summary: 通过 Synapse Client API（8008端口）成功登录 commander 账户; 发现 3 个房间，包括 `!WXyqvGnGVJGsgSODSR`（三端实时通讯）; 写了 `matrix-bridge.ps1` 脚本作为手动桥接方案; 待验证：Client API 发送消息 [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0018.md:17-20]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0018.md:3:5 -->
- Session: 2026-06-02 00:18:04 GMT+8: **Session Key**: agent:main:dashboard:537e8fe5-09e6-4c19-8f9b-b3bb39b13c31; **Session ID**: 2506a857-c2f3-46fa-b313-df859924139d; **Source**: webchat [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0018.md:3-5]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0018.md:9:12 -->
- Conversation Summary: assistant: 指挥官批评得对。我查通讯日志，看看昨天记录了什么。 assistant: 找到了，昨天写过一个手动矩阵桥接脚本。继续翻昨天的通讯记录： assistant: 指挥官说得对，我一直在重复查同一个问题。昨天写的记录在哪里？让我直接看昨天的日志和通讯通道。 assistant: 找到了。昨天（5月31日）的学习日志显示了一个关键发现： [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0018.md:9-12]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0116.md:14:17 -->
- Conversation Summary: | 项目 | 状态 | 详情 | |------|------|------| | **Gateway** | ✅ 在线 | 运行 2m 17s | | **Ollama** | ✅ 在线 | 6 个模型就绪 | [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0116.md:14-17]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0116.md:18:21 -->
- Conversation Summary: | **主模型** | ✅ qwen3.6:latest | 23GB | | **CPU** | ✅ 正常 | 负载 20% | | **内存** | ✅ 充裕 | 52.2 / 64.9 GB (80.5% 空闲) | | **C盘** | ✅ 充足 | 625.5 GB 可用 (67.2%) | [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0116.md:18-21]
<!-- openclaw-memory-promotion:memory:memory/2026-06-02-0116.md:22:24 -->
- Conversation Summary: | **GPU 3090** | ✅ 正常 | 40°C，6.8W，空闲 | | **GPU 5070 Ti** | ✅ 正常 | 45°C，8.4W，空闲 | | **Cron** | ✅ 7 个任务 | 下次唤醒 00:59 | [score=0.854 recalls=0 avg=0.620 source=memory/2026-06-02-0116.md:22-24]

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
