$body = @{model='qwen3.6:27b';prompt='.';stream=$false;options=@{keep_alive='10m'}} | ConvertTo-Json
$result = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/generate' -Method Post -ContentType 'application/json' -Body $body
$result | ConvertTo-Json
