$ips = @(22,80,443,3000,5000,8008,8088,9090)
foreach ($i in $ips) {
    try {
        $tcp = New-Object Net.Sockets.TcpClient
        $tcp.Connect('192.168.31.18', $i)
        Write-Host ("Port " + $i + ": OPEN")
        $tcp.Close()
        $tcp.Dispose()
    } catch { }
}
'Scan complete'
