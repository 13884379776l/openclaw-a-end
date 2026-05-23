$gpus = Get-CimInstance Win32_VideoController
foreach ($g in $gpus) {
    Write-Host "GPU: $($g.Name) VRAM: $([math]::Round($g.AdapterRAM/1MB)) MB"
}
$cpus = Get-CimInstance Win32_Processor
foreach ($c in $cpus) {
    Write-Host "CPU: $($c.Name) Cores: $($c.NumberOfCores) Threads: $($c.NumberOfLogicalProcessors)"
}
$rams = Get-CimInstance Win32_PhysicalMemory
$totalGB = 0
foreach ($r in $rams) { $totalGB += [math]::Round($r.Capacity/1MB) }
Write-Host "RAM Total: ${totalGB} MB"
