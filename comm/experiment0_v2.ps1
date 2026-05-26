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

$allEmbeds = @()
for ($i = 0; $i -lt $sentences.Length; $i++) {
    $body = @{ model = "bge-m3"; prompt = $sentences[$i] } | ConvertTo-Json
    $emb = Invoke-RestMethod -Uri $base -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ContentType "application/json; charset=utf-8"
    $allEmbeds += , $emb.embedding
    Write-Host "  [$($i+1)/$($sentences.Length)] $($sentences[$i])"
}

# 计算余弦相似度（用数组列表）
$n = $sentences.Length
$pairSims = [System.Collections.Generic.List[float]]::new()

for ($i = 0; $i -lt $n; $i++) {
    for ($j = $i+1; $j -lt $n; $j++) {
        $dot = 0.0; $na = 0.0; $nb = 0.0
        for ($k = 0; $k -lt 768; $k++) {
            $dot += $allEmbeds[$i][$k] * $allEmbeds[$j][$k]
            $na += $allEmbeds[$i][$k] * $allEmbeds[$i][$k]
            $nb += $allEmbeds[$j][$k] * $allEmbeds[$j][$k]
        }
        $cos = $dot / ( [Math]::Sqrt($na) * [Math]::Sqrt($nb) )
        $pairSims.Add($cos)
    }
}

$mean = ($pairSims | Measure-Object -Average).Average
$max = ($pairSims | Measure-Object -Maximum).Maximum
$min = ($pairSims | Measure-Object -Minimum).Minimum

Write-Host ""
Write-Host "===== 结果 ===="
Write-Host "平均余弦相似度: $([Math]::Round($mean, 4))"
Write-Host "最大余弦相似度: $([Math]::Round($max, 4))"
Write-Host "最小余弦相似度: $([Math]::Round($min, 4))"

# 判断
if ($mean -gt 0.85) {
    $conclusion = "latent 空间已包含语言结构 (sim > 0.85) - 可以继续实验 1"
} elseif ($mean -gt 0.6) {
    $conclusion = "latent 空间部分包含语言结构 (0.6 < sim < 0.85) - 需要更深层映射"
} else {
    $conclusion = "latent 空间不包含语言结构 (sim < 0.6) - 需要重新编码"
}
Write-Host ""
Write-Host "结论: $conclusion"

# 保存
$result = @{
    experiment = "0"
    model = "bge-m3"
    sentenceCount = $n
    meanCosineSimilarity = [Math]::Round($mean, 4)
    maxCosineSimilarity = [Math]::Round($max, 4)
    minCosineSimilarity = [Math]::Round($min, 4)
    conclusion = $conclusion
    timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
} | ConvertTo-Json -Depth 3
$result | Out-File "C:\Users\48856\.openclaw\workspace\comm\experiment0_result.json" -Encoding UTF8
Write-Host "结果已保存到 experiment0_result.json"
