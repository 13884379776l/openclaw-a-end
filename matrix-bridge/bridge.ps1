# Matrix Bridge v4 - OpenClaw (A端)
# 通过 Synapse Client API 桥接 Matrix 到 OpenClaw
param($Action = "poll", $Message, $RoomId = "!WXyqvGnGVJGsgSODSR")

$HomeServer = "http://192.168.31.18:8008"
$Token = "syt_Y29tbWFuZGVy_sEfjJMnwTyHpFjutrKUN_1Vk49W"
$TOKEN_FILE = Join-Path $PSScriptRoot "token.json"
$LAST_FILE = Join-Path $PSScriptRoot "last-msg-ts.json"
$Proxy = "http://127.0.0.1:10809"
$User = "commander"
$Pass = "Cmd@123456!"

function Curl-Get ($path) {
    $url = "$HomeServer$path"
    $h = "Authorization: Bearer $Token"
    $r = curl.exe -s -x $Proxy "`$url" -X GET -H $h
    return $r
}

function Curl-Put ($path, $body) {
    $url = "$HomeServer$path"
    $h1 = "Authorization: Bearer $Token"
    $h2 = "Content-Type: application/json"
    $r = curl.exe -s -x $Proxy "`$url" -X PUT -H $h1 -H $h2 -d $body
    return $r
}

function Refresh-Token {
    $lb = '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"commander"},"password":"Cmd@123456!"}'
    $result = curl.exe -s -x $Proxy "$HomeServer/_matrix/client/v3/login" -X POST -H "Content-Type: application/json" -d $lb
    $obj = $result | ConvertFrom-Json
    if ($obj.access_token) {
        @{ token = $obj.access_token; ts = (Get-Date).ToUniversalTime().ToString("o") } | ConvertTo-Json | Set-Content $TOKEN_FILE
        Write-Host "TOKEN|$( $obj.access_token )"
        return $obj.access_token
    }
    Write-Host "ERROR|Login failed"
    return $null
}

function Poll {
    $lastTs = 0
    if (Test-Path $LAST_FILE) {
        $lastTs = (Get-Content $LAST_FILE | ConvertFrom-Json).ts
    }
    
    $path = "/_matrix/client/v3/rooms/$([Net.WebUtility]::UrlEncode($RoomId))/messages?dir=b&limit=50&timeout=0"
    $resp = Curl-Get $path
    $obj = $resp | ConvertFrom-Json
    $msgs = $obj.chunk | Where-Object { $_.type -eq "m.room.message" } | Sort-Object origin_server_ts
    
    if ($lastTs -gt 0) {
        $msgs = $msgs | Where-Object { [long]$_.origin_server_ts -gt $lastTs }
    }
    
    if ($msgs.Count -eq 0) {
        Write-Host "NO_MESSAGES"
        return
    }
    
    foreach ($m in $msgs) {
        $body = $m.content.body -or $m.content."m.body" -or "[富文本]"
        Write-Host "MSG|$($m.sender)|$body|$( $m.origin_server_ts )"
    }
    
    @{ ts = (Get-Date).ToUniversalTime().ToUnixTimeMilliseconds() } | ConvertTo-Json | Set-Content $LAST_FILE
}

function Send-Matrix ($text) {
    $txnId = (Get-Random -Maximum 4294967296).ToString("x8")
    $body = '{"msgtype":"m.text","body":"' + $text.Replace('"','\"') + '"}'
    $path = "/_matrix/client/v3/rooms/$([Net.WebUtility]::UrlEncode($RoomId))/send/m.room.message/$txnId"
    $resp = Curl-Put $path $body
    if ($resp -match '^\{') { Write-Host "OK" } else { Write-Host "ERR|$resp" }
}

function ListRooms {
    $path = "/_matrix/client/v3/joined_rooms"
    $resp = Curl-Get $path
    $rooms = ($resp | ConvertFrom-Json).joined_rooms
    foreach ($r in $rooms) {
        $name = "(unknown)"
        try {
            $n = Curl-Get "/_matrix/client/v3/rooms/$([Net.WebUtility]::UrlEncode($r))/state/m.room.name"
            $name = ($n | ConvertFrom-Json).name
        } catch { }
        Write-Host "$r | $name"
    }
}

$lastTs = 0
if ($Action -eq "poll") {
    Poll
} elseif ($Action -eq "send") {
    Send-Matrix $Message
} elseif ($Action -eq "login") {
    Refresh-Token
} elseif ($Action -eq "rooms") {
    ListRooms
}
