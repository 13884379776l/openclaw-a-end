# Context Length Benchmark
# RTX 3090 + qwen3.6:latest
# Date: 2026-06-02 15:34

$RESULTS = @()

# Context sizes: 100, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000
$contextSizes = @(100, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000)

$promptTemplate = "请总结以下内容：{TEXT}\n\n请回答：好的"

Write-Host "=== Context Length Benchmark ==" -ForegroundColor Cyan
Write-Host "Model: qwen3.6:latest (23GB)" -ForegroundColor Yellow
Write-Host "GPU: RTX 3090 (24GB)" -ForegroundColor Yellow
Write-Host "Date: 2026-06-02 15:34" -ForegroundColor Yellow
Write-Host ""

foreach ($ctxSize in $contextSizes) {
    # Generate dummy text
    $dummyText = "测试数据" * ($ctxSize / 2)
    $prompt = $promptTemplate -replace "{TEXT}", $dummyText
    
    Write-Host "Testing: ${ctxSize} tokens..." -ForegroundColor Green
    
    # Measure API call
    $body = @{
        model = "qwen3.6:latest"
        prompt = $prompt
        stream = $false
    } | ConvertTo-Json
    
    $startTime = Get-Date
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 300
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }
    $endTime = Get-Date
    
    $totalMs = ($endTime - $startTime).TotalMilliseconds
    $totalSec = [math]::Round($totalMs / 1000, 2)
    $outputText = $response.response
    $tokenCount = $outputText.Length / 4.5  # Rough estimate
    $tps = if ($totalSec -gt 0) { [math]::Round($tokenCount / $totalSec, 2) } else { 0 }
    
    $result = @{
        Context = $ctxSize
        TotalMs = $totalMs
        OutputTokens = [math]::Round($tokenCount)
        TPS = $tps
    }
    $RESULTS += New-Object PSObject -Property $result
    
    Write-Host "  Context: ${ctxSize} | Time: ${totalSec}s | Output: $([math]::Round($tokenCount)) tokens | TPS: ${tps}" -ForegroundColor White
}

# Save results
$OUTPUT_FILE = "C:\Users\48856\.openclaw\workspace\memory\2026-06-02-context-bench.md"

$md = @"
## Context Length Benchmark Test
**Date:** 2026-06-02 15:34
**Model:** qwen3.6:latest (23GB)
**GPU:** RTX 3090 (24GB)

| Context Length | Total Time (ms) | Output Tokens | TPS |
|----------------|-----------------|---------------|-----|
"@

foreach ($r in $RESULTS) {
    $md += "| $($r.Context) | $($r.TotalMs) | $($r.OutputTokens) | $($r.TPS)`n"
}

$md += @"

## 结果
"@

# Add analysis
if ($RESULTS.Count -ge 2) {
    $minCtx = ($RESULTS | Measure-Object -Property TPS -Minimum).Minimum
    $maxCtx = ($RESULTS | Measure-Object -Property TPS -Maximum).Maximum
    $avgCtx = [math]::Round(($RESULTS | Measure-Object -Property TPS -Average).Average, 2)
    
    $md += "- 最高 TPS: $($maxCtx)"
    $md += "- 最低 TPS: $($minCtx)"
    $md += "- 平均 TPS: $($avgCtx)"
}

$md | Out-File $OUTPUT_FILE -Encoding UTF8
Write-Host ""
Write-Host "Results saved to: $OUTPUT_FILE" -ForegroundColor Cyan
Write-Host "=== Benchmark Complete ===" -ForegroundColor Cyan
