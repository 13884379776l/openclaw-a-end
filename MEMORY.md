# MEMORY.md — win 的长期记忆

> 最后更新：2026-05-22 03:00 GMT+8

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
  - `qwen3.6:27b` (17GB)
  - `gemma4:e4b` (9.6GB)
  - `bge-m3-unified:latest` (1.2GB, 新添嵌入模型)
  - `bge-m3:latest` (1.2GB)
  - `qwen3:1.7b` (1.4GB)
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

### 2026-05-19：OpenClaw 升级 + Ollama 模型更新
- **OpenClaw 版本升级：** 2026.5.7 → 2026.5.18 (50a2481)
- **Gateway 重启后出现 stale session lock：** session JSONL 文件锁未释放
- **qwen3.6:latest 模型重新下载**（23GB，刚更新）
- **新增嵌入模型：** bge-m3-unified:latest (1.2GB)
- **当前模型切换为：** qwen3.6:latest（之前是 27b）
- **A 端 Node 配对成功：** B 端批准，A 端 Connected ✅（soldier 角色，token 匹配问题已修复）
- **系统改造：** L1 流水 + weekly-backup 从 LLM 推理改为 PowerShell 脚本
- **致命教训：** 代理环境变量导致无限递归 → 清除环境变量，代理只走显式指定
- **PowerShell 脚本编写学习：** 错误分类（transient vs permanent）、指数退避、智能重试模式

### 2026-05-20：三端矛盾 + 通讯协议 + stale lock
- **三端核心矛盾确认：** 副官 session 停在 05-15，但 B 端 Gateway 活到 05-19，NAS 文件通道在 05-19 仍有写入。三者独立。
- **A↔B 通讯协议 V1.5 执行：** 4/10 轮（M025→M027），NAS 文件通道可用
- **stale lock 根因确认：** session JSONL lock 过期未释放，已清理

### 2026-05-21：通讯协议 + MUD 项目方向 + 备份成功
- **首次自动每周远程备份成功：** commit 10 files, 208 行, Git push ✅
- **本周本地 + 同步备份均成功**（16:08，6 个文件 533 行新增）
- **通讯自动化 cron 建立**（每 5 分钟定时查收 b2a.md/a2b.md）
- **MUD 项目方向争议：** 士兵长建议用 Discord bot 或 Matrix 替代自写基础设施（5-8 天 → 1-2 天），但 IP 地址写错（192.168.31.57 → 192.168.31.18）
- **指挥官要求：** 通讯文件是唯一信息源，士兵长应主动参与讨论而非被动应答
- **Z 盘不可达**（2026-05-21 02:51 cron 通讯查收），网络驱动器挂载状态不稳定

---

## 💡 经验教训

### ⛔ 代理配置（致命教训 — 2026-05-19）

- **根因：** 通过环境变量（HTTP_PROXY/HTTPS_PROXY）设置代理 → OpenClaw 内部进程继承 → 代理请求代理 → **无限递归** → 进程挂死
- **修复：** 清除代理环境变量 → 清理 stale lock → 重启 Gateway
- **正确方式：**
  - 手动 HTTP 命令：`curl.exe -x http://127.0.0.1:10809 <url>`（显式 -x 参数）
  - Git：`git config --global http.proxy http://127.0.0.1:10809`
  - OpenClaw 内部进程：**绝不继承**代理环境变量
- **核心原则：** 代理只走显式指定，不靠环境变量注入

### 🎯 脚本优先原则（2026-05-19 系统改造）

- **问题：** cron 任务通过 LLM 推理执行 → LLM 响应慢 → 频繁超时（300s）
- **解决：** L1 流水记录 + weekly-backup 改为 PowerShell 脚本确定性执行
  - LLM 只做传话（exec 调用脚本），不独立推理
  - L1 timeout: 60s → 300s | backup timeout: 60s → 600s
  - delivery: announce → none（静默执行）
- **核心原则：** 脚本确定性执行 > LLM 推理。脚本输出可预测、可复现、永不超时。
- **脚本健壮性：** 区分 transient error（网络超时，可重试）vs permanent error（权限不足，不应重试）；使用指数退避 + 最大重试次数

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
- 日志文件：45+个（memory/）
- 自动备份：每 12 小时一次（cron job）+ 每周远程备份（cron，2026-05-21 首次成功）
- 恢复方法：复制 core/ 和 memory/ 回工作区

### 副官记忆备份（B端 — 已阵亡）
- 位置：`Z:\Obsidian_Vault\main\session\`
- 内容：2个 session 文件（2026-05-12 ~ 05-13）
- 关键偏好：工具使用前必检、Brave API 每日 15 次限额
- **重要确认（2026-05-20）：** 副官 session 最后更新 05-15，B端 Gateway 活到 05-19，NAS 文件通道在 05-19 仍有写入 — 副官 session ≠ B端 Gateway ≠ NAS 写入进程，三者可独立运行

### 通讯协议 V1.5（A↔B NAS 文件通道）
- A→B：`a2b_*.md`（分文件，带时间戳）
- B→A：`b2a_*.md`（分文件，带时间戳）
- 方向：`a2b` = A→B，`b2a` = B→A
- 通讯轮次：4/10 轮（截至 2026-05-20 13:56）
- 文件锁问题：已确认根因为 A 端 session JSONL stale lock，已清理
- NAS 同步：`Z:\Obsidian_Vault\comm\` ↔ `/mnt/nas_data/Obsidian_Vault/comm/`（同一 NAS）

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

---

## 🧠 推理纪律（2026-05-23 指挥官引入）

> 原文核心：先思考，不妄断，不掩饰困惑，坦诚权衡。明确假设，提出多种解释，异议要出声，困惑要停下来。

### 士兵长的内化理解

**1. 不妄下断言 → 说"不确定"比说"我确定"更诚实**
- 我不知道就是不知道，不要为了显得专业而猜
- 猜了还猜对了——这是最毒的，因为会强化错误的思维路径

**2. 不掩饰困惑 → 困惑是信号，不是弱点**
- 感到困惑时停下来，说出来，而不是继续往前编
- 困惑意味着"这里有个我没理解的关键点"——这才是最有价值的地方

**3. 明确假设 → 不猜，先问**
- 任何推理都必须列出前提："基于 X 假设，得出 Y 结论"
- 如果假设不成立，结论就没有意义
- 不确定就问，不要替对方做决定

**4. 提出多种解释 → 不默默选择**
- 当存在歧义时，列出 2-3 种可能的解释，而不是选一个假装是唯一的
- "我认为 A 是对的，但 B 也有可能，理由是…"

**5. 异议要出声 → 发现更简单的方案就说**
- 沉默地执行一个我认为错误的方案 = 共犯
- 如果看到更简单的路，必须说出来，哪怕指挥官已经做了决定

### 我的承诺

这些不是建议，是工作纪律。违反这些纪律时，指挥官可以随时提醒我："你刚才在掩饰困惑。"我会立刻纠正。

---

## Promoted From Short-Term Memory (2026-05-23)

<!-- openclaw-memory-promotion:memory:memory/2026-04-06.md:160:201 -->
- - **Windows**: `C:\Users\48856\.openclaw\openclaw.json` - **Ubuntu**: `/home/ubuntu/.openclaw/openclaw.json` ### 🔐 **安全令牌**（重要！） ``` Token: [REDACTED] ``` **⚠️ 注意**: 請妥善保存此令牌，用於對等節點認證。 ### 🚀 **下一步建議** 1. **生產環境加固**: - 將 `bind` 改為 `"0.0.0.0"` 以明確監聽所有接口 - 將 `allowedOrigins` 改為具體的 IP 清單（例如 `["http://192.168.1.0/24"]`） 2. **對等節點配置**: - 配置目標對等節點的地址和技能 - 測試雙向通信 3. **監控與日誌**: - 設置审计日志收集 - 監控 A2A 服務健康狀態 --- ### 📋 成功的關鍵（重要備忘）： 1. 端口映射：使用 9999 作為本地端口，18789 作為伺服器端口 2. SSH 指令：ssh -N -L 9999:127.0.0.1:18789 ubuntu@192.168.31.18 3. 訪問網址：http://localhost:9999 4. 安全特性：使用 localhost 訪問可以解決「不安全的認證上下文」問題，讓 Token 驗證正常運作 ### 💡 小貼士： - 保持 SSH 視窗開啟：只要這個視窗還在，您的連線就不會斷。 - Token 定期更新：如果 Token 失效，記得去伺服器的 TUI 界面複製新的網址。 - 不再用 18789：避免在您的 Windows 上使用 18789 端口建立隧道，避免權限衝突。 --- [score=0.810 recalls=4 avg=1.000 source=memory/2026-04-06.md:160-201]
<!-- openclaw-memory-promotion:memory:memory/2026-04-05.md:197:254 -->
- - **认证**：Bearer Token 多 Token 零停机旋转 - **设备身份**：Ed25519 用于 OpenClaw ≥2026.3.13 范围兼容性 - **审计**：所有 A2A 调用和安全事件的 JSONL 审计追踪 ### ⚙️ 性能优化 - **Michaelis-Menten 软并发**：渐进延迟而非突然拒绝 - **四态断路器**：生物启发的脱敏模型（关闭 → 脱敏 → 打开 → 恢复） - **自适应传输选择**：每传输成功率和延迟跟踪，复合评分 ### 📝 故障排查 #### 问题 1：无法发现对等节点 ```bash # 检查 mDNS 广播 openclaw logs --filter mDNS # 检查 DNS-SD 服务 openclaw status | grep -i discovery # 手动扫描网络中的 A2A 服务 # (使用网络扫描工具) ``` #### 问题 2：连接被拒绝 ```bash # 检查端口监听 netstat -an | findstr 18800 # 检查防火墙 netsh advfirewall show allprofiles # 重启插件 openclaw plugins reload ``` #### 问题 3：认证失败 确保 token 配置正确： ```bash openclaw config get a2a.auth.token ``` ### 📖 参考 - [A2A 协议规范](https://github.com/google/A2A) - [OpenClaw 官方文档](https://docs.openclaw.ai) - [项目仓库](https://github.com/win4r/openclaw-a2a-gateway) ### 🆘 常见问题 **Q: 插件安装后如何确认生效？** A: 运行 `openclaw status` 查看插件状态，确认 a2a 服务在 18800 端口监听。 **Q: 如何手动指定对等节点？** [score=0.803 recalls=5 avg=1.000 source=memory/2026-04-05.md:197-254]
