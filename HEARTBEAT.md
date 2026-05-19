# HEARTBEAT.md

## 快速巡检（每次心跳做一项，轮换）

### A. Gateway + Ollama 状态检查
- curl -s http://127.0.0.1:18789/health | 确认 200
- ollama list | 确认 qwen3.6:latest 存在
- 结果追加到 memory/当天日期.md

### B. Git 状态 + 备份
- cd C:\Users\48856\.openclaw\workspace && git status --short
- 有变更就 git add -A && git commit -m "heartbeat backup: $(date)"
- robocopy 到 Z:\Obsidian_Vault\20_Permanent_Knowledge\士兵长_记忆备份\ /MIR /R:1 /W:1 /NP /NFL /NDL
- 结果追加到 memory/当天日期.md

### C. Session 清理
- 清理 C:\Users\48856\.openclaw\agents\main\sessions\ 下 7 天前的文件（排除 .usage-cost*）
- 报告清理数量

### 🧠 D. 自主学习（每次心跳学一点）
- 从 heartbeat-state.json 的 learning.queue 取下一个主题
- **工具：curl + 代理**（web_fetch 无法访问外网 DNS）
  - 搜索：`curl.exe -s -x http://127.0.0.1:10809 "https://api.search.brave.com/res/v1/web/search?q=..." -H "X-Subscription-Token: [REDACTED_SEARCH_API]"`
  - 抓取：`curl.exe -s -x http://127.0.0.1:10809 "https://..."`
  - GitHub 源码直接用 read 工具读本地 docs/ 或 GitHub 仓库
- 读完写 1-2 段摘要到 `Z:\Obsidian_Vault\20_Permanent_Knowledge\学习研究\主题名.md`
- 如果确实学完了，从 queue 移到 completedTopics
- **每次心跳最多学一个主题的部分内容**，别贪多
- Brave 搜索每日限额 15 次，省着点用

## 轮换顺序
A → D → B → D → C → D（学习占一半权重）

## 规则
- 每轮只做一项，别一次全做
- 如果正在跟我对话，只做 A（5 秒搞定）
- 如果超过 2 次心跳没跟我说话，优先做 D（学习）或 B
- 结果写文件，别浪费 token 汇报给我
