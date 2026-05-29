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
