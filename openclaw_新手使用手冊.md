# 📘 OpenClaw 新手使用手冊

> **版本**: 2026.4.8  
> **適合對象**: 電腦小白、新手用戶  
> **目標**: 讓您在 15 分鐘內掌握 OpenClaw 的所有基礎功能！

---

## 📖 目錄

1. [什麼是 OpenClaw？](#什麼是-openclaw)
2. [安裝與啟動](#安裝與啟動)
3. [基本操作](#基本操作)
4. [常見問題解決](#常見問題解決)
5. [進階功能簡介](#進階功能簡介)

---

## 🤔 什麼是 OpenClaw？

OpenClaw 是一個**AI 助手工具**，它可以：

- ✅ 幫助您管理電腦檔案
- ✅ 協助您執行系統指令
- ✅ 協助您監控硬體狀態
- ✅ 自動執行重複性工作

**簡單來說**：它就像您的私人數位助理，24 小時為您服務！

---

## 🚀 安裝與啟動

### 第一步：檢查是否已安裝

打開命令提示字元（按下 `Win + R`，輸入 `cmd`，按 Enter）：

```bash
openclaw --version
```

**如果看到類似**：
```
OpenClaw 2026.4.8 (9ece252)
```

→ **恭喜！您已經安裝成功了！** ✅

**如果看到「找不到命令」**：
→ 請聯絡您的系統管理員重新安裝（這部分先跳過，我假設您已經安裝好了）

### 第二步：檢查系統狀態

執行以下命令：

```bash
openclaw status
```

**您會看到類似這樣的輸出**：

```
┌─────────────────────────────────────────────┐
│ OpenClaw System Status                       │
├─────────────────────────────────────────────┤
│ 版本：2026.4.8                               │
│ Git Commit: 9ece252                          │
│ 運行中：是                                    │
│ 連接狀態：正常                                │
│ 記憶體使用：15%                               │
│ 磁碟空間：充足                                │
└─────────────────────────────────────────────┘
```

**說明**：
- **版本**：當前 OpenClaw 的版本號
- **運行中**：OpenClaw 是否正在運作
- **連接狀態**：系統是否連接到網路

如果一切都顯示「正常」，恭喜！您已經成功啟動了！

### 第三步：更新 OpenClaw（如果必要）

如果您的版本較舊，可以執行以下命令進行更新：

```bash
npm update
```

**注意事項**：
- 更新可能需要一些時間（30 秒到 3 分鐘）
- 請保持網路連線
- 更新過程中不要關閉命令視窗
- 更新完成後會看到「已更新 xxx 個套件」

---

## 💡 基本操作

### 1. 查看版本

```bash
openclaw --version
```

**用途**：檢查您安裝的是哪個版本的 OpenClaw。

### 2. 查看系統狀態

```bash
openclaw status
```

**用途**：查看 OpenClaw 是否運行正常。

### 3. 獲取幫助資訊

```bash
openclaw help
```

**用途**：列出所有可用的命令和說明。

### 4. 查看更新日誌

```bash
openclaw log
```

**用途**：查看 OpenClaw 的運行日誌，排查問題。

### 5. 停止 OpenClaw（如果需要）

```bash
openclaw stop
```

**用途**：關閉 OpenClaw 服務。

**注意事項**：
- 停用後，下次執行 `openclaw status` 會顯示「已停止」
- 需要重新啟動才能恢復功能
- 停用前請確保沒有重要的工作進行

### 6. 重新啟動 OpenClaw

```bash
openclaw restart
```

**用途**：如果 OpenClaw 出現問題，重新啟動通常可以解決。

---

## 🛠️ 常見問題解決

### Q1：打開命令提示字元時，顯示「找不到命令」

**問題**：
```
'openclaw' 不是內部或外部命令...
```

**解決方案**：

1. 重新啟動電腦
2. 檢查環境變數是否設定正確
3. 重新安裝 OpenClaw：

```bash
npm install openclaw -g
```

4. 如果還是無法執行，請聯絡您的系統管理員。

### Q2：執行 `openclaw status` 時出現錯誤

**錯誤訊息**：
```
TypeError: Cannot read property 'status' of undefined
```

**解決方案**：

1. 重新啟動 OpenClaw：

```bash
openclaw restart
```

2. 檢查網路連線是否正常
3. 檢查是否有足夠的磁碟空間

### Q3：OpenClaw 卡住或無響應

**解決方案**：

1. 打開任務管理員（`Ctrl + Shift + Esc`）
2. 找到 `openclaw` 或 `node` 進程
3. 點擊「結束任務」
4. 執行 `openclaw restart` 重新啟動

### Q4：如何檢查 OpenClaw 佔用了多少資源？

**方法 1**：使用任務管理員

1. 按下 `Ctrl + Shift + Esc` 打開任務管理員
2. 切換到「效能」標籤
3. 查看 CPU、記憶體使用情況

**方法 2**：使用命令提示字元

```bash
wsl --status
```

（如果安裝了 WSL）

### Q5：OpenClaw 日誌在哪裡？

**日誌位置**：

- 主要日誌：`C:\Users\<您的使用者帳號>\.openclaw\workspace\`
- 系統日誌：`C:\Users\<您的使用者帳號>\AppData\Roaming\npm\node_modules\openclaw\`

**查看日誌**：

```bash
type C:\Users\<您的使用者帳號>\.openclaw\workspace\*.log
```

（將 `<您的使用者帳號>` 替換為您的實際使用者名稱，例如 `48856`）

---

## 🎓 進階功能簡介

### 1. 管理 Cron 工作（定期任務）

OpenClaw 可以設定定期執行的工作，例如每天備份、每週整理檔案等。

**基本用法**：

```bash
# 列出所有已設定的工作
openclaw cron list

# 新增一個定期工作
openclaw cron add --daily "備份資料" "backup.sh"

# 刪除一個工作
openclaw cron remove --id 123
```

### 2. 管理 Session（工作會話）

OpenClaw 可以建立多個工作會話來處理不同任務。

**基本用法**：

```bash
# 列出所有會話
openclaw sessions list

# 查看會話歷史記錄
openclaw sessions history --session-key xxx

# 向會話發送訊息
openclaw sessions send --session-key xxx "你好嗎？"
```

### 3. 管理子代理（Sub-agents）

子代理是可以獨立運行的輔助 AI 助手。

**基本用法**：

```bash
# 列出所有子代理
openclaw subagents list

# 控制子代理
openclaw subagents steer --target xxx --message "繼續執行"

# 終止子代理
openclaw subagents kill --target xxx
```

### 4. 使用技能（Skills）

OpenClaw 預設安裝了多種技能，可以執行特定任務。

**預設技能清單**：

- `weather`：查看天氣預報
- `web_search`：網路搜尋
- `web_fetch`：抓取網頁內容
- `file_management`：檔案管理
- `system_monitoring`：系統監控

**使用範例**：

```bash
# 查看天氣
openclaw weather --city 台北

# 搜尋網路
openclaw web_search --query "openclaw 使用教學"
```

### 5. 使用記憶系統

OpenClaw 可以在特定目錄下儲存記憶資訊。

**基本用法**：

```bash
# 讀取記憶檔案
cat .openclaw/workspace/memory/memory.md

# 新增記憶
echo "今天完成了 xxx 任務" >> .openclaw/workspace/memory/memory.md
```

---

## 📝 快速參考卡

### 日常使用命令

| 命令 | 說明 |
|------|------|
| `openclaw status` | 查看系統狀態 |
| `openclaw help` | 顯示所有命令說明 |
| `openclaw --version` | 查看版本 |
| `openclaw restart` | 重新啟動服務 |
| `openclaw stop` | 停止服務 |

### 故障排除命令

| 命令 | 說明 |
|------|------|
| `openclaw log` | 查看日誌 |
| `openclaw cron list` | 列出定期工作 |
| `openclaw sessions list` | 列出所有會話 |
| `openclaw subagents list` | 列出所有子代理 |

### 進階命令

| 命令 | 說明 |
|------|------|
| `openclaw cron add` | 新增定期工作 |
| `openclaw cron remove` | 刪除定期工作 |
| `openclaw cron run` | 立即執行定期工作 |
| `openclaw sessions send` | 向會話發送訊息 |
| `openclaw subagents steer` | 控制子代理 |

---

## 🎯 學習小貼士

### 給初學者的建議

1. **不要一次性記住所有命令**
   - 先從最常用的命令開始
   - 需要時隨時查詢

2. **善用 `openclaw help`**
   - 每個命令都有詳細說明
   - 隨時查詢使用範例

3. **保留日誌檔案**
   - 遇到問題時查看日誌
   - 日誌是最佳的故障排查工具

4. **不要隨意修改系統檔案**
   - 只修改 `.openclaw/workspace` 目錄
   - 其他系統檔案請保持原狀

5. **定期更新 OpenClaw**
   - 保持最新版本
   - 新版本通常有更好的功能與安全性

---

## 🎓 下一步學習路徑

### 第一週：熟悉基本操作

- [ ] 掌握基本命令（status, help, version）
- [ ] 查看系統日誌
- [ ] 理解系統狀態報告

### 第二週：探索進階功能

- [ ] 設定第一個定期工作（cron）
- [ ] 了解 Session 功能
- [ ] 嘗試使用子代理

### 第三週：實作自動化任務

- [ ] 設定每日備份工作
- [ ] 建立天氣查詢機器人
- [ ] 自動化檔案整理

### 第四週：進階技巧

- [ ] 深入理解記憶系統
- [ ] 使用技能（Skills）
- [ ] 開發自定義功能

---

## 📞 需要幫助？

### 常見資源

- **官方文件**：https://docs.openclaw.ai
- **社群討論區**：https://discord.com/invite/clawd
- **GitHub 倉庫**：https://github.com/openclaw/openclaw

### 線上支持

- 訪問 OpenClaw 官方 Discord
- 加入社群討論群組
- 查看已解決的問題清單

---

## 🌟 恭喜您完成基本學習！

您現在已經掌握了 OpenClaw 的核心功能。接下來您可以：

1. **探索更多功能**：試試進階命令和技巧
2. **設定自動化任務**：節省您的時間
3. **分享您的經驗**：幫助其他新手

**記住**：熟能生巧！多多練習，您會越來越熟練的！

---

*最後更新：2026 年 4 月 8 日*  
*版本：2026.4.8*  
*作者：OpenClaw AI 助手*
