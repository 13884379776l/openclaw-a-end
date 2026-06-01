# GPU Power & Fan Control Script
# 用途：降低 GPU 功耗和温度（空闲/夜间模式）

param(
    [string]$Mode = "low",  # "low" = 降功率, "full" = 恢复默认
    [int]$Power3090,
    [int]$Power5070Ti,
    [int]$Fan3090,
    [int]$Fan5070Ti
)

$ErrorActionPreference = "SilentlyContinue"

# 默认值
if ($Mode -eq "low") {
    if (-not $Power3090) { $Power3090 = 200 }     # 3090 降功率（100-380W）
    if (-not $Power5070Ti) { $Power5070Ti = 250 } # 5070 Ti 最低 250W
    if (-not $Fan3090) { $Fan3090 = 30 }          # 风扇低速
    if (-not $Fan5070Ti) { $Fan5070Ti = 25 }
} else {
    if (-not $Power3090) { $Power3090 = 380 }     # 恢复默认上限
    if (-not $Power5070Ti) { $Power5070Ti = 300 }
    if (-not $Fan3090) { $Fan3090 = 0 }           # 0 = 自动
    if (-not $Fan5070Ti) { $Fan5070Ti = 0 }
}

Write-Host "=== GPU Power & Fan Control ===" -ForegroundColor Cyan
Write-Host "模式：$(if($Mode -eq 'low'){'降功率/降温'}else{'恢复默认'})" -ForegroundColor Cyan
Write-Host "3090 功率：$Power3090W | 5070Ti 功率：$Power5070TiW" -ForegroundColor Yellow

# 设置功率限制
Write-Host "`n[3090] Setting power limit: $Power3090 W..." -ForegroundColor Gray
nvidia-smi -i 0 --power-limit=$Power3090
if ($LASTEXITCODE -ne 0) { Write-Host "[3090] Power limit set failed" -ForegroundColor DarkGray }

Write-Host "[5070Ti] Setting power limit: $Power5070Ti W..." -ForegroundColor Gray
nvidia-smi -i 1 --power-limit=$Power5070Ti
if ($LASTEXITCODE -ne 0) { Write-Host "[5070Ti] Power limit set failed" -ForegroundColor DarkGray }

# 设置风扇
Write-Host "[3090] Setting fan: $Fan3090%..." -ForegroundColor Gray
nvidia-smi -i 0 -f $Fan3090

Write-Host "[5070Ti] Setting fan: $Fan5070Ti%..." -ForegroundColor Gray
nvidia-smi -i 1 -f $Fan5070Ti

# 验证
Write-Host "`n=== Current Status ===" -ForegroundColor Green
nvidia-smi --query-gpu=name,power.draw,power.limit,temperature.gpu,fan.speed --format=csv

# 写入日志
$logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Mode:$Mode | 3090:$Power3090W/$Fan3090% | 5070Ti:$Power5070TiW/$Fan5070Ti%"
$logEntry | Out-File -FilePath "$env:TEMP\gpu_control.log" -Append -Encoding utf8
