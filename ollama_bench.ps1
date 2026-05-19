# Ollama Inference Speed Test - A端
Write-Host "=== Ollama Inference Speed Test ===" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)" -ForegroundColor Gray
Write-Host "Model: qwen3.6:latest (Q4_K_M, 36B)" -ForegroundColor Gray
Write-Host "OS: Windows 11 (A端)" -ForegroundColor Gray
Write-Host "GPU: $(if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) { nvidia-smi --query-gpu=name --format=csv,noheader 2>$null | Select-Object -First 1 } else { 'N/A' })" -ForegroundColor Gray
Write-Host ""

# Model info
Write-Host "--- Model Info ---" -ForegroundColor Yellow
try {
    $tags = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags" -Method Get
    foreach ($m in $tags.models) {
        if ($m.name -eq "qwen3.6:latest") {
            Write-Host "  Name: $($m.name)"
            Write-Host "  Size: $([math]::Round($m.size/1GB, 1)) GB"
            Write-Host "  Params: $($m.details.parameter_size)"
            Write-Host "  Format: $($m.details.format)"
            Write-Host "  Family: $($m.details.families -join ', ')"
        }
    }
} catch {
    Write-Host "  Error: $_" -ForegroundColor Red
}

# Helper function
function Test-Inference {
    param(
        [string]$Name,
        [string]$Content,
        [int]$NumPredict,
        [int]$ExpectedMinTokens
    )
    
    Write-Host ""
    Write-Host "--- $Name ($NumPredict tokens max) ---" -ForegroundColor Yellow
    
    $payload = @{
        model = "qwen3.6:latest"
        messages = @(
            @{ role = "user"; content = $Content }
        )
        stream = $false
        options = @{ num_predict = $NumPredict }
    }
    
    try {
        $start = Get-Date
        $resp = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/chat" -Method Post -Body ($payload | ConvertTo-Json -Depth 10) -ContentType "application/json" -TimeoutSec 120
        $end = Get-Date
        $dur = [math]::Round(($end - $start).TotalMilliseconds)
        $tokens = $resp.message.token_count
        
        Write-Host "  Duration: ${dur}ms"
        Write-Host "  Tokens: $tokens"
        if ($dur -gt 0 -and $tokens -gt 0) {
            $tps = [math]::Round($tokens * 1000 / $dur, 2)
            Write-Host "  TPS: $tps"
        }
        if ($tokens -lt $ExpectedMinTokens) {
            Write-Host "  ⚠️ Tokens fewer than expected ($ExpectedMinTokens) - may have stopped early" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Test 1: Short
Test-Inference -Name "Test 1: Short response" -Content "Say hello in one sentence" -NumPredict 64 -ExpectedMinTokens 4

# Test 2: Medium
Test-Inference -Name "Test 2: Medium response" -Content "Explain GPU memory management in 200 words or less" -NumPredict 256 -ExpectedMinTokens 100

# Test 3: Long (may take longer)
Write-Host ""
Write-Host "Test 3: Long response (512 tokens) - may take 30+ seconds..." -ForegroundColor Gray
Test-Inference -Name "Test 3: Long response" -Content "Write a detailed explanation of how transformer models work, covering attention mechanisms, multi-head attention, position encoding, and the decoder architecture. Aim for 400-500 words." -NumPredict 512 -ExpectedMinTokens 200

# GPU info
Write-Host ""
Write-Host "=== GPU Info ===" -ForegroundColor Cyan
try {
    nvidia-smi --query-gpu=name,memory.total,memory.used,memory.free,gpu_util,utilization.memory --format=csv,noheader 2>$null | Format-Table
    Write-Host ""
    Write-Host "--- VRAM Usage ---" -ForegroundColor Yellow
    nvidia-smi --query-compute-apps=pid,used_memory --format=csv 2>$null
} catch {
    Write-Host "  N/A"
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Green
