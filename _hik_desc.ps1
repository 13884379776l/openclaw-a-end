# RTSP DESCRIBE to extract channel config from Hikvision camera
$cam = "192.168.31.203"
$user = "13884379776"
$pass = "ls689776"

function Send-RtspDescribe($uri) {
    Write-Host "`n>>> DESCRIBE $uri" -ForegroundColor Yellow
    
    $tcp = New-Object Net.Sockets.TcpClient
    try {
        $result = $tcp.BeginConnect($cam, 554, $null, $null)
        if (-not $result.AsyncWaitHandle.WaitOne(5000, $false)) {
            Write-Host "  Timeout" -ForegroundColor Red
            return
        }
        $tcp.EndConnect($result) | Out-Null
        
        # Build DESCRIBE with Digest Auth (Hikvision style)
        # First get nonce via OPTIONS or try without auth (some cameras allow it)
        
        # Method 1: Simple DESCRIBE without auth (try first)
        $cseq = 1
        $req = "DESCRIBE $uri RTSP/1.0`r`n" +
               "CSeq: $cseq`r`n" +
               "Accept: application/sdp`r`n" +
               "`r`n"
        
        [byte[]]$bytes = [System.Text.Encoding]::UTF8.GetBytes($req)
        $tcp.GetStream().Write($bytes, 0, $bytes.Length)
        
        # Read response
        $stream = $tcp.GetStream()
        $buf = New-Object char[] 8192
        $total = ""
        $count = 0
        while (($count = $stream.Read($buf, 0, $buf.Length)) -gt 0) {
            $total += [System.Text.Encoding]::UTF8.GetString($buf, 0, $count)
            if ($total -match "^\r?n$") { break } # end of headers
        }
        
        Write-Host "Response:" -ForegroundColor Gray
        
        # Check for auth challenge or content
        if ($total -match "401 Unauthorized") {
            Write-Host "  Need Auth - retrying with digest" -ForegroundColor Yellow
            
            # Extract nonce from WWW-Authenticate header
            $nonce = ""; $realm = ""
            foreach ($line in $total.Split("`n")) {
                if ($line -match 'nonce="([^"]*)"') { $nonce = [regex]::Match($line, 'nonce="([^"]*)"').Groups[1].Value }
                if ($line -match 'realm="([^"]*)"') { $realm = [regex]::Match($line, 'realm="([^"]*)"').Groups[1].Value }
            }
            
            # Compute digest response
            $ha1 = (New-Object System.Security.Cryptography.MD5).ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes("${user}:${realm}:${pass}"))
            $ha1str = -join ($ha1 | ForEach-Object { $_.ToString("x2") })
            
            $ha2 = (New-Object System.Security.Cryptography.MD5).ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes("DESCRIBE:${uri}"))
            $ha2str = -join ($ha2 | ForEach-Object { $_.ToString("x2") })
            
            $respInput = "${ha1str}:${nonce}:00000001:testauth:auth:${ha2str}"
            $response = -join ((New-Object System.Security.Cryptography.MD5).ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($respInput)) | ForEach-Object { $_.ToString("x2") })
            
            $cseq2 = $cseq + 1
            $authReq = "DESCRIBE $uri RTSP/1.0`r`n" +
                       "CSeq: $cseq2`r`n" +
                       "Accept: application/sdp`r`n" +
                       "Authorization: Digest username=`"$user`", realm=`"$realm`", nonce=`"$nonce`", uri=`"$uri`", response=`"$response`", algorithm=MD5, qop=auth, nc=00000001, cnonce=`"testauth`"`r`n" +
                       "`r`n"
            
            [byte[]]$bytes2 = [System.Text.Encoding]::UTF8.GetBytes($authReq)
            $tcp.GetStream().Write($bytes2, 0, $bytes2.Length)
            Start-Sleep -Milliseconds 500
            
            # Read response
            $buf2 = New-Object char[] 8192
            $total2 = ""
            while (($count = $stream.Read($buf2, 0, $buf2.Length)) -gt 0) {
                $total2 += [System.Text.Encoding]::UTF8.GetString($buf2, 0, $count)
            }
            
            # Parse SDP content for codec info
            if ($total2 -match "m=video") {
                Write-Host "`n--- Stream Media Info ---" -ForegroundColor Cyan
                foreach ($line in $total2.Split("`n")) {
                    if ($line.StartsWith("m=video") -or 
                        $line.StartsWith("a=control:") -or
                        $line.StartsWith("a=rtpmap:") -or
                        $line.StartsWith("a=fmtp:") -or
                        $line.StartsWith("a=sizehint:") -or
                        $line.StartsWith("t=")) {
                        Write-Host "  $($line.Trim())" -ForegroundColor White
                    }
                }
            }
            
            # Also extract from a= lines for codec details
            if ($total2 -match "a=fmtp:.*profile-level-id") {
                $fmtp = [regex]::Matches($total2, "a=fmtp:[^\r\n]+")[0].Value
                Write-Host "`n  Codec Details:" -ForegroundColor Cyan
                foreach ($line in $total2.Split("`n")) {
                    if ($line.StartsWith("a=rtpmap:") -or $line.StartsWith("a=fmtp:")) {
                        Write-Host "    $($line.Trim())" -ForegroundColor Gray
                    }
                }
            }
            
        } elseif ($total -match "200 OK") {
            Write-Host "  OK (no auth needed)" -ForegroundColor Green
        } else {
            Write-Host "  Status: $([regex]::Match($total, 'RTSP/\d\.\d \d+').Value)" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host ("Error: " + $_.Exception.Message) -ForegroundColor Red
    } finally {
        try { $tcp.Close() } catch {}
    }
}

Write-Host "`n=== Camera 5970380977 Channel Config ===" -ForegroundColor Cyan
Write-Host ("IP: $cam | User: $user | Pass: ****") -ForegroundColor DarkGray

# Try both main and sub stream
Send-RtspDescribe "rtsp://$cam:554/Streaming/Channels/101"
Send-RtspDescribe "rtsp://$cam:554/Streaming/Channels/102"

Write-Host "`nDone" -ForegroundColor Gray
