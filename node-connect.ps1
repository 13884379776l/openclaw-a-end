# OpenClaw Node - A-Soldier-Node to B Gateway
$ErrorActionPreference = "Stop"
Write-Host "=== OpenClaw Node Connection ==="
Write-Host "Target: 192.168.31.18:18789"
Write-Host "Name: A-Soldier-Node"
Write-Host ""
openclaw node run --host 192.168.31.18 --port 18789 --display-name "A-Soldier-Node"
