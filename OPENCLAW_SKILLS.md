# OpenClaw 技能系统整理

## 🎯 技能系统简介

OpenClaw 的技能系统（AgentSkills）是一种模块化、可扩展的工具生态系统，允许为特定任务创建可复用的自动化能力。

## 📦 核心技能列表

### 1. healthcheck - 主机安全检查

**用途：**
- 主机安全加固
- 风险容忍度配置
- 防火墙/SSH/更新加固
- 风险态势审查
- 暴露审查
- OpenClaw 定时任务调度
- 版本状态检查

**适用场景：**
- 定期检查系统健康状态
- 安全审计
- 风险评估报告

**使用方式：**
```bash
openclaw healthcheck
```

### 2. node-connect - 节点连接诊断

**用途：**
- 诊断 OpenClaw 节点连接问题
- 解决配对失败问题
- 排查 Tailscale 配置

**适用场景：**
- Android/iOS/macOS  Companion App 连接失败
- QR 码/手动配对失败
- 本地 Wi-Fi 正常但 VPS/tailnet 无法连接

**诊断内容：**
- 配对错误
- 授权失败
- bootstrap token 失效
- gateway.bind 配置
- Tailscale 配置

### 3. oracle - Oracle CLI 最佳实践

**用途：**
- Prompt + 文件打包
- 引擎管理
- 会话管理
- 文件附件模式

**适用场景：**
- 复杂问题咨询
- 文档生成
- 数据分析任务

### 4. session-logs - 会话日志分析

**用途：**
- 搜索和分析会话日志
- 使用 jq 工具处理日志数据
- 调试历史记录

**适用场景：**
- 排查问题
- 审计会话历史
- 性能分析

### 5. skill-creator - 技能创建工具

**用途：**
- 创建新的 AgentSkill
- 编辑现有技能
- 改进现有技能
- 审查和审计技能
- 清理技能目录
- 验证技能配置

**适用场景：**
- 从零创建技能
- 优化现有技能
- 重构技能代码

### 6. video-frames - 视频帧提取

**用途：**
- 使用 ffmpeg 提取视频帧
- 截取短视频片段

**适用场景：**
- 视频分析
- 关键帧提取
- 屏幕录制片段

### 7. weather - 天气查询

**用途：**
- 通过 wttr.in 查询天气
- 通过 Open-Meteo 查询天气
- 获取天气预报

**适用场景：**
- 当前天气查询
- 短期天气预报
- 户外活动建议

**限制：**
- 不支持历史天气数据
- 不支持严重天气警报
- 不支持详细气象分析

## 🛠️ Web 搜索技能

### 支持的搜索引擎

| 提供商 | 特点 | API 密钥 |
|--------|------|---------|
| Brave Search | 结构化结果，支持 LLM context | BRAVE_API_KEY |
| DuckDuckGo | 免密钥备用方案 | 无需密钥 |
| Exa | 神经搜索 + 内容提取 | EXA_API_KEY |
| Firecrawl | 结构化结果，深度提取 | FIRECRAWL_API_KEY |
| Gemini | AI 综合答案，Google 引用 | GEMINI_API_KEY |
| Grok | AI 综合答案，xAI 引用 | XAI_API_KEY |
| Kimi | AI 综合答案，Moonshot 引用 | KIMI_API_KEY |
| MiniMax | 结构化结果 | MINIMAX_API_KEY |
| Ollama Web Search | 免密钥 | ollama signin |
| Perplexity | 结构化结果，域过滤 | PERPLEXITY_API_KEY |
| SearXNG | 自托管元搜索 | 无需密钥 |
| Tavily | 结构化结果，内容提取 | TAVILY_API_KEY |

### 自动检测顺序

1. API 提供商：Brave → MiniMax → Gemini → Grok → Kimi → Perplexity → Firecrawl → Exa → Tavily
2. 免密钥备用：DuckDuckGo → Ollama Web Search

## 📁 文件操作工具

### read() - 读取文件
- 支持文本文件
- 支持图像（jpg, png, gif, webp）
- 输出限制：2000 行或 50KB

### write() - 写入文件
- 自动创建父目录
- 覆盖现有文件

### edit() - 编辑文件
- 精确文本替换
- 支持多区域编辑
- 不支持重叠编辑

### exec() - 执行命令
- 支持背景进程
- 支持超时控制
- 支持环境变量

## 🔧 本地工具配置

### 摄像头
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- 首选语音："Nova"（温暖，略偏英音）
- 默认扬声器：Kitchen HomePod

### 设备别名
- 自定义设备昵称
- 房间/扬声器名称

## 🎨 技能目录结构

```
skills/
├── healthcheck/       # 主机检查技能
├── node-connect/      # 节点连接诊断技能
├── oracle/            # Oracle CLI 技能
├── session-logs/      # 会话日志分析技能
├── skill-creator/     # 技能创建工具
├── video-frames/      # 视频帧提取技能
├── weather/           # 天气查询技能
└── references/        # 技能引用/资源
    └── scripts/       # 脚本文件
```

## 💡 最佳实践

### 技能创建
1. 明确技能用途
2. 编写清晰的 SKILL.md 文档
3. 定义准确的工具参数
4. 设置合适的权限

### 技能管理
- 定期审查技能文件
- 移除过时技能
- 保持目录整洁

### 技能安全
- 避免在技能中硬编码敏感信息
- 使用环境变量管理密钥
- 限制技能的网络访问范围

## 🚀 扩展技能

OpenClaw 允许用户：
- 创建自定义技能
- 扩展现有技能
- 组合多个技能
- 分享技能到社区

## 🔗 相关链接

- OpenClaw 官方文档：https://docs.openclaw.ai
- 技能中心：https://clawhub.ai
- Discord 社区：https://discord.com/invite/clawd

## 📝 当前配置

**已启用的技能：**
- ✅ web_search (DuckDuckGo 备用)
- ✅ web_fetch (轻量 URL 抓取)
- ✅ 文件读写工具
- ✅ 系统命令执行

**配置路径：** `C:\Users\48856\.openclaw\openclaw.json`

---

**总结：** OpenClaw 的技能系统确实非常强大，通过模块化设计，可以轻松创建和扩展自动化能力。
