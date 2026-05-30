# 尝试通过 Synapse 管理 API 获取群组列表
Write-Host "=== 获取群组列表 ==="
Invoke-RestMethod -Uri "http://192.168.31.18:9090/_synapse/admin/v1/public-channels" -Method GET -TimeoutSec 10 2>&1

Write-Host "=== 尝试获取房间列表 ==="
# 假设我们已经有登录凭据，尝试获取房间列表
# 这里需要先用 soldier_a 的凭据登录
