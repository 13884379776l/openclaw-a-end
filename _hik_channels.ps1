$cam = "192.168.31.203"
$user = "13884379776"
$pass = "ls689776"

Write-Host "`n=== Hikvision Camera 5970380977 Channel Config ===" -ForegroundColor Cyan

# Build Digest Auth header for RTSP DESCRIBE (Hikvision uses basic digest auth)
function Get-DigestAuthHeader($url, $method) {
    # Phase 1: get nonce via OPTIONS or GET challenge
    try {
        $req = [System.Net.HttpWebRequest]::Create("http://$cam/ISAPI/System/deviceInfo")
        $req.Method = "GET"
        $req.Timeout = 5000
        try { $resp = $req.GetResponse() } catch {}
        
        # Try to get WWW-Authenticate header for nonce
        $challenge = $null
        if ($_.Exception.Response.Headers["WWW-Authenticate"]) {
            $challenge = $_.Exception.Response.Headers["WWW-Authenticate"]
        }
    } catch {}

    # Build simple DESCRIBE request for RTSP
    $cseq = 1
    $realm = "IP Camera(v2.0)"
    $nonce = "/WkMgD4QAAESBTQzXpEwAAABYiwBvA==" # common Hikvision nonce
    $opaque = "f4a0d7988c"
    
    $ha1_bytes = [System.Security.Cryptography.MD5]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes("${user}:${realm}:${pass}"))
    $ha1 = -join ($ha1_bytes | ForEach-Object { $_.ToString("x2") })
    
    $ha2_bytes = [System.Security.Cryptography.MD5]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes("${method}:${url}"))
    $ha2 = -join ($ha2_bytes | ForEach-Object { $_.ToString("x2") })
    
    $nc = "00000001"
    $cnonce = "openclaw$(Get-Random -Maximum 9999)"
    $response_input = "${ha1}:${nonce}:${nc}:${cnonce}:auth:${ha2}"
    $response_bytes = [System.Security.Cryptography.MD5]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($response_input))
    $response = -join ($response_bytes | ForEach-Object { $_.ToString("x2") })
    
    return "Digest username=`"$user`", realm=`"${realm}`", nonce=`"${nonce}`", uri=`"$url`", qop=auth, nc=${nc}, cnonce=`"${cnonce}`", response=`"${response}`", algorithm=MD5"
}

# RTSP DESCRIBE URL
$url = "rtsp://$cam:554/Streaming/Channels/101"
Write-Host "`n[Channel 1 - Main Stream]" -ForegroundColor Yellow

try {
    # Create RTSP connection
    $tcp = New-Object Net.Sockets.TcpClient
    $result = $tcp.BeginConnect($cam, 554, $null, $null)
    if ($result.AsyncWaitHandle.WaitOne(5000, $false)) {
        $tcp.EndConnect($result) | Out-Null
        
        # Build RTSP DESCRIBE request with Digest Auth
        $auth = Get-DigestAuthHeader -url $url -method "DESCRIBE"
        
        $cseq = 1
        $req_text = "DESCRIBE rtsp://$cam:554/Streaming/Channels/101 RTSP/1.0`r`n" +
                    "CSeq: $cseq`r`n" +
                    "Authorization: $auth`r`n" +
                    "Accept: application/sdp`r`n`r`n"
        
        Write-Host "Request sent..." -ForegroundColor DarkGray
        [byte[]]$bytes = [System.Text.Encoding]::UTF8.GetBytes($req_text)
        $tcp.GetStream().Write($bytes, 0, $bytes.Length)
        Start-Sleep -Milliseconds 1000
        
        # Read response  
        $reader = New-Object System.IO.StreamReader($tcp.GetStream())
        $response = $reader.ReadToEnd()
        
        if ($response.Contains("401")) {
            Write-Host "Authentication required" -ForegroundColor Yellow
            Write-Host $response -ForegroundColor Red
        } elseif ($response.Contains("200 OK")) {
            Write-Host "Channel 1 Config:" -ForegroundColor Green
            
            # Parse SDP response for codec info
            $sdpLines = $response.Split("`n")
            foreach ($line in $sdpLines) {
                if ($line.StartsWith("a=rtpmap:") -or 
                    $line.StartsWith("a=fmtp:") -or
                    $line.StartsWith("m=video") -or
                    $line.StartsWith("a=control:") -or
                    $line.StartsWith("a=frameRate:")) {
                    Write-Host "  $($line.Trim())" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host ("Unexpected response: " + ($response.Split("`r")[0])) -ForegroundColor Yellow
        }
        
        $tcp.Close()
    } else {
        Write-Host "RTSP connection timeout" -ForegroundColor Red
    }
} catch {
    Write-Host "RTSP error: " + $_.Exception.Message -ForegroundColor Red
}

# Try Channel 2 (Sub Stream)
Write-Host "`n[Channel 2 - Sub Stream]" -ForegroundColor Yellow
try {
    $tcp = New-Object Net.Sockets.TcpClient
    $result = $tcp.BeginConnect($cam, 554, $null, $null)
    if ($result.AsyncWaitHandle.WaitOne(5000, $false)) {
        $tcp.EndConnect($result) | Out-Null
        
        $cseq = 2
        $auth = Get-DigestAuthHeader -url "rtsp://$cam:554/Streaming/Channels/102" -method "DESCRIBE"
        
        $req_text = "DESCRIBE rtsp://$cam:554/Streaming/Channels/102 RTSP/1.0`r`n" +
                    "CSeq: $cseq`r`n" +
                    "Authorization: $auth`r`n" +
                    "Accept: application/sdp`r`n`r`n"
        
        [byte[]]$bytes = [System.Text.Encoding]::UTF8.GetBytes($req_text)
        $tcp.GetStream().Write($bytes, 0, $bytes.Length)
        Start-Sleep -Milliseconds 1000
        
        $reader = New-Object System.IO.StreamReader($tcp.GetStream())
        $response = $reader.ReadToEnd()
        
        if ($response.Contains("200 OK")) {
            Write-Host "Channel 2 Config:" -ForegroundColor Green
            
            $sdpLines = $response.Split("`n")
            foreach ($line in $sdpLines) {
                if ($line.StartsWith("a=rtpmap:") -or 
                    $line.StartsWith("a=fmtp:") -or
                    $line.StartsWith("m=video") -or
                    $line.StartsWith("a=control:")) {
                    Write-Host "  $($line.Trim())" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host ("Status: " + ($response.Split("`r")[0])) -ForegroundColor Yellow
        }
        
        $tcp.Close()
    } else {
        Write-Host "RTSP connection timeout" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`n=== Done ===" -ForegroundColor Gray
