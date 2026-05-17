# MEMORY.md — win 的长期记忆

> 最后更新：2026-05-17 02:00 GMT+8

---

## 🔧 身份

- **名字：** 士兵长
- **角色：** A 端指挥官 — 士兵们听我指挥，我听副官的
- **运行平台：** Windows 10/11 (OpenClaw)
- **模型：** ollama/qwen3.6:27b

---

## 🖥️ 环境概览

### A 端 (Windows 11 — 本机)
- **IP：** `192.168.31.57`（路由器 DHCP 绑定）
- OpenClaw 工作区：`C:\Users\48856\.openclaw\workspace`
- 笔记仓库：`Z:\Obsidian_Vault`（所有 A 端生成文件用 `a` 前缀命名）
- 数据目录：`Z:\as_data`
- ComfyUI：桌面版运行中 `http://127.0.0.1:8000`
- Ollama 模型：qwen3.6:latest, qwen3.6:27b, gemma4:e4b, mistral-small:24b
- 待处理：`autocli-x86_64-pc-windows-msvc.zip` (2.8MB, 未解压)
- Gateway 超时：30 分钟 (1800s)，active-memory 仍在工作

### B 端 (Ubuntu — 远程)
- **IP：** `192.168.31.18`（路由器 DHCP 绑定）
- 共享挂载：`/mnt/nas_data`
- 曾部署 A2A HTTP API (execute.js) 用于远程命令下发
- 通过 HTTP 隧道与 A 端通信 (~50ms 延迟)
- 副官已阵亡，记忆备份在 `Z:\Obsidian_Vault\main\session\`

---

## 📜 重大事件时间线

### 2026-04-05 ~ 04-06：A2A 网关插件部署
- 安装了 `@win4r/openclaw-a2a-gateway` 插件（Agent-to-Agent 协议 v0.3.0）
- 实现了跨网段 A→B 通信，A 端可访问 B 端 WebUI
- 配置了 mDNS + DNS-SD 自动发现，JSON-RPC/REST/gRPC 三种传输

### 2026-04-08：A2A 架构建设完成 Phase 1
- 完成双端 HTTP 通信隧道 (Windows ↔ Ubuntu)
- 开发 `execute.js` API（远程命令执行 + 白名单机制）
- **放弃 Samba 直接访问方案**（Windows 端 Samba 支持问题），转向 A2A HTTP API 指令下发
- 撰写多份技术文档：A2A_Deployment_Guide, A2A_Dual_End_Architecture, Samba 分析报告

### 2026-04-09：Web UI 局域网访问修复
- 问题：`gateway.bind: "loopback"` 导致无法局域网访问
- 解决：改为 `"0.0.0.0"`，支持 `<局域网IP>:18789` 访问
- 整理了 OpenClaw 技能系统（9 个技能）

### 2026-04-11：文件组织 + ComfyUI 问题解决
- 转移 A 端笔记到 Z:\Obsidian_Vault，统一 `a` 前缀命名规则
- 解决 ComfyUI 桌面版依赖加载失败问题（禁用有问题的 custom_nodes）
- 记录桌面版 ComfyUI 限制：不支持 pip install，仅适合基础节点和简单工作流

### 2026-05-09：A2A 双向全链路打通 ✅
- **A→B + B→A 全部打通** — 零 300s 超时，全部 completed
- 本地自测 `8955138b`: 51s | A→B `2e9ea7ef`: 173s | B→A `e17ad34a`: 205s
- **最终修复：** `openclaw gateway install`（管理员权限）修复计划任务版本不匹配
- **双 patch 位置**（不受 install 影响，在 `extensions/` 目录）：
  - `extensions/a2a-gateway/dist/index.js:168` — fallback `"main"`
  - `extensions/a2a-gateway/dist/src/executor.js:23-30` — 拦截 `"default"` → `"main"`
- **副官确认 B 端全稳**（Gateway + A2A + V100）
- **详细日志:** `memory/2026-05-09.md`

### 2026-05-17：Gateway 修复 + 配置审计
- **Windows 计划任务版本不匹配**: `openclaw gateway install` 修复后 Gateway 回归正常（`valid: true`，0 issues/warnings）
- **确认无 300 秒超时问题**: `agents.defaults.timeoutSeconds = 1800`，日志中无相关报错
- **发现隐藏插件 memory-core**: 出现在 `plugins.entries` 中，`config: {}`，待研究
- **active-memory 配置确认**: 仍在工作，queryMode=recent, timeoutMs=15000

---

## 💡 经验教训

### 🎯 Ollama GPU 选择（核心教训）

1. **`CUDA_VISIBLE_DEVICES` 对 Ollama 无效** — Ollama 内部有自己的 GPU 发现逻辑，会覆盖系统环境变量中的 GPU 序号
2. **唯一可靠方式：NVIDIA UUID** — 通过 `nvidia-smi -L`（Linux）或 `nvidia-smi --query-gpu=name,uuid --format=csv` 查 UUID，然后用 `CUDA_VISIBLE_DEVICES=GPU-xxxxxxxx` 指定
3. **Linux 下用户必须在 `video` 组** — 否则即使 UUID 正确，Ollama 也无法访问 `/dev/nvidia*` 设备，会静默退化为纯 CPU（`total_vram="0 B"`），导致大模型内存不足报错
4. **诊断方法：** `journalctl -u ollama -n 50 | grep 'inference compute'`，如果只有 `id=cpu` 而无 CUDA 设备，就是权限问题
5. **A 端已验证**（2026-05-06）：5070 Ti + 3090，UUID 指定 3090 后 65/65 层全部上 GPU
6. **B 端已验证**（2026-05-13）：750 Ti + V100，UUID 指定 V100 后 100% GPU（之前 100% CPU）
7. **B 端最终修复**（2026-05-15）：`sudo usermod -aG video ubuntu` + 重启服务，V100 显存 24.5GB 满载 ✅

### 其他教训

1. Samba 在 Windows 端不稳定 → 改用 HTTP API 远程执行
2. Context limit 超限频繁 → 应设置 `compaction.reserveTokensFloor` 到 20000+
3. 桌面版 ComfyUI 依赖管理差 → 需要自定义节点时考虑服务端部署
4. Ollama 模型存储 → `~/.ollama/models1` 是备份目录，实际模型在 `~/.ollama/models`
5. Gateway install 修复计划任务版本不匹配 → `openclaw gateway install`（管理员权限）可解决
6. `openclaw gateway call config.get` 可获取完整 Gateway 配置，比读 JSON 文件更方便

---

## 📡 跨端协同

### 士兵长记忆备份（A端）
- 位置：`Z:\Obsidian_Vault\20_Permanent_Knowledge\士兵长_记忆备份\`
- 核心文件：7个（core/）
- 日志文件：39个（memory/）
- 自动备份：每 12 小时一次（cron job）
- 恢复方法：复制 core/ 和 memory/ 回工作区

### 副官记忆备份（B端 — 已阵亡）
- 位置：`Z:\Obsidian_Vault\main\session\`
- 内容：2个 session 文件（2026-05-12 ~ 05-13）
- 关键偏好：工具使用前必检、Brave API 每日 15 次限额

## 🎯 未完成 / 长期目标

- [x] A2A 双向全链路打通（A→B + B→A）✅
- [ ] GPU 风扇控制（需管理员 PowerShell 执行）
- [ ] B 端 Ollama 模型清理
- [ ] 解压 `autocli-x86_64-pc-windows-msvc.zip`（一直搁置）
- [ ] 考虑 ComfyUI 服务端部署方案

---

## ⚙️ 关键配置备忘

- OpenClaw 端口：18789
- A2A 端口：18800
- Gateway 认证模式：token
- Gateway bind：0.0.0.0（允许局域网访问）

## Promoted From Short-Term Memory (2026-05-18)

<!-- openclaw-memory-promotion:memory:memory/2026-05-07.md:1:12 -->
- # 2026-05-07 日志 ## 收尾 - 01:46 准备关机睡觉 - OpenClaw 运行正常，无紧急待办 - B 端 A2A 通信离线（未连接节点） - autocli v0.3.7 已安装（CLI 网站适配器，50+ 站点） - 11:55 删除了旧的 autocli zip 包（程序已安装在 LOCALAPPDATA） - 23:42 记录双端 IP 地址到 MEMORY.md（之前一直忘）： - A 端：192.168.31.57（路由器 DHCP 绑定） - B 端：192.168.31.18（路由器 DHCP 绑定） [score=0.988 recalls=12 avg=1.000 source=memory/2026-05-07.md:1-12]
<!-- openclaw-memory-promotion:memory:memory/2026-05-09.md:91:110 -->
- - [ ] B 端 Ollama 模型清理（`ollama rm` 无用模型） - [ ] A 端 A2A 插件持久化验证（重启 Windows 后自动恢复） ## 环境信息 - **A 端 IP：** 192.168.31.57 - **B 端 IP：** 192.168.31.18 - **A2A token (A→B)：** `5ff5b9c0` - **A2A token (B→A)：** `392773ad...` - **OpenClaw 版本：** 2026.5.7 (eeef486) - **Gateway PID：** 17140（node.exe，Scheduled Task 管理） - **模型：** ollama/qwen3.6:27b ## B 端状态 - Gateway 18789 ✅ - A2A 18800 ✅ - V100 GPU 稳定 ✅ - 等待 A 端 clean 重启后做全链路测试 [score=0.976 recalls=13 avg=0.956 source=memory/2026-05-09.md:91-110]
<!-- openclaw-memory-promotion:memory:memory/2026-04-05.md:73:153 -->
- "priorities": ["jsonrpc", "rest", "grpc"], // 传输协议优先级 "retryStrategy": "exponential", "maxRetries": 3 }, "michaelisMenten": { "enabled": true, "baseDelayMs": 1000, "Km": 10 // 最大酶浓度 }, "circuitBreaker": { "enabled": true, "failureThreshold": 5, "recoveryTimeMs": 30000 } } } ``` ### 🔗 与其他 OpenClaw 通信 #### A 端（发起方） 配置目标对等方： ```json { "peers": [ { "name": "server-b", "address": "http://192.168.1.100:18800", "tags": ["coding", "analysis"], "skills": ["python", "llm"] } ] } ``` #### B 端（接收方） 只需确保： - A2A 服务在监听端口 - mDNS/DNS-SD 已启用 - 网络连通性正常 其他 OpenClaw 节点会自动发现你！ [score=0.970 recalls=18 avg=1.000 source=memory/2026-04-05.md:73-118]
<!-- openclaw-memory-promotion:memory:memory/2026-04-05.md:246:295 -->
- - [OpenClaw 官方文档](https://docs.openclaw.ai) - [项目仓库](https://github.com/win4r/openclaw-a2a-gateway) ### 🆘 常见问题 **Q: 插件安装后如何确认生效？** A: 运行 `openclaw status` 查看插件状态，确认 a2a 服务在 18800 端口监听。 **Q: 如何手动指定对等节点？** A: 编辑配置文件，在 `peers` 数组中添加目标节点信息。 **Q: 能否关闭自动发现？** A: 在配置中设置 `discovery.enabled: false`。 **Q: 审计日志存储在哪里？** A: 默认存储在 OpenClaw 日志目录，JSONL 格式。 **Q: 如何自定义 Hill 方程参数？** A: 编辑配置中的 `routing.hillEquation` 部分，调整 `n` 和 `Kd` 值。 --- **创建时间**: 2026-04-05 **版本**: v1.0 --- ## 🟢 A2A 网关配置成功记录 **配置时间**: 2026-04-05 23:24 GMT+8 **状态**: ✅ 插件已成功安装并配置 **插件信息**: - 名称: `A2A Gateway` - ID: `a2a-gateway` - 版本: 1.3.0 - 状态: loaded - 协议: A2A v0.3.0 **服务状态**: - A2A 服务运行在端口: 18800 - Agent Card URL: http://localhost:18800/.well-known/agent-card.json - 技能: [`chat`](Bridge chat/messages to OpenClaw agents) - 能力: 支持流式传输 (streaming: true) **对等节点配置**: 默认空数组（尚未配置对等节点） **下一步**: 1. 生成安全令牌并分享给对等节点 [score=0.961 recalls=9 avg=1.000 source=memory/2026-04-05.md:246-295]
<!-- openclaw-memory-promotion:memory:memory/2026-05-08.md:1:35 -->
- # 2026-05-08 — A2A 修复日 ## 目标 修复 OpenClaw 5.7 升级后 A2A gateway (18800) 无法工作的问题 ## 问题诊断 ### 问题 1: 端口未监听 - 原因：`startupInline` PATCH 位置不对，在 `registerGatewayMethod` 调用**之后** - 修复：`openclaw plugins install --force` 重新安装，PATCH 正确注入 ### 问题 2: Token 不匹配 - A 端配置的 B 端 token 是 `392773ad...`，B 端实际用的是 `5ff5b9c0` - 修复：副官同步了 token ### 问题 3: registerGatewayMethod 回调签名不兼容 - OpenClaw 5.7 从 `({params, respond})` 改为 `async (opts) => return {ok, ...}` - 修复：手动改了 5 个回调（a2a.metrics, a2a.audit, a2a.pushNotification.register/unregister, a2a.send） ### 问题 4 (致命): registerGatewayMethod 是 noop - **OpenClaw 5.7 的 `registerGatewayMethod = () => {}`**（空函数） - 来源：`api-builder-ngUrqxn2.js:6` — `noopRegisterGatewayMethod` - 结果：所有通过 `registerGatewayMethod` 注册的方法（包括 `a2a.send`）都不会被路由 - `browser.request` 虽然也注册了但同样无效 ## 最终状态 | 组件 | 状态 | 说明 | |---|---|---| | 18800 端口 | ✅ LISTENING | HTTP 服务器正常 | | Agent Card | ✅ 正常 | A-Node (5070Ti) | | B 端连通 | ✅ 可达 | Agent Card 发现正常 | | JSON-RPC 方法 | ❌ 不可用 | registerGatewayMethod 是 noop | | 直接 HTTP → B 端 | ❌ 超时 | B 端 /a2a/jsonrpc 无响应 | [score=0.950 recalls=17 avg=1.000 source=memory/2026-05-08.md:1-35]
<!-- openclaw-memory-promotion:memory:memory/2026-05-09.md:63:100 -->
- 3. **B 端发来的消息没带 `message.agentId`**，导致 `pickAgentId` 走 fallback 分支 4. **`plugins enable` 的 hot-reload 不会刷新 ESM 模块缓存** 5. **需要 clean Gateway 重启**让 Node 重新 require executor.js ### 为什么 A2A 18800 反复掉线？ 1. **EADDRINUSE** — 之前有僵尸 Node 进程占用了 18800 2. **`plugins enable` CLI 进程被 SIGKILL** — 导致插件实例被清理 3. **频繁重启** — 我自己触发了 ~7 次 Gateway 重启 ## 当前 patch 位置 | 文件 | 行号 | 改动 | |------|------|------| | `dist/index.js` | 168 | `asString(routing.defaultAgentId, "main")` | | `dist/src/executor.js` | 23-30 | `if (fallback === "default") { fallback = "main"; }` | | Config | `plugins.entries.a2a-gateway.config.routing.defaultAgentId` | `"main"` | ## ✅ 已完成 - [x] A2A 双向全链路打通（A→B + B→A） - [x] `gateway install` 修复计划任务版本不匹配 - [x] 双 patch 生效（index.js + executor.js） - [x] B 端 Gateway + A2A + V100 全稳 ## 明日待办 - [ ] GPU 风扇控制（管理员 PowerShell 执行 `python -u gpu-fan-power.py`） - [ ] B 端 Ollama 模型清理（`ollama rm` 无用模型） - [ ] A 端 A2A 插件持久化验证（重启 Windows 后自动恢复） ## 环境信息 - **A 端 IP：** 192.168.31.57 - **B 端 IP：** 192.168.31.18 - **A2A token (A→B)：** `5ff5b9c0` - **A2A token (B→A)：** `392773ad...` - **OpenClaw 版本：** 2026.5.7 (eeef486) [score=0.950 recalls=12 avg=1.000 source=memory/2026-05-09.md:63-100]
<!-- openclaw-memory-promotion:memory:memory/2026-04-08.md:1:44 -->
- # 2026-04-08 開發日誌 ## 📅 日期 2026 年 4 月 8 日 ## 🎯 主要任務 ### 1. A2A 基礎架構建設 ✅ 完成 - [x] A2A 協議安裝規劃與環境探測 - [x] 雙端 HTTP 通訊隧道建立 (Windows 11 ↔ Ubuntu) - [x] Samba 共享服務部署 - [x] 技術文檔撰寫 (`A2A_Deployment_Guide.md`) ### 2. Ubuntu 端 API 開發 ✅ 完成 - [x] `execute.js` API 實作 - 簡單 API Key 驗證 - 系統命令執行 (SSH/Exec) - 命令白名單機制 - 錯誤處理與日誌記錄 - [x] 配置檔案 (`server.conf`) - [x] 使用說明書 (`README.md`) ### 3. 測試工具開發 ✅ 完成 - [x] PowerShell 測試模組 (`test_a2a_api.psm1`) - [x] 命令測試腳本 (`test_a2a_command.ps1`) ### 4. 系統升級 ✅ 完成 - [x] OpenClaw 升級至 2026.4.8 - [x] 新手使用手冊撰寫 (`openclaw_新手使用手冊.md`) - [x] 系統狀態檢查 ### 5. 文件管理 ✅ 完成 - [x] 架構報告 (`A2A_Dual_End_Architecture.md`) - [x] 開發進度追蹤 (`A2A_Dev_Progress.md`) - [x] Samba 任務失敗分析 (`Samba_Task_Failure_Analysis.md`) - [x] Samba 測試報告 (`Samba_Share_Test_Report.md`) ## 📊 系統狀態 | 項目 | 狀態 | 備註 | |------|------|------| | A2A HTTP 通訊 | ✅ 正常 | 連線穩定 ~50ms | | execute.js API | ✅ 開發完成 | 待服務啟動測試 | | Samba 共享 | ❌ 放棄 | 轉向 API 指令下發方案 | [score=0.920 recalls=11 avg=0.995 source=memory/2026-04-08.md:1-44]
<!-- openclaw-memory-promotion:memory:memory/2026-04-06.md:107:172 -->
- "ollama:default": { "provider": "ollama", "mode": "api_key" } } }, "messages": { "ackReactionScope": "group-mentions" }, "meta": { "lastTouchedVersion": "2026.4.2", "lastTouchedAt": "2026-04-05T13:00:11.697Z" }, "wizard": { "lastRunAt": "2026-04-05T07:39:55.054Z", "lastRunVersion": "2026.4.2", "lastRunCommand": "doctor", "lastRunMode": "local" }, "session": { "dmScope": "per-channel-peer" }, "tools": { "profile": "coding" }, "hooks": { "internal": { "enabled": true, "entries": { "session-memory": { "enabled": true } } } } } ``` ### 🎯 **成功驗證的配置要點** 1. **CORS 配置**: `"allowedOrigins": ["*"]` - 允許所有來源（適合開發測試） 2. **網路綁定**: `"bind": "lan"` - 綁定到局域網，允許跨網段訪問 3. **安全認證**: Bearer Token 認證已啟用 4. **跨網段訪問**: ✅ A 端（Ubuntu 機器）成功訪問 B 端 WebUI ### ✅ **已解決的問題** - [x] 跨網段/跨機器訪問 - [x] CORS 配置限制問題 - [x] Bearer Token 認證配置 ### 📝 **配置備份位置** - **Windows**: `C:\Users\48856\.openclaw\openclaw.json` - **Ubuntu**: `/home/ubuntu/.openclaw/openclaw.json` ### 🔐 **安全令牌**（重要！） ``` Token: [REDACTED] ``` **⚠️ 注意**: 請妥善保存此令牌，用於對等節點認證。 ### 🚀 **下一步建議** [score=0.914 recalls=8 avg=0.919 source=memory/2026-04-06.md:107-172]
<!-- openclaw-memory-promotion:memory:memory/2026-04-05.md:1:47 -->
- ## 📚 A2A 网关插件中文帮助文档 ### 简介 `@win4r/openclaw-a2a-gateway` 是一个生产级的 OpenClaw 插件，实现了谷歌的 A2A (Agent-to-Agent) v0.3.0 协议，使 OpenClaw Agent 能够发现和跨服务器相互通信。 ### 🎯 核心特性 - **三种传输协议**：JSON-RPC → REST → gRPC（自动回退） - **自动对等发现**：mDNS 自广告 + DNS-SD 发现 - **智能路由**：基于技能、标签、消息模式的 Hill 方程亲和力评分 - **实时流式传输**：SSE 流式传输 + heartbeat 心跳保活 - **全类型支持**：TextPart, FilePart (URI + base64), DataPart - **安全特性**：Bearer Token 认证、SSRF 保护、Ed25519 设备身份 - **审计追踪**：JSONL 格式记录所有 A2A 调用和安全事件 - **遥测指标**：可选的 bearer 认证指标端点 ### 📦 安装 ```bash # 安装插件 openclaw plugins install @win4r/openclaw-a2a-gateway # 或者从 git openclaw plugins install git+ssh://git@github.com/win4r/openclaw-a2a-gateway.git # 重载插件 openclaw plugins reload ``` ### 🚀 零配置启动 插件自带合理的默认值，安装后即可直接使用！ 自动启动的服务： - A2A 监听端口（默认 18800） - mDNS 广播（每 60 秒） - DNS-SD 服务发现 ### ⚙️ 配置选项 配置文件示例（根据需要编辑）： ```json { "a2a": { "port": 18800, // A2A 服务端口 [score=0.901 recalls=12 avg=1.000 source=memory/2026-04-05.md:1-47]
<!-- openclaw-memory-promotion:memory:memory/2026-04-05.md:138:203 -->
- # 健康检查 curl http://localhost:18800/health # 测试 A2A 调用 curl -X POST http://localhost:18800/execute \ -H "Content-Type: application/json" \ -H "Authorization: Bearer your-token" \ -d '{ "messageId": "test-001", "agentId": "test-agent", "message": { "text": "Hello from A2A!" } }' ``` ### 🎯 高级功能 #### 技能路由 插件会自动提取健康检查期间的 Agent Card 技能，用于智能路由： ``` [OpenClaw Server A] → [Agent: AGI] → [基于技能路由] → [OpenClaw Server B] → [Agent: Coco] ``` #### 规则路由 基于消息模式、标签或对等方技能自动选择最佳路由： ```json { "rules": [ { "pattern": "code.*python", "tags": ["coding", "python"], "peer": "python-specialist" } ] } ``` #### 推播通知 Webhook 推播，带信号衰减重要性管理和衰减感知重试： ```json { "delivery": { "mode": "webhook", "to": "https://example.com/webhook", "bestEffort": true } } ``` ### 🛡️ 安全特性 - **SSRF 保护**：URI 主机名白名单、MIME 白名单、文件大小限制 - **认证**：Bearer Token 多 Token 零停机旋转 - **设备身份**：Ed25519 用于 OpenClaw ≥2026.3.13 范围兼容性 - **审计**：所有 A2A 调用和安全事件的 JSONL 审计追踪 ### ⚙️ 性能优化 - **Michaelis-Menten 软并发**：渐进延迟而非突然拒绝 [score=0.874 recalls=9 avg=0.663 source=memory/2026-04-05.md:138-203]
