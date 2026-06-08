$cam = "192.168.31.203"
$user = "13884379776"
$pass = "13884379776"

Write-Host "`n=== Camera 5970380977 Test ===" -ForegroundColor Cyan
Write-Host ("IP: $cam | User: $user") -ForegroundColor DarkGray

# Try ISAPI endpoints via PowerShell (not curl which keeps failing)
$urls = @(
    "/ISAPI/System/capabilities",
    "/ISAPI/System/deviceInfo",
    "/ISAPI/Streaming/channels/1"
)

foreach($u in $urls){
    try{
        $req = [System.Net.HttpWebRequest]::Create("http://$cam$u")
        $req.Method = "GET"
        $req.Timeout = 5000
        $resp = $req.GetResponse()
        $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $content = $r.ReadToEnd()
        Write-Host ("$u => OK (" + $content.Length + " bytes)") -ForegroundColor Green
        if($content.Length -lt 400){
            Write-Host ("    " + $content) -ForegroundColor DarkGray
        } else {
            Write-Host ("    " + $content.Substring(0,200)) -ForegroundColor DarkGray
        }
        $r.Close(); $resp.Close()
    } catch {
        $msg = $_.Exception.Message
        if($msg -like "*401*"){
            Write-Host ($u + " => 401 Unauthorized (Digest Auth needed)") -ForegroundColor Yellow
        } else {
            Write-Host ($u + " => " + $msg) -ForegroundColor Red
        }
    }
}

# RTSP streams (username:password encoded in URL for RTSP)
Write-Host "`n=== RTSP Streams ===" -ForegroundColor Yellow
$rtspMain = "rtsp://" + $user + ":" + $pass + "@" + $cam + ":554/Streaming/Channels/101"
$rtspSub  = "rtsp://" + $user + ":" + $pass + "@" + $cam + ":554/Streaming/Channels/102"
Write-Host ("Main: " + $rtspMain) -ForegroundColor Cyan
Write-Host ("Sub:  " + $rtspSub) -ForegroundColor Cyan

# ONVIF
$onvif = "http://" + $cam + ":80/onvif/device-service"
Write-Host ("ONVIF: " + $onvif) -ForegroundColor DarkGray
