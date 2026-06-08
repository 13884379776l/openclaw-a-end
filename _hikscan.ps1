$cam = "192.168.31.203"

Write-Host "`n=== Hikvision Camera Check ===" -ForegroundColor Cyan
Write-Host "ID: 5970380977" -ForegroundColor Gray

# ISAPI capabilities check
$isapiUrls = @(
    "/ISAPI/System/capabilities",
    "/ISAPI/Streaming/channels", 
    "/ISAPI/System/deviceInfo",
    "/ISAPI/System/httpPrivilege"
)

foreach($url in $isapiUrls){
    try{
        $req = [System.Net.HttpWebRequest]::Create("http://$cam"+$url)
        $req.Timeout = 5000
        $req.Method = "GET"
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $content = $reader.ReadToEnd()
        Write-Host ("ISAPI "+$url+": "+$content.Length+" chars") -ForegroundColor Green
        if($content.Length -lt 500){
            Write-Host "    Content: "+$content.Substring(0,[Math]::Min($content.Length,300)) -ForegroundColor DarkGray
        }
        $reader.Close()
        $resp.Close()
    }catch{
        Write-Host ("ISAPI "+$url+": FAILED ("+$_.Exception.Message+")") -ForegroundColor Red
    }
}

# RTSP test
Write-Host "`nRTSP streams:" -ForegroundColor Cyan
$streams = @(
    "rtsp://$cam:554/Streaming/Channels/101",  # Main stream
    "rtsp://$cam:554/Streaming/Channels/102"   # Sub stream  
)
foreach($s in $streams){
    try{
        $proc = Start-Process ffprobe -ArgumentList "-v error -show_entries format=filename \"$s\"" -NoNewWindow -PassThru -Wait
        if($proc.ExitCode -eq 0){
            Write-Host (""+$s+": OK") -ForegroundColor Green
        } else {
            Write-Host (""+$s+": FAIL") -ForegroundColor Red
        }
    }catch{
        Write-Host ($s+": ffprobe not available") -ForegroundColor Yellow
    }
}

Write-Host "`nDone" -ForegroundColor Gray
