# pre-backup-check.ps1
# 备份前安全检查：确认 Z 盘、Git、磁盘空间正常

$logFile = "C:\Users\48856\.openclaw\workspace\memory\pre-backup-check.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$results = @()

# 1. Z 盘检查
try {
    $zExists = Test-Path Z:\Obsidian_Vault
    $results += "Z盘: $($if($zExists){'OK'}else{'FAIL'})" -replace '\$\(if\(','','')
} catch {
    $results += "Z盘: FAIL ($($_.Exception.Message))"
}

# 2. Git 状态
try {
    $gitStatus = cd C:\Users\48856\.openclaw\workspace; git status --porcelain 2>&1
    $changes = $gitStatus.Count
    if ($changes -eq 0) { $results += "Git: clean" } else { $results += "Git: $changes 个变更" }
} catch {
    $results += "Git: FAIL ($($_.Exception.Message))"
}

# 3. 磁盘空间
try {
    $cDisk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace
    $cFreeGB = [math]::Round($cDisk / 1GB, 2)
    $results += "C盘空闲: ${cFreeGB} GB"
} catch {
    $results += "磁盘: FAIL"
}

# 4. OpenClaw Gateway
try {
    $r = curl.exe -s http://127.0.0.1:18789/health
    $status = ($r | ConvertFrom-Json).status
    $results += "Gateway: $status"
} catch {
    $results += "Gateway: FAIL"
}

# 输出
foreach ($r in $results) { Write-Output $r }
