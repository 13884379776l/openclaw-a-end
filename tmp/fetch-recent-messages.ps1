# 获取最近收到的消息
Write-Host "=== 获取登录 token ==="
try {
    $login_response = Invoke-RestMethod -Uri "http://192.168.31.18:9090/_synapse/admin/v1/login" -Method POST -Body @{
        type = "m.login.password"
        identifier = @{
            type = "m.id.user"
            user = "commander"
        }
        password = "Cmd@123456!"
    } -ContentType "application/json" -ErrorAction Stop
    $access_token = $login_response.access_token
    Write-Host "Token: $access_token"
} catch {
    Write-Host "登录失败：$($_.Exception.Message)"
    exit 1
}

# 获取最近的消息（需要房间 ID）
Write-Host "=== 获取最近消息 ==="
# 尝试通过 Matrix 客户端 API 获取房间消息
# 需要知道房间 ID，这里假设是 #123:b-matrix-server
$room_id = "!roomid:b-matrix-server"  # 需要实际房间 ID
$fetch_url = "http://192.168.31.18:9090/_matrix/client/r0/rooms/$room_id/messages"

try {
    $messages = Invoke-RestMethod -Uri $fetch_url -Method GET -Headers @{
        Authorization = "Bearer $access_token"
    } -ContentType "application/json" -ErrorAction Stop
    Write-Host "消息列表："
    $messages.chunk | Format-Table type, content
} catch {
    Write-Host "获取消息失败：$($_.Exception.Message)"
}
