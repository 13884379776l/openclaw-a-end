# Power limits: GPU0 (3090) 85% = 255W, GPU1 (5070 Ti) = max 380W

$ErrorActionPreference = "SilentlyContinue"

# ── Power limit config (85% of TDP, nvidia-smi uses W not mW) ──
$gpuPowerLimits = @{
    0 = 255   # GPU0 (5070 Ti): 300W * 0.85 ≈ 255W (max 380W for 5070 Ti, 300W default cap)
    1 = 315   # GPU1 (3090): 370W * 0.85 ≈ 315W (max 300W for 3090)
}


# ── Fan curve config ──
function Get-TargetFan {
    param($temp, $gpuIndex)
    
    # 5070 Ti has higher min fan due to hardware constraint (~32-44% floor)
    $minFan = if ($gpuIndex -eq 1) { 40 } else { 30 }
    
    if ($temp -ge 42) { return 100 }
    elseif ($temp -ge 38) { return 80 + [int](($temp - 38) / 4.0 * 20) }
    elseif ($temp -ge 34) { return 60 + [int](($temp - 34) / 4.0 * 20) }
    elseif ($temp -ge 30) {
        $lo = if ($gpuIndex -eq 0) { 40 } else { 50 }
        return $lo + [int](($temp - 30) / 4.0 * (if ($gpuIndex -eq 0) { 20 } else { 10 }))
    }
    else { return $minFan }
}

# ── Initialize ──
Write-Host "[INIT] Scanning GPUs..." -ForegroundColor Cyan
$gpus = Get-CimInstance -Namespace "root\wmi" -ClassName "NVP60600_SensorData" -ErrorAction SilentlyContinue

if (-not $gpus) {
    Write-Host "[ERROR] pynvml not found. Install pynvml via: pip install pynvml" -ForegroundColor Red
    Write-Host "[WARN] Running in monitor-only mode (fan control disabled)" -ForegroundColor Yellow
    
    # Monitor-only mode: use nvidia-smi for read-only
    Write-Host "" -NoNewline
    while ($true) {
        $output = nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,memory.used,memory.total,fan.speed --format=csv,noheader 2>$null
        if ($output) {
            Write-Host "`n--- $(Get-Date -Format 'HH:mm:ss') ---" -ForegroundColor Green
            Write-Host $output -ForegroundColor White
        }
        Start-Sleep -Seconds 10
    }
}

# ── Set power limits (85% of TDP) ──
Write-Host "[SET] Applying power limits (85% of TDP)..." -ForegroundColor Cyan
foreach ($gpuIdx in $gpuPowerLimits.Keys) {
    try {
        $plW = $gpuPowerLimits[$gpuIdx] / 1000
        $result = nvidia-smi -i $gpuIdx -pl $gpuPowerLimits[$gpuIdx] 2>$null
        Write-Host "  [GPU$gpuIdx] Power limit: $plW W" -ForegroundColor Green
    } catch {
        Write-Host "  [GPU$gpuIdx] Power limit failed: $_" -ForegroundColor Red
    }
}
Write-Host "Starting smart fan + power control..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop." -ForegroundColor Gray
Write-Host "" -NoNewline

$counter = 0

while ($true) {
    $counter++
    $line = ""
    
    # Use nvidia-smi to get real-time data (reliable across all NVIDIA driver versions)
    $smiOutput = nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw,fan.speed --format=csv,noheader,nounits 2>$null
    
    if ($smiOutput) {
        $lines = $smiOutput -split "`n" | Where-Object { $_.Trim() }
        foreach ($lineStr in $lines) {
            $parts = $lineStr -split ","
            if ($parts.Count -ge 7) {
                $idx = $parts[0].Trim()
                $name = $parts[1].Trim()
                $temp = [double]$parts[2].Trim()
                $gpuUtil = [double]$parts[3].Trim()
                $memUsed = [double]$parts[4].Trim() / 1024
                $memTot = [double]$parts[5].Trim() / 1024
                $power = [double]$parts[6].Trim()
                $fanSpeed = [double]$parts[7].Trim()
                
                $target = Get-TargetFan $temp $idx
                
                $status = "[GPU$idx] $name | $temp°C | Fan $fanSpeed% (target $target%) | GPU $gpuUtil% | MEM $memUsed/$memTot GB | $powerW"
                
                if ($temp -ge 40) {
                    Write-Host $status -ForegroundColor Yellow
                } else {
                    Write-Host $status -ForegroundColor White
                }
            }
        }
    }
    
    # Verbose status every 60 seconds
    if ($counter % 6 -eq 0) {
        Write-Host "`n[INFO] $(Get-Date -Format 'HH:mm:ss') - Status check" -ForegroundColor Cyan
    }
    
    Start-Sleep -Seconds 10
}
