# GPU 功率限制脚本（需要管理员权限）

Write-Host "=== GPU 功率限制设置 ===" -ForegroundColor Cyan

# RTX 3090 设置 330W
Write-Host "[3090] 设置功率上限: 330W..." -ForegroundColor Yellow
nvidia-smi -i 0 --power-limit=330
if ($LASTEXITCODE -ne 0) { Write-Host "[3090] 设置失败 (可能需要管理员权限)" -ForegroundColor Red }

# RTX 5070 Ti 设置 250W
Write-Host "[5070Ti] 设置功率上限: 250W..." -ForegroundColor Yellow
nvidia-smi -i 1 --power-limit=250
if ($LASTEXITCODE -ne 0) { Write-Host "[5070Ti] 设置失败 (可能需要管理员权限)" -ForegroundColor Red }

# 验证
Write-Host "`n=== 当前状态 ===" -ForegroundColor Green
nvidia-smi --query-gpu=name,power.draw,power.limit,temperature.gpu --format=csv

Write-Host "`n功率设置完成" -ForegroundColor Green
