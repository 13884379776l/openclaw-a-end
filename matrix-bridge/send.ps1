# Matrix Bridge Send - 通过 Matrix 发送消息
param([string]$Message, [string]$RoomId = "!WXyqvGnGVJGsgSODSR")
$token = "syt_Y29tbWFuZGVy_zBlcItXNlkRfppMcDeyZ_33GHXA"
$txnId = (Get-Random -Maximum 16777216).ToString("x8")
$url = "http://192.168.31.18:8008/_matrix/client/v3/rooms/$([Net.WebUtility]::UrlEncode($RoomId))/send/m.room.message/$txnId"
$body = '{"msgtype":"m.text","body":"' + $Message.Replace('"','\"') + '"}'
curl.exe -s -x http://127.0.0.1:10809 $url -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $token" -d $body