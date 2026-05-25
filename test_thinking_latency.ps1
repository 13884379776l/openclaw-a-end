#!/usr/bin/env pwsh
$base = 'http://127.0.0.1:18789/v1'
$token = '[REDACTED]'
$prompt = '请用一句话解释量子纠缠'
$levels = @('off', 'minimal', 'low', 'medium', 'high', 'max')

$results = @()

foreach ($level in $levels) {
    Write-Host "Testing thinking level: $level" -ForegroundColor Cyan
    
    $body = @{
        model    = 'openclaw/default'
        messages = @( @{ role = 'user'; content = $prompt } )
        thinking = @{ level = $level }
    } | ConvertTo-Json -Depth 10

    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type'  = 'application/json'
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $resp = Invoke-RestMethod -Uri ($base + '/chat/completions') -Method Post -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 300
        $sw.Stop()

        $latency_ms = $sw.ElapsedMilliseconds
        $output_tok = $resp.usage.output_tokens
        $total_tok = $resp.usage.total_tokens
        $reason_len = 0
        if ($resp.choices[0].message.reasoning_content) {
            $reason_len = $resp.choices[0].message.reasoning_content.Length
        }
        $resp_text = $resp.choices[0].message.content
        $resp_short = ($resp_text -replace '?
', ' ').Substring(0, [Math]::Min(40, $resp_text.Length))

        $results += [PSCustomObject]@{
            Level     = $level
            Latency_ms = $latency_ms
            OutputTok = $output_tok
            TotalTok  = $total_tok
            ReasonLen = $reason_len
            Resp      = $resp_short
        }

        Write-Host "  OK: ${latency_ms}ms, ${output_tok} tok, reasoning: ${reason_len} chars" -ForegroundColor Green
    } catch {
        $sw.Stop()
        Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Level     = $level
            Latency_ms = $sw.ElapsedMilliseconds
            OutputTok = 'ERR'
            TotalTok  = 'ERR'
            ReasonLen = 0
            Resp      = 'ERROR'
        }
    }

    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "===== SUMMARY =====" -ForegroundColor Yellow
foreach ($r in $results) {
    Write-Host ("  Level: $($r.Level) | Latency: $($r.Latency_ms)ms | Tokens: $($r.OutputTok) | Reasoning: $($r.ReasonLen) | Resp: $($r.Resp)")
}

$out = $results | ConvertTo-Json
$out | Out-File -FilePath 'C:\Users\48856\.openclaw\workspace\memory\thinking_latency_test.json' -Encoding utf8
Write-Host "Saved to memory/thinking_latency_test.json" -ForegroundColor Gray
