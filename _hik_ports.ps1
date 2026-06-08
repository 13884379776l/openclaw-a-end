# Hikvision camera on 192.168.31.203 - scan more ports
$ip = "192.168.31.203"
$ports = @(443, 8081, 8000, 37777, 9000, 554, 8088, 3000, 8082, 8800, 8090)
Write-Host "`n=== Scanning $ip ===" -ForegroundColor Cyan

foreach($p in $ports){
    try{
        $tcp = New-Object Net.Sockets.TcpClient
        $result = $tcp.BeginConnect($ip, $p, $null, $null)
        $wait = $result.AsyncWaitHandle.WaitOne(1500, $false)
        if($wait){
            try{ $tcp.EndConnect($result) | Out-Null }catch{}
            Write-Host ("Port " + $p + ": OPEN") -ForegroundColor Green
        }
        $tcp.Close(); $tcp.Dispose()
    } catch {}
}

Write-Host "`nDone" -ForegroundColor Gray
