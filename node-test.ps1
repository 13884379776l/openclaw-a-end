# Node 协议测试脚本
Write-Host "=== Node 协议测试 ===" -ForegroundColor Cyan
Write-Host ""

# 测试 1: Node 状态
Write-Host "[测试 1] Node 状态" -ForegroundColor Yellow
openclaw nodes status
Write-Host ""

# 测试 2: Node 描述
Write-Host "[测试 2] Node 能力描述" -ForegroundColor Yellow
openclaw nodes describe --node 192.168.31.18
Write-Host ""

# 测试 3: 尝试 invoke（列出可用命令）
Write-Host "[测试 3] 测试命令执行" -ForegroundColor Yellow
Write-Host "（跳过，需要查白名单）" -ForegroundColor Gray
Write-Host ""

Write-Host "=== 测试完成 ===" -ForegroundColor Cyan
