# System Health Check
Write-Host "=== Disk ===" -ForegroundColor Cyan
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $dev = $_.DeviceID
    $free = [math]::Round($_.FreeSpace/1GB, 1)
    $total = [math]::Round($_.Size/1GB, 1)
    Write-Host "$dev  Total: ${total}GB  Free: ${free}GB"
}

Write-Host "`n=== CPU Load ===" -ForegroundColor Cyan
$cpu = (Get-CimInstance Win32_Processor).LoadPercentage
Write-Host "CPU Load: $cpu%"

Write-Host "`n=== GPU ===" -ForegroundColor Cyan
try { nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader 2>$null | ForEach-Object { Write-Host $_ } } catch { Write-Host "nvidia-smi not available" }

Write-Host "`n=== Disk Temp ===" -ForegroundColor Cyan
try {
    $temps = Get-CimInstance MSFT_PhysicalDisk | Select-Object FriendlyName, Temperature | Where-Object { $_.Temperature }
    if ($temps) { $temps | ForEach-Object { Write-Host "$($_.FriendlyName): $($_.Temperature)°C" } }
    else { Write-Host "No disk temp data" }
} catch { Write-Host "No disk temp" }

Write-Host "`n=== Memory ===" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
$totalMem = [math]::Round($os.TotalVisibleMemorySize/1MB, 1)
$freeMem = [math]::Round($os.FreePhysicalMemory/1MB, 1)
Write-Host "Total: ${totalMem}GB  Free: ${freeMem}GB"

Write-Host "`n=== Ollama Version ===" -ForegroundColor Cyan
$ver = curl.exe -s -x http://127.0.0.1:10809 "http://127.0.0.1:11434/version" 2>$null
Write-Host "Ollama: $ver"

Write-Host "`n=== Gateway ===" -ForegroundColor Cyan
$gw = curl.exe -s -x http://127.0.0.1:10809 "http://127.0.0.1:18789/health" 2>$null
Write-Host "Gateway: $gw"
