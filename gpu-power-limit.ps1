# GPU Power Limit Script
# Target: 3090 -> 300W, 5070 Ti -> 250W
# Run as Administrator: powershell -ExecutionPolicy Bypass -File gpu-power-limit.ps1

Write-Host "========== GPU Power Limit Adjust ==========" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Check admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] Must run as Administrator!" -ForegroundColor Red
    Write-Host "Close this window, right-click -> Run as Administrator" -ForegroundColor Yellow
    exit 1
}

# Target power limits
$targets = @(
    @{ UUID = "GPU-30d9ab08-2254-92be-4ed2-fc7f7ad13c1d"; Name = "RTX 3090"; TargetW = 300 },
    @{ UUID = "GPU-925cff72-dc04-3019-f192-8b50540f7d01"; Name = "RTX 5070 Ti"; TargetW = 250 }
)

foreach ($gpu in $targets) {
    Write-Host "" -NoNewline
    Write-Host "[SET] $($gpu.Name) -> $($gpu.TargetW)W" -ForegroundColor Yellow
    
    # Apply power limit
    $result = & nvidia-smi --gpu-id $gpu.UUID --power-limit=$($gpu.TargetW) 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "[OK] $($gpu.Name) power limit set to $($gpu.TargetW)W" -ForegroundColor Green
    } else {
        Write-Host "[WARN] $($gpu.Name): $result" -ForegroundColor Yellow
        Write-Host "[WARN] Exit code: $exitCode" -ForegroundColor Yellow
    }
}

# Verify
Write-Host "" -NoNewline
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Current Power Limits" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

& nvidia-smi --query-gpu=name,power.limit,enforced.power.limit --format=csv

Write-Host "" -ForegroundColor Green
Write-Host "[DONE] Script finished." -ForegroundColor Green
Write-Host "NOTE: Power limit resets after driver reload. See persistence section below." -ForegroundColor Yellow
