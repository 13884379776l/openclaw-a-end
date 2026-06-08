# Hikvision camera on 192.168.31.203 - scan common ports
$ports = @(80,443,554,8000,8080,8081,8082,8086,8088,9000,5000,3777,8008)
foreach($p in $ports){
    try{
        $tcp=New-Object Net.Sockets.TcpClient
        $result=$tcp.BeginConnect('192.168.31.203',$p,$null,$null)
        $wait=$result.AsyncWaitHandle.WaitOne(2000,$false)
        if($wait){
            Write-Host ("203:"+$p+" OPEN") -ForegroundColor Green
            try{ $tcp.EndConnect($result) | Out-Null }catch{}
            $tcp.Close(); $tcp.Dispose()
        }
    }catch{
        try{ $tcp.Close(); $tcp.Dispose() }catch{}
    }
}
Write-Host "`n=== Web login attempts ===" -ForegroundColor Cyan

# Try HTTP GET on common web ports and show response length
foreach($p in @(80,8080)){
    try{
        $wc=New-Object Net.WebClient
        $wc.Timeout=3000
        $r=$wc.DownloadString("http://192.168.31.203:"+$p+"/")
        Write-Host ("Port "+$p+": "+$r.Length+" chars returned") -ForegroundColor Green
    }catch{
        Write-Host ("Port "+$p+": "+$_) -ForegroundColor Red
    }
}

Write-Host "`nDone" -ForegroundColor Gray
