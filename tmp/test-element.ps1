[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$r = Invoke-WebRequest -Uri 'https://update.element.io/element-desktop/setup/win64' -OutFile 'C:\Users\48856\Downloads\ElementSetup-Test.exe' -Proxy 'http://127.0.0.1:10809' -UseBasicParsing -TimeoutSec 120
$r.StatusDescription
Get-Item 'C:\Users\48856\Downloads\ElementSetup-Test.exe' | Select-Object Length
