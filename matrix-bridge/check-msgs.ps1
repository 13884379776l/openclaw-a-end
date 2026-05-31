$token = "syt_Y29tbWFuZGVy_sEfjJMnwTyHpFjutrKUN_1Vk49W"
$lastTsObj = Get-Content last-msg-ts.json | ConvertFrom-Json
$lastTs = if ($lastTsObj -ne $null -and $lastTsObj.ts -ne $null) { $lastTsObj.ts } else { 0 }

# Use URI object to avoid shell interpretation of &
$uri = New-Object System.Uri("http://192.168.31.18:8008/_matrix/client/v3/rooms/%21mPDLgwreaBeBbOsABm%3Ab-matrix-server/messages?dir=b&limit=10&timeout=0")

curl.exe -s -x http://127.0.0.1:10809 $uri.AbsoluteUri -H "Authorization: Bearer $token"
