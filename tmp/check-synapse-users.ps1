# 检查 Synapse 用户列表
Write-Host "=== 检查 Synapse 用户 ==="
Invoke-RestMethod -Uri "http://192.168.31.18:9090/_synapse/admin/v1/users" -Method GET -TimeoutSec 10 2>&1

Write-Host "=== 检查 Synapse 管理 API 状态 ==="
Invoke-WebRequest "http://192.168.31.18:9090/_synapse/admin/v1/server_version" -Method GET -UseBasicParsing -TimeoutSec 10 2>&1

Write-Host "=== 检查 Element Web 状态 ==="
Invoke-WebRequest "http://192.168.31.18:8088/" -UseBasicParsing -TimeoutSec 10 2>&1 | Format-List StatusCode
