$token = "72130e8bad51cab66b2602c2b3c9f31790af8b9a46e5ffa1"
$env:OPENCLAW_GATEWAY_TOKEN = $token
$params = Get-Content "C:\Users\48856\.openclaw\workspace\node-test-msg.json" -Raw
$invokeParams = "--node", "soldier", "--command", "system.notify", "--params", $params
openclaw nodes invoke @invokeParams
