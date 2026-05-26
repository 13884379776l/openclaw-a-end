# weekly-memory-backup.ps1
# 每周记忆备份到共享盘 + 清理过期 session（脚本确定性执行）

$date = Get-Date -Format "yyyy-MM-dd HH:mm"
$ws = "C:\Users\48856\.openclaw\workspace"
$backupDest = "Z:\Obsidian_Vault\20_Permanent_Knowledge\士兵长_记忆备份"
$sessionsDir = "C:\Users\48856\.openclaw\agents\main\sessions"
$cutoff = (Get-Date).AddDays(-7)

$robocopyResults = @()
$sessionCleanResults = @()

# --- 备份 .md 文件 ---
try {
    $rcOut1 = robocopy.exe $ws $backupDest /MIR /R:1 /W:1 /NP /NFL /NDL /R:1 /XF .git *.log *.json *.usage-cost* 2>&1
    $robocopyResults += "workspace -> 记忆备份: OK"
} catch {
    $robocopyResults += "workspace -> 记忆备份: FAIL ($($_.Exception.Message))"
}

# --- 备份 memory/ ---
try {
    $rcOut2 = robocopy.exe (Join-Path $ws "memory") (Join-Path $backupDest "memory") /MIR /R:1 /W:1 /NP /NFL /NDL /R:1 2>&1
    $robocopyResults += "memory/ -> 记忆备份/memory/: OK"
} catch {
    $robocopyResults += "memory/ -> 记忆备份/memory/: FAIL ($($_.Exception.Message))"
}

# --- 清理过期 session ---
$cleanCount = 0
$keepCount = 0
try {
    $oldSessions = Get-ChildItem $sessionsDir -Recurse -File -ErrorAction SilentlyContinue | 
        Where-Object { $_.LastWriteTime -lt $cutoff -and $_.Name -notlike '*.usage-cost*' -and $_.Name -notlike '*.lock' }
    if ($oldSessions) {
        foreach ($s in $oldSessions) {
            Remove-Item $s.FullName -Force -ErrorAction SilentlyContinue
            $cleanCount++
        }
        $sessionCleanResults += "清理 $cleanCount 个过期 session"
    } else {
        $sessionCleanResults += "无过期 session"
    }
} catch {
    $sessionCleanResults += "清理失败: $($_.Exception.Message)"
}

# --- 写日志 ---
$todayFile = Join-Path $ws "memory\$(Get-Date -Format yyyy-MM-dd).md"
$logBlock = "`n## 每周记忆备份 ($date)``n"
foreach ($r in $robocopyResults) { $logBlock += "- robocopy: $r`n" }
foreach ($r in $sessionCleanResults) { $logBlock += "- session清理: $r`n" }

if (Test-Path $todayFile) {
    $content = Get-Content $todayFile -Raw -Encoding UTF8
    $content += $logBlock
    Set-Content $todayFile -Value $content -Encoding UTF8
} else {
    Set-Content $todayFile -Value $logBlock -Encoding UTF8
}

Write-Output "Backup: $(($robocopyResults | Where-Object { $_ -like "*OK*" }).Count)/$( $robocopyResults.Count) OK"
Write-Output "Sessions cleaned: $cleanCount"
Write-Output "Log: $todayFile"
