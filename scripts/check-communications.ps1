# check-communications.ps1
# 通讯文件定时查收（脚本确定性执行）

$commDir = "Z:\Obsidian_Vault\comm"
$workDir = "C:\Users\48856\.openclaw\workspace"
$memoryDir = Join-Path $workDir "memory"
$date = Get-Date -Format "yyyy-MM-dd HH:mm"

$results = @()

# --- 检查 Z 盘和 comm 目录 ---
if (-not (Test-Path $commDir)) {
    $results += "comm目录不可达: $commDir"
    foreach ($r in $results) { Write-Output $r }
    exit 0
}

# --- 读取 b2a.md ---
$b2aFile = Join-Path $commDir "b2a.md"
if (Test-Path $b2aFile) {
    try {
        $b2aContent = Get-Content $b2aFile -Raw -Encoding UTF8 -ErrorAction Stop
        $b2aModified = (Get-Item $b2aFile).LastWriteTime
        $results += "b2a.md: OK (最后修改: $($b2aModified.ToString('yyyy-MM-dd HH:mm')), 长度: $($b2aContent.Length) chars)"
    } catch {
        $results += "b2a.md: 读取失败 - $($_.Exception.Message)"
    }
} else {
    $results += "b2a.md: 文件不存在"
}

# --- 读取 a2b.md ---
$a2bFile = Join-Path $commDir "a2b.md"
if (Test-Path $a2bFile) {
    try {
        $a2bContent = Get-Content $a2bFile -Raw -Encoding UTF8 -ErrorAction Stop
        $a2bModified = (Get-Item $a2bFile).LastWriteTime
        $results += "a2b.md: OK (最后修改: $($a2bModified.ToString('yyyy-MM-dd HH:mm')), 长度: $($a2bContent.Length) chars)"
    } catch {
        $results += "a2b.md: 读取失败 - $($_.Exception.Message)"
    }
} else {
    $results += "a2b.md: 文件不存在"
}

# --- 检查其他通讯文件 ---
$commFiles = Get-ChildItem $commDir -Filter "*_M*.md" -ErrorAction SilentlyContinue
if ($commFiles) {
    $results += "最新通讯文件: $($commFiles | Sort-Object Name -Descending | Select-Object -First 1).Name ($((Get-Item ($commFiles | Sort-Object Name -Descending | Select-Object -First 1)).LastWriteTime.ToString('yyyy-MM-dd HH:mm')))"
}

# --- 写摘要 ---
$todayFile = Join-Path $memoryDir "$(Get-Date -Format yyyy-MM-dd).md"
$logBlock = "`n## 通讯查收 ($date)``n"
foreach ($r in $results) { $logBlock += "- $r`n" }

if (Test-Path $todayFile) {
    $content = Get-Content $todayFile -Raw -Encoding UTF8
    $content += $logBlock
    Set-Content $todayFile -Value $content -Encoding UTF8
} else {
    Set-Content $todayFile -Value $logBlock -Encoding UTF8
}

Write-Output "通讯状态: $(($results | Where-Object { $_ -like "*OK*" }).Count)/$( $results.Count) 正常"
foreach ($r in $results) { Write-Output $r }
