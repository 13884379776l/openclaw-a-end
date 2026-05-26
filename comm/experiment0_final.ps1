# Experiment 0: Verify bge-m3 latent space for language structure
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

Write-Host "[EXP 0] Verify bge-m3 latent space for language structure"
Write-Host "[$($sentences.Length)] sentences encoding..."

$allEmbeds = @()
for ($i = 0; $i -lt $sentences.Length; $i++) {
    $body = @{ model = "bge-m3"; prompt = $sentences[$i] } | ConvertTo-Json
    $emb = Invoke-RestMethod -Uri $base -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ContentType "application/json; charset=utf-8"
    $allEmbeds += , $emb.embedding
    Write-Host "  [$($i+1)/$($sentences.Length)] $($sentences[$i])"
}

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
Write-Host "===== RESULTS ==="
Write-Host "Mean cosine similarity: $([Math]::Round($mean, 4))"
Write-Host "Max cosine similarity: $([Math]::Round($max, 4))"
Write-Host "Min cosine similarity: $([Math]::Round($min, 4))"

if ($mean -gt 0.85) {
    $conclusion = "Latent space ALREADY contains language structure (sim > 0.85) - proceed to Exp 1"
} elseif ($mean -gt 0.6) {
    $conclusion = "Latent space PARTIALLY contains language structure (0.6 < sim < 0.85) - need deeper mapping"
} else {
    $conclusion = "Latent space DOES NOT contain language structure (sim < 0.6) - need re-encoding"
}
Write-Host ""
Write-Host "Conclusion: $conclusion"

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
Write-Host "Results saved to experiment0_result.json"
