# Node exec 白名单批量添加
$bins = @(
    "/usr/bin/uname",
    "/usr/bin/hostname",
    "/usr/bin/uptime",
    "/usr/bin/free",
    "/usr/bin/ps",
    "/usr/bin/ls",
    "/usr/bin/cat",
    "/usr/bin/env",
    "/usr/bin/node",
    "/usr/bin/git",
    "/usr/bin/curl",
    "/usr/bin/nvidia-smi",
    "/usr/bin/ollama",
    "/usr/bin/ping",
    "/usr/bin/df",
    "/usr/bin/pwd",
    "/usr/bin/mkdir",
    "/usr/bin/whoami",
    "/usr/bin/ip"
)
foreach ($bin in $bins) {
    $result = openclaw approvals allowlist add --node 192.168.31.18 $bin 2>&1
    Write-Host "$bin -> $result"
    Start-Sleep -Milliseconds 500
}
Write-Host "Done"
