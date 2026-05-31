# Matrix Bridge for OpenClaw (A端)
# 通过 Synapse Client API 桥接 Matrix 到 OpenClaw
# 需要 PowerShell 7+

param(
    [string]$Homeserver = "http://192.168.31.18:8008",
    [string]$AccessToken,
    [string]$RoomId = "!WXyqvGnGVJGsgSODSR",
    [string]$Action = "poll",
    [string]$LastCheckTs
)

function Get-Token {
    $loginUrl = "$Homeserver/_matrix/client/v3/login"
    $body = @{
        type = "m.login.password"
        identifier = @{
            type = "m.id.user"
            user = "commander"
        }
        password = "Cmd@123456!"
    } | ConvertTo-Json -Compress
    $resp = curl.exe -s -x http://127.0.0.1:10809 $loginUrl `
        -H "Content-Type: application/json" `
        -d $body
    ($resp | ConvertFrom-Json).access_token
}

function Read-Messages {
    if (-not $AccessToken) {
        $AccessToken = Get-Token
    }
    $url = "$Homeserver/_matrix/client/v3/rooms/$RoomId/messages?dir=b&limit=50&timeout=0"
    $headers = @{ "Authorization" = "Bearer $AccessToken" }
    $resp = curl.exe -s -x http://127.0.0.1:10809 $url -H $headers
    $obj = $resp | ConvertFrom-Json
    $messages = $obj.chunk | Where-Object { $_.type -eq "m.room.message" } | Sort-Object origin_server_ts
    
    if ($LastCheckTs) {
        $messages = $messages | Where-Object { [long]$_.origin_server_ts -gt ([long]$LastCheckTs) }
    }
    
    $messages | ForEach-Object {
        $body = $_.content.body
        if (-not $body) {
            $body = if ($_.content."m.body") { $_.content."m.body" } else { "[富文本消息]" }
        }
        @{
            sender = $_.sender
            body = $body
            ts = [long]$_.origin_server_ts
            eventId = $_.event_id
        }
    }
}

function Send-Message ($body, $token = $null) {
    if (-not $token) { $token = Get-Token }
    $txnId = [guid]::NewGuid().ToString().Substring(0, 16)
    $url = "$Homeserver/_matrix/client/v3/rooms/$RoomId/send/m.room.message/$txnId"
    $msgBody = @{ msgtype = "m.text"; body = $body } | ConvertTo-Json -Compress
    $headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
    curl.exe -s -x http://127.0.0.1:10809 $url -X PUT `
        -H $headers -d $msgBody | Out-Null
}

switch ($Action) {
    "poll" { Read-Messages | ConvertTo-Json -Depth 10 }
    "send" { Send-Message -body $bodyText }
    "token" { Get-Token }
    "rooms" {
        $url = "$Homeserver/_matrix/client/v3/joined_rooms"
        $headers = @{ "Authorization" = "Bearer $($AccessToken ?: (Get-Token))" }
        curl.exe -s -x http://127.0.0.1:10809 $url -H $headers | ConvertFrom-Json |
            ForEach-Object { $_.joined_rooms }
    }
}
