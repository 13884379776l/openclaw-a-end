$pem = "-----BEGIN PRIVATE KEY-----`nMC4CAQAwBQYDK2VwBCIEII8UrvFiw4YIj6zFX0T5e8Poy3/30MjP9zSR4K6JHd1i`n-----END PRIVATE KEY-----"
$jsonPath = "$HOME\.openclaw\openclaw.json"
$config = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json
if (-not ($config.PSObject.Properties.Name -contains 'adapterConfig')) {
    $config | Add-Member -NotePropertyName 'adapterConfig' -NotePropertyValue @{}
}
$config.adapterConfig.devicePrivateKeyPem = $pem
$finalJson = ConvertTo-Json $config -Depth 100 -Compress
[System.IO.File]::WriteAllText($jsonPath, $finalJson)
Write-Host "Written successfully."