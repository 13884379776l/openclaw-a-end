$bins = @("/usr/bin/free","/usr/bin/ps","/usr/bin/nvidia-smi","/usr/bin/ollama","/usr/bin/df","/usr/bin/ping","/usr/bin/env","/usr/bin/ls","/usr/bin/cat","/usr/bin/pwd","/usr/bin/node","/usr/bin/git","/usr/bin/curl","/usr/bin/mkdir")
foreach ($b in $bins) {
    $r = openclaw approvals allowlist add --node ubuntu-s $b 2>&1
    if ($r -match "Pattern") { Write-Host "OK: $b" } else { Write-Host "FAIL: $b - $r" }
    Start-Sleep -Milliseconds 1000
}
