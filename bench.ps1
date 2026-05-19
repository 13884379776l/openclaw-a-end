$prompt = "请用300字详细解释机器学习的基本原理，包括监督学习、无监督学习和强化学习三种方式。"
$results = @()
for ($run = 1; $run -le 3; $run++) {
    Write-Host "=== Run $run ==="
    # Build JSON manually with proper escaping
    $promptEscaped = $prompt -replace '"', '\"' -replace '\', '\\'
    $json = '{"model":"qwen3.6:27b","prompt":"' + $promptEscaped + '","stream":false,"options":{"num_ctx":32768,"temperature":0.7}}'
    # Write as UTF-8 BOM
    [System.IO.File]::WriteAllText("$env:TEMP\run${run}.json", $json, [System.Text.UTF8Encoding]::new($true))
    $raw = curl.exe -s -X POST http://127.0.0.1:11434/api/generate -H "Content-Type: application/json; charset=utf-8" -d "@$env:TEMP\run${run}.json"
    # Parse with net.http
    $reader = [System.IO.StringReader]::new($raw)
    $jsonReader = [System.Json.JsonReader]::new($reader)
    $j = [System.Json.JavaScriptObject]::new($jsonReader)
    # Manual parse since .Json might not be available
    $j = $null
    try {
        $j = $raw | ConvertFrom-Json
    } catch {
        # Fallback: use regex to extract key fields
        Write-Host "  JSON parse failed, using regex..."
        if ($raw -match '"prompt_eval_count":(\d+)') { $pt = [int]$Matches[1] } else { $pt = 0 }
        if ($raw -match '"prompt_eval_duration":(\d+)') { $pdt = [int]$Matches[1] } else { $pdt = 0 }
        if ($raw -match '"eval_count":(\d+)') { $et = [int]$Matches[1] } else { $et = 0 }
        if ($raw -match '"eval_duration":(\d+)') { $edt = [int]$Matches[1] } else { $edt = 0 }
        if ($raw -match '"total_duration":(\d+)') { $td = [int]$Matches[1] } else { $td = 0 }
        $ps = if ($pdt -gt 0) { [math]::Round($pt / ($pdt/1e9), 2) } else { 0 }
        $es = if ($edt -gt 0) { [math]::Round($et / ($edt/1e9), 2) } else { 0 }
        $ts = [math]::Round($td/1e9, 3)
        Write-Host "  Prompt tokens: $pt | Prompt speed: $ps tok/s"
        Write-Host "  Output tokens: $et | Output speed: $es tok/s"
        Write-Host "  Total time: ${ts}s"
        $results += [PSCustomObject]@{ Run=$run; PromptSpeed=$ps; OutputSpeed=$es; PromptTokens=$pt; OutputTokens=$et; TotalTime=$ts }
    }
    if ($j) {
        $ps = if ($j.prompt_eval_duration -gt 0) { [math]::Round($j.prompt_eval_count / ($j.prompt_eval_duration/1e9), 2) } else { 0 }
        $es = if ($j.eval_duration -gt 0) { [math]::Round($j.eval_count / ($j.eval_duration/1e9), 2) } else { 0 }
        $ts = [math]::Round($j.total_duration/1e9, 3)
        Write-Host "  Prompt tokens: $($j.prompt_eval_count) | Prompt speed: $ps tok/s"
        Write-Host "  Output tokens: $($j.eval_count) | Output speed: $es tok/s"
        Write-Host "  Total time: ${ts}s"
        $results += [PSCustomObject]@{ Run=$run; PromptSpeed=$ps; OutputSpeed=$es; PromptTokens=$j.prompt_eval_count; OutputTokens=$j.eval_count; TotalTime=$ts }
    }
    Start-Sleep -Seconds 2
}
Write-Host "`n========== SUMMARY =========="
$results | Format-Table -AutoSize
$avgPS = [math]::Round(($results | Measure-Object -Property PromptSpeed -Average).Average, 2)
$avgOS = [math]::Round(($results | Measure-Object -Property OutputSpeed -Average).Average, 2)
Write-Host "Average Prompt Speed: $avgPS tok/s"
Write-Host "Average Output Speed: $avgOS tok/s"
