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
