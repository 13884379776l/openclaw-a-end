# L1 流水自动记录脚本（纯 PowerShell，不依赖 LLM）
# 目标：Z:\knowledge_base\logs\l1_raw_a.jsonl
# 运行方式：exec 直接执行

$logDir = "Z:\knowledge_base\logs"
$logFile = "$logDir\l1_raw_a.jsonl"
$ts = Get-Date -Format "yyyy-MM-ddTHH:mm:ss+08:00"

# 确保目录存在
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

# 收集状态信息
$gatewayOk = "unreachable"
try {
    $health = Invoke-WebRequest -Uri "http://127.0.0.1:18789/health" -TimeoutSec 3 -UseBasicParsing
    if ($health.StatusCode -eq 200) { $gatewayOk = "up" }
} catch { $gatewayOk = "down" }

$ollamaModels = 0
try { $ollamaModels = (ollama list 2>&1 | Measure-Object -Line).Line } catch { $ollamaModels = -1 }

$zExists = Test-Path "Z:\"
$workspaceSizeKB = (Get-ChildItem "C:\Users\48856\.openclaw\workspace" -Recurse -File -Force | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum
$workspaceSizeKB = [math]::Round($workspaceSizeKB / 1KB, 1)

# 构建 JSON 行
$jsonObj = @{
    ts = $ts
    src = "A"
    type = "heartbeat"
    content = "Gateway=$gatewayOk | Ollama_models=$ollamaModels | Z=$zExists | Workspace=${workspaceSizeKB}KB"
    context = @{
        gateway = $gatewayOk
        ollama_models = $ollamaModels
        z_disk = $zExists
        workspace_size_kb = $workspaceSizeKB
    }
} | ConvertTo-Json -Depth 3

Add-Content -Path $logFile -Value $jsonObj -Encoding UTF8
Write-Output "L1 log written: $logFile"
