# OpenClaw V2026.5.x ~ V2026.6.x 维护深度笔记

> 士兵长整理 | 2026-06-02
> 当前版本：2026.5.28 | 最新可用：2026.6.1-beta.1

---

## 一、架构级变更（影响运维）

### 1.1 存储：全量 SQLite 迁移

**核心变化：**
- 通道入站队列 → SQLite
- 插件安装索引 → SQLite
- iMessage 监控状态 → SQLite
- 旧版文件系统轮询已被取代

**对 A 端影响：**
- 数据目录结构可能变化，旧版 `*.json` 文件可能被归档
- 重启恢复速度提升（减少文件扫描）
- SQLite 数据库文件位置：通常在 OpenClaw 数据目录 `data/` 下

**维护要点：**
- 备份时需额外关注 SQLite DB 文件（不只是 JSON）
- 恢复后检查 `openclaw status --deep` 确认通道状态

### 1.2 Rastermill 替换 Sharp

**核心变化：**
- Sharp（C++ 原生依赖，体积大，安装困难）→ Rastermill（纯 Rust，零原生依赖）
- Sharp 依赖已从 package manifest 中移除

**对 A 端影响：**
- ✅ 正面：包体积更小，安装更稳定
- Windows 上不再需要 Visual C++ Redistributable

### 1.3 插件系统升级

**新插件：**
| 插件名 | 包名 | 用途 |
|--------|------|------|
| GitHub Copilot | `@openclaw/copilot` | GitHub Copilot agent runtime |
| Tokenjuice | `@openclaw/tokenjuice` | Token 管理 |
| Pixverse | 外部插件 | 视频生成 |

**安装方式：**
```bash
openclaw plugins install @openclaw/copilot
openclaw plugins install @openclaw/tokenjuice
```

**SecretRef 契约：**
- 插件清单新增 SecretRef 提供者集成
- Secret 密文管理通过 SecretRef 统一处理
- 旧版环境变量方式仍兼容

---

## 二、Cron 系统重大变更

### 2.1 并发度提升

- 默认并发数：**1 → 8**
- 影响：大量 cron job 可同时运行
- 注意：如果之前有资源竞争问题，可能需要限流

### 2.2 瞬态模型限流重试

- 重试策略：发生瞬态 rate limit 后，不等下一调度轮，直接重试
- 预检模型可用性：跳过前预检，避免无效调度

### 2.3 维护影响

```bash
# 查看当前 cron 配置
openclaw cron list

# 检查是否有失败的 cron
openclaw cron status
```

**旧版 cron job（payload 格式不兼容）仍保留但不可运行** — 升级后需重新创建。

---

## 三、内存（Memory）系统变更

### 3.1 本地 Embedding 隔离

- 本地 GGUF embedding 运行在 **独立 worker sidecar** 中
- Worker 崩溃不会拖垮 Gateway（降级到 fallback 或 keyword search）

**维护要点：**
- embedding worker 崩溃现在可隔离处理，不影响主服务
- 检查 Gateway 日志中的 embedding worker 状态

### 3.2 REM Dreaming 优化

- Dreaming 现在只关注 **live light-staged memories**
- 旧 recall history 不再主导新候选
- 已考虑的条目被标记，避免重复

### 3.3 Memory Wiki

- Wiki lint 工具输出现在报相对路径
- 目录碰撞错误包含原始错误码

---

## 四、通信通道变更

### 4.1 Telegram

- ✅ 入站 bold/italic/code/strikethrough 等格式保留为 markdown
- ✅ 论坛主题不再阻塞兄弟主题流量
- ✅ 死信处理：被毒化的消息不再阻塞后续消息
- ✅ 发送日志包含完整元数据（account/chat/message/thread 等）

### 4.2 Discord

- ✅ 语音消息：实时会话旋转，不报错
- ✅ 模糊 wake-name 支持更广（"Open Club" → OpenClaw）
- ✅ 流式字幕合并到媒体回复

### 4.3 WhatsApp

- ✅ Baileys 更新至 `7.0.0-rc13`
- ✅ auth 目录从 active profile 解析（profile 隔离）
- ✅ `forceDocument` 保留原始媒体字节
- ✅ 拒绝 symlinked credentials 文件（安全加固）

### 4.4 Android/iOS 移动端

- **Android：** Talk Mode 实时 Gateway relay（流式语音 + 工具结果桥接 + 屏幕实时字幕）
- **iOS：** iPad 布局、托管推送中继、实时 Talk 回放、WebSocket 保活

### 4.5 QQBot

- ✅ 回复 watchdog 基于 agent/provider 超时动态调整（不再硬编码 5 分钟）

---

## 五、Provider 覆盖扩展

### 5.1 新增 Provider

| Provider | 说明 |
|----------|------|
| **MiniMax M3** | 最新模型支持，流式音乐生成响应 |
| **Claude Opus 4.8** | 支持 |
| **Fal Krea** | 图像模型 schemas |
| **NVIDIA featured** | 模型目录 |
| **OpenAI 兼容 embedding** | 本地/托管端点 |

### 5.2 OpenRouter SQLite 缓存

- 模型列表使用 SQLite 缓存，启动更快
- 缓存跨重启持久化

### 5.3 DeepSeek

- ✅ `anyOf`/`oneOf` union schema 自动标准化
- ✅ `reasoning_content` 跨 tier replay 保留

### 5.4 Ollama（A 端核心）

- ✅ plain-text tool calls 被 promote（之前可能被忽略）
- ✅ 模型目录缓存自动启用
- ✅ 本地模型路由无变化

---

## 六、安全加固（重要）

### 6.1 SSRF 防护

- 浏览器工具：严格 tab URL allowlist 检查
- 拒绝无效 tab index、CDP port 0、非有限 viewport
- Teams 服务 URL 来源受限

### 6.2 Prompt 注入防护

- ✅ 插件清单模型模式正则使用 safe-regex 编译器
- ✅ transcript 元数据 field names 转义
- ✅ 不安全命令包装器拒绝

### 6.3 认证

- ✅ auth profiles 原子写入
- ✅ 强制重新登录恢复
- ✅ Codex 启动拒绝 Node/包管理器参数嵌入

### 6.4 审计

- `openclaw security audit` 现在 flag webhook token 复用 Gateway 密码的情况

---

## 七、性能优化（维护视角）

### 7.1 Hot-Path 缓存

| 项目 | 优化方式 |
|------|----------|
| 插件元数据 | 指纹缓存，不重复扫描 |
| 工具搜索目录 | 不变时复用 |
| 插件路径 | realpath 缓存 |
| 会话元数据 | 只读快照 |
| 模型目录 | auto-enabled 插件配置缓存 |
| Session 写入 | precomputed patch writers |
| Store 克隆 | 减少分配次数 |

### 7.2 启动优化

- ✅ 本地模型启动跳过不必要的插件发现
- ✅ provider auth 线程外预热
- ✅ 延迟 Slack 完全启动
- ✅ Windows 上不再重复解析文件系统

---

## 八、Workboard / Skill Workshop（新功能，值得了解）

### 8.1 Workboard

- 多 Agent 编排面板
- 跨 Agent 规划 + 任务追踪
- 任务驱动工作流 + 评论支持

**适合场景：** A↔B 协同、多 Agent 编排

### 8.2 Skill Workshop

- 技能提案系统（版本化 + 审批流程）
- Control UI 可视化面板
- 提案可修订、可回滚
- `skill_workshop` agent 工具：批准/拒绝/隔离

**适合场景：** A 端自定义技能管理

---

## 九、升级影响评估

### 9.1 从 2026.5.28 → 2026.6.1-beta.1

| 影响项 | 风险评估 | 说明 |
|--------|----------|------|
| **当前 Ollama 模型** | 🟢 无影响 | 模型管理不变 |
| **Cron jobs** | 🟡 中 | 并发度变 8，job 格式兼容 |
| **记忆系统** | 🟢 无影响 | 降级兼容 |
| **NAS 通讯协议** | 🟢 无影响 | b2a.md/a2b.md 通道不受影响 |
| **ComfyUI** | 🟢 无影响 | 独立服务 |
| **通道配置** | 🟢 兼容 | 旧格式自动迁移 |
| **插件索引** | 🟡 中 | SQLite 新格式 |
| **Gateway 配置** | 🟡 中 | 部分字段 hot-reload，部分需 restart |

### 9.2 升级前检查清单

1. `openclaw status` — 确认当前状态
2. `openclaw cron list` — 记录所有 cron jobs
3. `openclaw plugins list` — 记录已安装插件
4. 备份 `Z:\Obsidian_Vault\士兵长_记忆备份\`
5. 备份 OpenClaw 数据目录
6. 升级后检查 `openclaw status --deep`
7. 检查 cron jobs 是否正常运行
8. 检查各通道连接状态

### 9.3 升级命令

```bash
openclaw update
# 或指定 tag
openclaw update --tag v2026.6.1-beta.1
```

---

## 十、故障排查要点

### 10.1 常见新问题的排查方向

| 症状 | 可能原因 | 排查命令 |
|------|----------|----------|
| cron job 不执行 | payload 格式不兼容 | `openclaw cron get <jobId>` |
| 通道连接断开 | SQLite DB 损坏 | 检查 `openclaw status --deep` |
| embedding 失败 | worker sidecar 问题 | 检查 Gateway 日志 |
| 插件索引不更新 | SQLite 格式迁移 | `openclaw plugins list` |
| 配置不生效 | 需 restart 的字段 | `config.schema.lookup` 查询 |

### 10.2 日志位置

- Gateway 日志：OpenClaw 数据目录下的 logs
- 升级日志：`openclaw update` 输出

---

## 十一、对 B 端通讯协议的影响

| 项目 | 影响 |
|------|------|
| `a2b.md` / `b2a.md` 格式 | ✅ 无变化 |
| 编号 [Mnnn] | ✅ 无变化 |
| 500行/20KB 归档 | ✅ 无变化 |
| NAS 同步路径 | ✅ 无变化 |
| 备份 cron | ✅ 无变化 |

**结论：** B 端通讯协议完全不受影响。

---

*士兵长整理完毕。指挥官回来后可直接查看此文档。*
