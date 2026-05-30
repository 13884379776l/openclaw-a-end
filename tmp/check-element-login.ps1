# 检查 Element Desktop 登录状态
Write-Host "=== Element 配置文件 ==="
Get-ChildItem "C:\Users\48856\AppData\Roaming\Element" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName, Length | Format-Table

Write-Host "=== Element 会话文件 ==="
Get-ChildItem "C:\Users\48856\AppData\Local\element-desktop" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*session*" -or $_.Name -like "*token*" } | Select-Object FullName
