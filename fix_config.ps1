$base64Body = "MC4CAQAwBQYDK2VwBCIEII8UrvFiw4YIj6zFX0T5e8Poy3/30MjP9zSR4K6JHd1i"
$pemString = "-----BEGIN PRIVATE KEY-----`n$base64Body`n-----END PRIVATE KEY-----"
$jsonPath = "$HOME\.openclaw\openclaw.json"
$config = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json
if (-not $config.adapterConfig) {
    $config | Add-Member -MemberType NoteProperty -Name 'adapterConfig' -Value @{}
}
$config.adapterConfig.devicePrivateKeyPem = $pemString
$finalJson = ConvertTo-Json $config -Depth 100
[System.IO.File]::WriteAllText($jsonPath, $finalJson)
Write-Host "Pure overwrite complete."