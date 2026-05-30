# 测试代理 HTTPS 能力
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
$proxy = New-Object System.Net.WebProxy("http://127.0.0.1:10809")

Write-Host "=== 测试 httpbin.org ==="
try {
    $r1 = Invoke-WebRequest "https://httpbin.org/ip" -Proxy $proxy -UseBasicParsing -TimeoutSec 30
    Write-Host "HTTPBIN: $r1.StatusCode - $r1.StatusDescription"
    $r1.Content.Trim()
} catch {
    Write-Host "HTTPBIN FAILED: $($_.Exception.InnerException.Message)"
    Write-Host "Inner: $($_.Exception.Message)"
}

Write-Host "=== 测试 Google ==="
try {
    $r2 = Invoke-WebRequest "https://www.google.com" -Method Head -Proxy $proxy -UseBasicParsing -TimeoutSec 30
    Write-Host "GOOGLE: $r2.StatusCode - $r2.StatusDescription"
} catch {
    Write-Host "GOOGLE FAILED: $($_.Exception.InnerException.Message)"
    Write-Host "Inner: $($_.Exception.Message)"
}

Write-Host "=== 测试 update.element.io ==="
try {
    $r3 = Invoke-WebRequest "https://update.element.io/element-desktop/setup/win64" -Proxy $proxy -UseBasicParsing -TimeoutSec 30
    Write-Host "ELEMENT: $r3.StatusCode - $r3.StatusDescription"
} catch {
    Write-Host "ELEMENT FAILED: $($_.Exception.InnerException.Message)"
    $inner = $_.Exception.InnerException
    if ($inner) { Write-Host "Inner: $inner.Message"; Write-Host "HResult: $inner.HResult" }
    else { Write-Host "Inner: (none)"; Write-Host "Web: $($_.Exception.Message)" }
}
