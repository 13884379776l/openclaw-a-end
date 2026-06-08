# Hikvision Camera - Verify connection
$camIP = "192.168.31.203"
$user = "13884379776"
$pass = "13884379776"

Write-Host "`n=== 海康摄像头连接测试 ===" -ForegroundColor Cyan
Write-Host "IP: $camIP" -ForegroundColor Gray
Write-Host "账号: $user" -ForegroundColor Gray

# Test ISAPI REST API (ISAPI requires Digest Auth)
$isapiUrls = @(
    "/ISAPI/System/capabilities",
    "/ISAPI/System/deviceInfo", 
    "/ISAPI/Streaming/channels/0"
)

foreach($url in $isapiUrls){
    try{
        $req = [System.Net.HttpWebRequest]::Create("http://$camIP"+$url)
        $req.Timeout = 5000  
        $req.Method = "GET"
        
        # ISAPI uses Digest Authentication
        $auth = [System.Text.Encoding]::UTF8.GetBytes("${user}:${pass}")
        $encoded = [Convert]::ToBase64String($auth)
        # For digest auth, we need to let server challenge us first, so try without auth header
        # Just check if the URL responds at all
        
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $content = $reader.ReadToEnd()
        Write-Host ("ISAPI "+$url+": OK") -ForegroundColor Green
        if($content.Length -lt 600){
            Write-Host ("    " + $content) -ForegroundColor DarkGray
        } else {
            Write-Host ("    [" + $content.Substring(0,300) + "...]") -ForegroundColor DarkGray
        }
        $reader.Close()
        $resp.Close()  
    } catch {
        $msg = $_.Exception.Message
        if($msg.Contains("401")){
            Write-Host ("ISAPI "+$url+": 401 Unauthorized (需要正确凭证)") -ForegroundColor Yellow
        } else {
            Write-Host ("ISAPI "+$url+": FAIL - "+$msg) -ForegroundColor Red
        }
    }
}

# RTSP URL format for verification
Write-Host "`n=== RTSP 流地址（可复制到 VLC/ffplay）===" -ForegroundColor Yellow
$c1 = 'rtsp://' + $user + ':' + $pass + '@' + $camIP + ':554/Streaming/Channels/101'
$c2 = 'rtsp://' + $user + ':' + $pass + '@' + $camIP + ':554/Streaming/Channels/102'
$c3 = 'http://' + $camIP + ':80/onvif/device-service'
Write-Host ("主码流: " + $c1) -ForegroundColor Cyan
Write-Host ("子码流: " + $c2) -ForegroundColor Cyan
Write-Host ("ONVIF: " + $c3) -ForegroundColor Cyan

Write-Host "`n=== Done ===" -ForegroundColor Gray
