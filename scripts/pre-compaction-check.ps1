# 压缩前安全检查脚本
# 目的：在上下文压缩触发前，确保关键状态已持久化
# 运行方式：exec 直接执行，不依赖 LLM

$workspace = "C:\Users\48856\.openclaw\workspace"
$memoryDir = "$workspace\memory"
$dateStr = Get-Date -Format "yyyy-MM-dd"
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$todayFile = "$memoryDir\$dateStr.md"

# 确保目录存在
if (-not (Test-Path $memoryDir)) { New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null }

# 1. 检查 memory 目录状态
$memoryCount = (Get-ChildItem "$memoryDir\*.md" -File).Count
$memorySize = (Get-ChildItem "$memoryDir\*.md" -File | Measure-Object -Property Length -Sum).Sum

# 2. 检查 heartbeat-state.json
$hbState = "$workspace\heartbeat-state.json"
$hbExists = Test-Path $hbState

# 3. 检查 cron 任务状态（最近 24h 有错误的）
$cronErrors = @()

# 4. 检查会话锁（stale session lock）
$sessionsDir = "C:\Users\48856\.openclaw\agents\main\sessions"
$staleLocks = 0
if (Test-Path $sessionsDir) {
    $staleLocks = (Get-ChildItem $sessionsDir -File | Where-Object { $_.Name -like "*.lock" }).Count
}

# 5. 检查 Ollama 模型
$ollamaList = @()
try {
    $ollamaList = (ollama list 2>&1)
} catch {
    $ollamaList = "Ollama 不可用"
}

# 6. 检查 Z 盘挂载
$zExists = Test-Path "Z:\"

# 写入今天的日志
$appendLine = @"

## 压缩前自检 ($ts)
- memory 目录: $memoryCount 个文件, $([math]::Round($memorySize/1KB,1)) KB
- heartbeat-state.json: $(if($hbExists){"存在"}else{"不存在"})
- 会话锁: $staleLocks
- Z 盘: $(if($zExists){"已挂载"}else{"未挂载"})
- Ollama 模型: $(($ollamaList | Select-Object -First 1) -replace "`n.*","") ...
- 注意: 此条由脚本自动记录，非 LLM 生成
"@

Add-Content -Path $todayFile -Value $appendLine -Encoding UTF8

# 输出到 exec 结果
Write-Output "pre-compaction-check: memory=$memoryCount files, stale_locks=$staleLocks, z_exists=$zExists"
