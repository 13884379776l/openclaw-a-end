# daily-backup.ps1
# 每日本地+共享盘备份（脚本确定性执行，不依赖LLM推理）

$ws = "C:\Users\48856\.openclaw\workspace"
$backupDest = "Z:\Obsidian_Vault\20_Permanent_Knowledge\士兵长_记忆备份"
$date = Get-Date -Format "yyyy-MM-dd HH:mm"

# --- Git commit ---
try {
    Push-Location $ws
    $status = git status --porcelain 2>&1
    $changeCount = ($status | Measure-Object).Count
    
    if ($changeCount -eq 0) {
        $gitResult = "skip (clean)"
    } else {
        git add -A 2>&1
        $commitMsg = "daily-backup: $($date)"
        git commit -m $commitMsg 2>&1
        if ($LASTEXITCODE -eq 0) {
            $gitHash = git rev-parse --short HEAD
            $gitResult = "commit OK ($changeCount files, $gitHash)"
        } else {
            $gitResult = "commit FAILED"
        }
    }
} catch {
    $gitResult = "git ERROR: $($_.Exception.Message)"
}

# --- robocopy ---
$robocopyCmd = "robocopy.exe"
$robocopyArgs = @($ws, $backupDest, "/MIR", "/R:1", "/W:1", "/NP", "/NFL", "/NDL", "/R:1")
try {
    $robocopyOutput = & $robocopyCmd $robocopyArgs 2>&1
    $robocopyResult = "sync OK"
} catch {
    $robocopyResult = "sync FAILED: $($_.Exception.Message)"
}

# --- 写日志 ---
$todayFile = Join-Path (Join-Path $ws "memory") "$(Get-Date -Format yyyy-MM-dd).md"
$logLine = "## 本地备份 ($date)``n- Git：$gitResult``n- 备份同步：$robocopyResult`n"

if (Test-Path $todayFile) {
    $content = Get-Content $todayFile -Raw -Encoding UTF8
    $content += "`n$logLine"
    Set-Content $todayFile -Value $content -Encoding UTF8
} else {
    Set-Content $todayFile -Value $logLine -Encoding UTF8
}

Write-Output "Git: $gitResult"
Write-Output "Sync: $robocopyResult"
Write-Output "Log: $todayFile"
