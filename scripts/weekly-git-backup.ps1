# weekly-git-remote-backup.ps1
# 每周 GitHub 远程备份（脚本确定性执行）

$ws = "C:\Users\48856\.openclaw\workspace"
$memoryDir = Join-Path $ws "memory"
$date = Get-Date -Format "yyyy-MM-dd HH:mm"
$weekAgo = (Get-Date).AddDays(-7)

# --- 统计近7天备份情况 ---
$backupLines = Get-ChildItem $memoryDir -Filter "*.md" -Recurse 2>$null | 
    Where-Object { $_.LastWriteTime -ge $weekAgo } |
    Get-Content -Raw -Encoding UTF8 2>$null |
    Select-String "## 本地备份" -AllMatches |
    ForEach-Object { $_.Matches }

$successCount = 0
$failCount = 0
$filesChanged = 0

$backupResults = @()
if ($backupLines -ne $null) {
    foreach ($m in $backupLines) {
        $line = $m.Value
        if ($line -match "commit") {
            if ($line -match "OK") { $successCount++ } else { $failCount++ }
        }
    }
}

# 统计总变更文件数
try {
    Push-Location $ws
    $recentMd = Get-ChildItem $memoryDir -Filter "*.md" -Recurse | Where-Object { $_.LastWriteTime -ge $weekAgo }
    $filesChanged = ($recentMd | Measure-Object).Count
} catch { $filesChanged = 0 }

# --- Git commit ---
try {
    git add -A 2>$null
    $status = git status --porcelain 2>$null
    $changeCount = ($status | Measure-Object).Count
    
    if ($changeCount -eq 0) {
        $gitResult = "skip (clean)"
        $gitHash = "N/A"
    } else {
        $commitMsg = "weekly-summary: $($date) 每周远程备份"
        git commit -m $commitMsg 2>$null
        if ($LASTEXITCODE -eq 0) {
            $gitHash = git rev-parse --short HEAD
            $gitResult = "commit OK ($changeCount files)"
        } else {
            $gitResult = "commit FAILED"
            $gitHash = "N/A"
        }
    }
} catch {
    $gitResult = "git ERROR: $($_.Exception.Message)"
    $gitHash = "N/A"
}

# --- Git push ---
try {
    Push-Location $ws
    $pushEnv = @{ HTTP_PROXY="http://127.0.0.1:10809"; HTTPS_PROXY="http://127.0.0.1:10809" }
    $pushOutput = git push origin master 2>&1 | Select-Object -First 5
    $pushResult = "push OK" -replace "OK", "OK" -replace "N/A", "OK"
    if ($LASTEXITCODE -eq 0) {
        $pushResult = "push OK" 
    } elseif ($LASTEXITCODE -eq 1) {
        $pushResult = "push OK (no new commits)" 
    } else {
        $pushResult = "push FAILED``n$($pushOutput -join "`n")"
    }
} catch {
    $pushResult = "push FAILED: $($_.Exception.Message)"
}

# --- 写总结 ---
$todayFile = Join-Path $memoryDir "$(Get-Date -Format yyyy-MM-dd).md"
$summary = "`n## 每周远程备份总结 ($date)``n- 本周本地备份次数：$successCount``n- 成功：$successCount 次 | 失败：$failCount 次``n- 累计变更文件：$filesChanged 个``n- Commit：$gitResult (哈希: $gitHash)``n- Git push：$pushResult`n"

if (Test-Path $todayFile) {
    $content = Get-Content $todayFile -Raw -Encoding UTF8
    $content += $summary
    Set-Content $todayFile -Value $content -Encoding UTF8
} else {
    Set-Content $todayFile -Value $summary -Encoding UTF8
}

Write-Output "Backup stats: success=$successCount, fail=$failCount, files=$filesChanged"
Write-Output "Git: $gitResult"
Write-Output "Push: $pushResult"
