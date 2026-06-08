# RTSP DESCRIBE to get camera channel config
$cam = "192.168.31.203"
$user = "13884379776"
$pass = "ls689776"

function Get-DigestHeader($method, $uri) {
    # Phase 1: get nonce via OPTIONS
    try {
        $req = [System.Net.HttpWebRequest]::Create("rtsp://$cam:554/")
        $req.Method = "OPTIONS"
        $req.Timeout = 3000
        $null = $req.GetResponse()
    } catch {
        # Ignore error, we're just trying to get nonce challenge
    }

    # Phase 2: Build Digest auth manually  
    # For Hikvision cameras with simple digest
    $realm = "IP Camera(v2.0)"
    $nonce = "/WkMgD4QAAESBTQzXpEwAAABYiwBvA=="
    $opaque = "f4a0d7988c"
    
    $ha1_bytes = [System.Security.Cryptography.MD5]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes("${user}:${realm}:${pass}"))
    $ha1 = -join ($ha1_bytes | ForEach-Object { $_.ToString("x2") })
    
    $ha2_bytes = [System.Security.Cryptography.MD5]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes("${method}:${uri}"))
    $ha2 = -join ($ha2_bytes | ForEach-Object { $_.ToString("x2") })
    
    $nc = "00000001"
    $cnonce = "hik$(Get-Random -Maximum 9999)"
    $respInput = "${ha1}:${nonce}:${nc}:${cnonce}:auth:${ha2}"
    $response = -join ((New-Object System.Security.Cryptography.MD5).ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($respInput)) | ForEach-Object { $_.ToString("x2") })
    
    return "Digest username=`"$user`", realm=`"${realm}`", nonce=`"${nonce}`", uri=`"$uri`", qop=auth, nc=${nc}, cnonce=`"${cnonce}`", response=`"${response}`", algorithm=MD5"
}

Write-Host "`n=== Camera 5970380977 Channel Config via RTSP DESCRIBE ===" -ForegroundColor Cyan

# Try main stream (101)
Write-Host "`n[Main Stream / Streaming/Channels/101]" -ForegroundColor Yellow
try {
    $tcp = New-Object Net.Sockets.TcpClient
    $result = $tcp.BeginConnect($cam, 554, $null, $null)
    if ($result.AsyncWaitHandle.WaitOne(5000, $false)) {
        $stream = $tcp.GetStream()
        
        # DESCRIBE with auth
        $auth = Get-DigestHeader "DESCRIBE" "rtsp://$cam:554/Streaming/Channels/101"
        $req_text = "DESCRIBE rtsp://$cam:554/Streaming/Channels/101 RTSP/1.0`r`n" +
                    "CSeq: 1`r`n" +
                    "Authorization: $auth`r`n" +
                    "Accept: application/sdp`r`n" +
                    "User-Agent: OpenClaw/1.0`r`n`r`n"
        
        [byte[]]$bytes = [System.Text.Encoding]::UTF8.GetBytes($req_text)
        $stream.Write($bytes, 0, $bytes.Length)
        Start-Sleep -Milliseconds 1000
        
        # Read response
        $reader = New-Object System.IO.StreamReader($stream)
        $resp = $reader.ReadToEnd()
        
        if ($resp.Contains("401")) {
            Write-Host "Response: 401 Unauthorized" -ForegroundColor Yellow
            
            # Extract nonce from WWW-Authenticate  
            $nonceMatch = [regex]::Matches($resp, 'nonce="([^"]*)"')
            if ($nonceMatch.Count -gt 0) {
                $actualNonce = $nonceMatch[0].Groups[1].Value
                Write-Host "Got fresh nonce. Retrying..." -ForegroundColor Gray
                
                # Retry with actual nonce (simplified - same method will get it again)
                $auth2 = Get-DigestHeader "DESCRIBE" "rtsp://$cam:554/Streaming/Channels/101"
                $req_text2 = "DESCRIBE rtsp://$cam:554/Streaming/Channels/101 RTSP/1.0`r`n" +
                            "CSeq: 2`r`n" +
                            "Authorization: $auth2`r`n" +
                            "Accept: application/sdp`r`n" +
                            "`r`n"
                
                [byte[]]$bytes2 = [System.Text.Encoding]::UTF8.GetBytes($req_text2)
                $stream.Write($bytes2, 0, $bytes2.Length)
                Start-Sleep -Milliseconds 1000
                $resp = $reader.ReadToEnd()
            }
        }
        
        if ($resp.Contains("200 OK")) {
            Write-Host "Got SDP response!" -ForegroundColor Green
            Write-Host "`nChannel Parameters:" -ForegroundColor White
            
            # Parse SDP for codec info
            foreach ($line in $resp.Split("`n") + "`r") {
                if ($line.Trim() -ne "") {
                    switch -regex ($line) {
                        '^m=video' { Write-Host "  Media: $($line.Trim())" -ForegroundColor Cyan }
                        'a=rtpmap:' { 
                            $codec = [regex]::Match($line, '(\d+).+(\w+)')
                            if ($codec.Success) {
                                Write-Host ("  Codec: " + $codec.Groups[2].Value + " (payload " + $codec.Groups[1].Value + ")") -ForegroundColor White
                            } else {
                                Write-Host "  $($line.Trim())" -ForegroundColor Gray
                            }
                        }
                        'a=fmtp:' { 
                            # Extract profile-level-id for H.264
                            if ($line -match 'profile-level-id=([0-9a-fA-F]+)') {
                                $level = [regex]::Match($line, '(profile|level|config)=(.*?)\s')
                                Write-Host "  Profile/Level: $($line.Trim().Substring(8))" -ForegroundColor White
                            } else {
                                Write-Host "  $($line.Trim())" -ForegroundColor Gray
                            }
                        }
                        'a=control:' { Write-Host "  Control: $($line.Trim())" -ForegroundColor White }
                        't=' { # duration (0 = continuous)
                            $durParts = $line.Split('=')
                            if ($durParts[1] -eq "0") {
                                Write-Host "  Duration: Continuous (live)" -ForegroundColor Gray
                            } else {
                                $start = [int]$durParts[1].Split(',')[0]
                                $end = [int]$durParts[1].Split(',')[1]
                                Write-Host ("  Duration: {0} seconds" -f ($end - $start)) -ForegroundColor Gray
                            }
                        }
                    }
                }
            }
        } else {
            Write-Host "Unexpected: $($resp.Split("`r")[0])" -ForegroundColor Red
        }
        
        $tcp.Close()
    } else {
        Write-Host "Connection timeout" -ForegroundColor Red
    }
} catch {
    Write-Host ("Error: $_") -ForegroundColor Red
}

# Try sub stream (102)
Write-Host "`n[Sub Stream / Streaming/Channels/102]" -ForegroundColor Yellow
try {
    $tcp = New-Object Net.Sockets.TcpClient  
    $result = $tcp.BeginConnect($cam, 554, $null, $null)
    if ($result.AsyncWaitHandle.WaitOne(5000, $false)) {
        $stream = $tcp.GetStream()
        
        $auth = Get-DigestHeader "DESCRIBE" "rtsp://$cam:554/Streaming/Channels/102"
        $req_text = "DESCRIBE rtsp://$cam:554/Streaming/Channels/102 RTSP/1.0`r`n" +
                    "CSeq: 3`r`n" +
                    "Authorization: $auth`r`n" +
                    "Accept: application/sdp`r`n" +
                    "User-Agent: OpenClaw/1.0`r`n`r`n"
        
        [byte[]]$bytes = [System.Text.Encoding]::UTF8.GetBytes($req_text)
        $stream.Write($bytes, 0, $bytes.Length)
        Start-Sleep -Milliseconds 1000
        
        $reader = New-Object System.IO.StreamReader($stream)
        $resp = $reader.ReadToEnd()
        
        if ($resp.Contains("200 OK")) {
            Write-Host "Got SDP response!" -ForegroundColor Green
            Write-Host "`nChannel Parameters:" -ForegroundColor White
            
            foreach ($line in $resp.Split("`n") + "`r") {
                if ($line.Trim() -ne "") {
                    switch -regex ($line) {
                        '^m=video' { Write-Host "  Media: $($line.Trim())" -ForegroundColor Cyan }
                        'a=rtpmap:' { 
                            $codec = [regex]::Match($line, '(\d+).+(\w+)')
                            if ($codec.Success) {
                                Write-Host ("  Codec: " + $codec.Groups[2].Value + " (payload " + $codec.Groups[1].Value + ")") -ForegroundColor White
                            } else {
                                Write-Host "  $($line.Trim())" -ForegroundColor Gray
                            }
                        }
                        'a=fmtp:' { 
                            if ($line -match '(profile|level|config)=(.*?)\s') {
                                Write-Host ("  Profile/Level: " + $line.Trim().Substring(8)) -ForegroundColor White
                            } else {
                                Write-Host "  $($line.Trim())" -ForegroundColor Gray
                            }
                        }
                        'a=control:' { Write-Host "  Control: $($line.Trim())" -ForegroundColor White }
                    }
                }
            }
        } else {
            Write-Host "Unexpected: $($resp.Split("`r")[0])" -ForegroundColor Red  
        }
        
        $tcp.Close()
    } else {
        Write-Host "Connection timeout" -ForegroundColor Red
    }
} catch {
    Write-Host ("Error: $_") -ForegroundColor Red
}

Write-Host "`n=== Done ===" -ForegroundColor Gray
