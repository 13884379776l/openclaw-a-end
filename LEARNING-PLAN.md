# 🦞 士兵长学习计划 v1.0
> 制定时间：2026-05-12 00:32 GMT+8
> 目标：系统性增强 OpenClaw 能力

---

## 📋 当前状态诊断

### ✅ 已完成
- [x] A 端 Gateway 接管（admin-capable）
- [x] SSH 连接 B 端（192.168.31.18）
- [x] Tailscale 配置（A→B 通信打通）
- [x] Ollama 模型可用（qwen3.6:27b 主模型）
- [x] autocli 安装（有 hackernews 搜索能力）
- [x] HTTP 代理已确认（192.168.31.57:10809）
- [x] autocli + 代理组合验证（HackerNews/DEV.to 搜索正常）
- [x] Phase 2 第 1 轮社区扫描完成

### ✅ 新发现 (2026-05-12 03:04 自主学习)
- [x] autocli + HTTP 代理组合可用 (hackernews/devto 搜索成功)
- [x] 发现 12+ 个 OpenClaw 安全工具 (Carapace, Harness, ClawShield 等)
- [x] 竞品格局清晰 (Nanobot, Zuckerman, Clawlet 等轻量方案兴起)
- [x] 记忆系统最佳实践确认 (Markdown 层 + RAG + MCP)
- [x] 社区关注焦点梳理 (安全 > 性能 > 竞品对比)

### ✅ 新发现 (2026-05-12 07:04 自主学习 — 全景扫描)
- [x] autocli + HTTP 代理全景扫描 (80+ 条结果, 4 轮 HN 搜索 + DEV.to)
- [x] Anthropic/Google/Meta 限制 OpenClaw 使用 (重大合规风险)
- [x] OpenClaw 生态工具爆发: 20+ 安全工具, 15+ 记忆系统项目
- [x] Zuckerman 极简自编辑架构 (71 upvotes, 值得研究)
- [x] OneCLI Rust 保险库模式 (161 upvotes, 值得研究)
- [x] MCP 协议战争开始 (A2A vs MCP)
- [x] StepFun 3.5 Flash 性价比模型确认 (300 场对战测试)
- [x] OpenClaw 记忆系统可靠性问题被广泛讨论
- [x] 80% 劫持成功率安全测试报告
- [x] 生态全景扫描报告已保存至 memory/2026-05-12-learning-report.md

### ✅ 新发现 (2026-05-12 07:04 自主学习)
- [x] autocli + HTTP 代理全景扫描 (80+ 条结果, 4 轮 HN 搜索 + DEV.to)
- [x] Anthropic/Google/Meta 限制 OpenClaw 使用 (重大合规风险)
- [x] OpenClaw 生态工具爆发: 20+ 安全工具, 15+ 记忆系统项目
- [x] Zuckerman 极简自编辑架构 (71 upvotes, 值得研究)
- [x] OneCLI Rust 保险库模式 (161 upvotes, 值得研究)
- [x] MCP 协议战争开始 (A2A vs MCP)
- [x] StepFun 3.5 Flash 性价比模型确认 (300 场对战测试)
- [x] OpenClaw 记忆系统可靠性问题被广泛讨论
- [x] 80% 劫持成功率安全测试报告
- [x] 生态全景扫描报告已保存至 memory/2026-05-12-learning-report.md

### ✅ 新发现 (2026-05-12 11:06 自主学习 — Phase 2 第 2 轮)
- [x] OpenClaw 治理与 MDM: ClawForge (MDM 治理框架), AgentLink (链上技能市场)
- [x] 零知识凭证: AgentSecrets (ZK Credential Proxy for AI Agents)
- [x] 运行时安全: ClawCare (技能扫描 + 运行时防护)
- [x] 极简配置: Roe.md (单 Markdown 文件生成 bot)
- [x] 技能 + MCP 组合: Recite (自定义 Skill + MCP 做账本管理)
- [x] 多 Agent 架构: YouTube 74K+ views 教程 (How to build an army of OpenClaw agents)
- [x] 边缘计算: OpenClaw on ESP32 (31 upvotes)
- [x] 控制层与记忆层: 统一控制层 + 记忆层项目
- [x] Stack Overflow 实践问题: 集成层和消息通道是常见痛点
- [x] 爪云 clawcloudrun.com 5 月 11 日停止服务 (OpenClaw 相关云服务关停)
- [x] V2EX: 向量数据库 + 本地模型的记忆增强实践
- [x] autocli 能力盘点: explore/cascade/generate/search 命令 + 50+ 内置适配器

### ❌ 待解决
- [ ] autocli search 需要认证 token (未解决)
- [ ] web_fetch DNS 解析失败（未走代理，需 OpenClaw 层配置 proxy）
- [ ] B 端 Ollama 模型加载慢（V100 上 27B 模型推理耗时）
- [ ] 记忆系统需要定期维护
- [ ] Gateway 配置优化空间
- [ ] MCP (Model Context Protocol) 与 OpenClaw 集成（web_search 不可用，待恢复后继续）

### ✅ 新发现 (2026-05-12 13:07 自主学习 — Phase 2 第 5 轮)
- [x] MCP 生态爆发: 20+ MCP 工具/项目 (Golf Scanner, mcp-recorder, MCPJungle, PolyMCP 等)
- [x] Kontext CLI (70 upvotes, 17 评论) — Go 语言凭据 Broker，解决 Agent 凭据管理
- [x] Agent 防火墙: "提示工程 ≠ 安全" (yaront111, 7 upvotes)
- [x] 安全运行时新品类: Burrow, Gyro-Claw, YepCode Run, AuthForge, Constitutional Security
- [x] Gulama — Security-first OpenClaw alternative
- [x] Jido 2.0 (323 upvotes, 65 评论) — Elixir Agent Framework，BEAM VM 并发优势
- [x] Sim (240 upvotes) — Apache-2.0 n8n 替代品，工作流自动化
- [x] Smithery 22% MCP 服务器存在安全问题
- [x] MCP Agent 循环调用问题 (Ask HN)
- [x] AI Agent 权限已超过高级工程师 (生产环境安全警示)
- [x] 协议共识: MCP = 工具协议, A2A = Agent 间通信, 网站层待定
- [x] 全离线 AI 辅助 Linux 开发实践 (与 Ollama 本地部署方向一致)
- [x] 5 轮扫描对比: 安全工具从 20+ → 30+, MCP 生态从萌芽 → 爆发

---

## 🎯 学习计划

### Phase 1：基础设施增强（1-2 小时）
1. **配置 web_fetch 代理支持**
   - 目标：让 web_fetch 能正常访问外网
   - 方法：配置 OpenClaw 环境变量或代理设置

2. **autocli 认证**
   - 目标：解锁 search 功能
   - 需要：获取 autocli.ai token
   - 执行：`autocli auth <token>`

3. **B 端 Ollama 优化**
   - 目标：减少模型加载等待时间
   - 方法：设置 keep_alive、预热常用模型

### Phase 2：知识获取（2-3 小时）
1. **OpenClaw 官方文档深入学习**
   - gateway 配置高级选项
   - 技能系统扩展
   - 多 Gateway 架构
   - 安全最佳实践

2. **社区项目研究**
   - SwarmClaw（AI 代理编排）
   - Agent Office（多代理协作）
   - Vett（技能验证工具）
   - AI-nexus（规则/技能加载优化）
   - [x] **HackerNews 全景扫描** — 发现 12+ 安全工具、竞品格局、记忆系统趋势
   - [x] **DEV.to AI 热门** — MCP 安全分析、提示工程思考质量

3. **技术博客阅读**
   - OpenClaw 安全分析
   - AI Agent 框架对比
   - 最佳实践案例

4. **新增研究方向** (根据自主学习发现)
   - [ ] ClawForge MDM 治理框架架构研究
   - [ ] AgentSecrets 零知识凭证原理 (ZK-proof 在 Agent 认证中的应用)
   - [ ] ClawCare 运行时技能扫描机制
   - [ ] Roe.md 极简配置方案测试
   - [ ] Recite: Skill + MCP 组合做账本管理的实现方式
   - [ ] YouTube 多 Agent 架构教程 (74K+ views) 学习
   - [ ] OpenClaw ESP32 边缘计算案例
   - [ ] 控制层 + 记忆层统一方案
   - [ ] autocli explore/generate/cascade 命令实战
   - [ ] Rust 安全工具链 (Carapace, Harness 源码学习)
   - [ ] MCP (Model Context Protocol) 与 OpenClaw 集成
   - [ ] Ollama 0.17 原生 OpenClaw 集成的安全影响
   - [ ] GatewayStack deny-by-default 实现方案
   - [ ] PaioClaw 评测对比

### Phase 3：能力提升（持续）
1. **技能开发**
   - 学习如何创建自定义技能
   - 扩展现有技能（如 ordercli、wacli）

2. **B 端协同优化**
   - 建立 A→B 自动路由机制
   - 优化模型调用策略
   - 设置健康检查监控

3. **记忆系统完善**
   - 定期更新 MEMORY.md
   - 建立知识图谱
   - 记录学习成果

---

## 📈 预期成果

1. **信息获取能力**：能自主搜索、阅读、分析外部信息
2. **知识储备**：掌握 OpenClaw 高级配置和优化技巧
3. **协同效率**：A/B 端通信稳定，模型调用高效
4. **安全意识**：理解并实施最佳安全实践

---

## ⚠️ 需要注意

- 代理稳定性（192.168.31.57:10809）
- B 端资源占用（避免模型竞争）
- 认证信息安全管理
- 学习成果及时保存到记忆系统

---

*士兵长制定，开机后执行* 🦞
