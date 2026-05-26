# 实验 0: 验证 bge-m3 的 latent 空间是否包含语言结构
$base = "http://127.0.0.1:11434/api/embeddings"
$sentences = @(
    "Hello world.",
    "I like programming.",
    "The weather is nice today.",
    "AI is changing the world.",
    "The cat sits on the table.",
    "This book is very interesting.",
    "Studying hard is important.",
    "Technology makes life better.",
    "Let us learn together.",
    "The future is full of hope."
)

Write-Host "[实验 0] 验证 bge-m3 的 latent 空间是否包含语言结构"
Write-Host "[$($sentences.Length)] 句子正在编码..."

$embeddings = @()
for ($i = 0; $i -lt $sentences.Length; $i++) {
    $body = @{ model = "bge-m3"; prompt = $sentences[$i] } | ConvertTo-Json
    $emb = Invoke-RestMethod -Uri $base -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ContentType "application/json; charset=utf-8"
    $embeddings += , [double[]]$emb.embedding
    Write-Host "  [$($i+1)/$($sentences.Length)] $($sentences[$i])"
}

# 计算余弦相似度矩阵
$n = $sentences.Length
$sim = New-Object double[,] $n,$n
$sum = 0.0; $count = 0
for ($i = 0; $i -lt $n; $i++) {
    for ($j = $i+1; $j -lt $n; $j++) {
        $dot = 0.0; $na = 0.0; $nb = 0.0
        for ($k = 0; $k -lt 768; $k++) {
            $dot += $embeddings[$i][$k] * $embeddings[$j][$k]
            $na += $embeddings[$i][$k] * $embeddings[$i][$k]
            $nb += $embeddings[$j][$k] * $embeddings[$j][$k]
        }
        $cos = $dot / ( [Math]::Sqrt($na) * [Math]::Sqrt($nb) )
        $sim[$i,$j] = $cos
        $sim[$j,$i] = $cos
        $sum += $cos; $count++
    }
}

$mean = $sum / $count
$max = -1; $min = 2
for ($i = 0; $i -lt $n; $i++) {
    for ($j = 0; $j -lt $n; $j++) {
        if ($i -ne $j) {
            if ($sim[$i,$j] -gt $max) { $max = $sim[$i,$j] }
            if ($sim[$i,$j] -lt $min) { $min = $sim[$i,$j] }
        }
    }
}

Write-Host ""
Write-Host "===== 结果 ===="
Write-Host "平均余弦相似度: $([Math]::Round($mean, 4))"
Write-Host "最大余弦相似度: $([Math]::Round($max, 4))"
Write-Host "最小余弦相似度: $([Math]::Round($min, 4))"

# 判断
if ($mean -gt 0.85) {
    $conclusion = "latent 空间已包含语言结构 (sim > 0.85) - 可以继续实验 1"
} elseif ($mean -gt 0.6) {
    $conclusion = "latent 空间部分包含语言结构 (0.6 < sim < 0.85) - 需要更深入研究"
} else {
    $conclusion = "latent 空间不包含语言结构 (sim < 0.6) - 需要更深层映射"
}
Write-Host ""
Write-Host "结论: $conclusion"

# 保存
$result = @{
    experiment = "0"
    model = "bge-m3"
    sentences = $sentences
    meanCosineSimilarity = [Math]::Round($mean, 4)
    maxCosineSimilarity = [Math]::Round($max, 4)
    minCosineSimilarity = [Math]::Round($min, 4)
    conclusion = $conclusion
    timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
} | ConvertTo-Json -Depth 3
$result | Out-File "C:\Users\48856\.openclaw\workspace\comm\experiment0_result.json" -Encoding UTF8
Write-Host "结果已保存到 experiment0_result.json"
