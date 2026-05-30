# 查找房间 123
Write-Host "=== 查找房间 123 ==="

# 获取登录 token（用 commander 账户）
Write-Host "=== 获取登录 token ==="
$login_response = Invoke-RestMethod -Uri "http://192.168.31.18:9090/_synapse/admin/v1/login" -Method POST -Body @{
    type = "m.login.password"
    identifier = @{
        type = "m.id.user"
        user = "commander"
    }
    password = "Cmd@123456!"
} -ContentType "application/json"

$access_token = $login_response.access_token
Write-Host "Token: $access_token"

# 通过 token 查找房间
Write-Host "=== 查找房间列表 ==="
Invoke-RestMethod -Uri "http://192.168.31.18:9090/_synapse/admin/v1/directory/list/room" -Method GET -Headers @{
    Authorization = "Bearer $access_token"
} -TimeoutSec 10 2>&1
