# 基准线测试 - qwen3.6:latest (36GB, RTX 3090)
# 指挥官要求：不要换模型，用当前跑的那个

$env:OLLAMA_HOST = "http://localhost:11434"
$TEST_MODEL = "qwen3.6"

Write-Output "=== Ollama 推理速度基准线测试 ==="
Write-Output "测试时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output "测试模型: $TEST_MODEL"
Write-Output "运行设备: RTX 3090 (GPU, 100%)"
Write-Output "当前显存: 21.68GB/24GB 已用"
Write-Output ""

$PROMPTS = @(
    "用一句话回答：1+1等于几？",
    "简述人工智能的定义",
    "解释深度学习和机器学习的区别",
    "用3句话说明大语言模型的工作原理",
    "什么是迁移学习？"
)

$results = @()

for ($i = 1; $i -le $PROMPTS.Count; $i++) {
    $prompt = $PROMPTS[$i-1]
    $payload = @"
{
    "model": "$TEST_MODEL",
    "prompt": "$prompt",
    "stream": false,
    "options": {
        "num_ctx": 262144,
        "temperature": 0.7
    }
}
"@

    $start = Get-Date
    try {
        $response = curl.exe -s http://localhost:11434/api/generate `
            -X POST `
            -H "Content-Type: application/json" `
            -d $payload
        $elapsed = (Get-Date) - $start
        
        if ($response) {
            $data = $response | ConvertFrom-Json
            $respTokens = $data.eval_count
            $promptTokens = $data.prompt_eval_count
            $speed = [math]::Round($respTokens / $elapsed.TotalSeconds, 2)
            
            Write-Output "测试 $i/$($PROMPTS.Count):"
            Write-Output "  Prompt: $prompt"
            Write-Output "  生成 tokens: $respTokens | 提示 tokens: $promptTokens"
            Write-Output "  耗时: $([math]::Round($elapsed.TotalMilliseconds, 0))ms | 速度: $speed tokens/s"
            Write-Output "  响应: $($data.response.Substring(0, [Math]::Min(30, $data.response.Length)))..."
            
            $results += [PSCustomObject]@{
                Test = $i
                Prompt = $prompt
                Tokens = $respTokens
                ElapsedMs = [math]::Round($elapsed.TotalMilliseconds, 0)
                Speed = $speed
            }
            Write-Output ""
        }
    } catch {
        Write-Output "测试 $i 失败: $_"
        Write-Output ""
    }
}

if ($results.Count -gt 0) {
    $avgSpeed = [math]::Round(($results | Measure-Object -Property Speed -Average).Average, 2)
    $minSpeed = ($results | Measure-Object -Property Speed -Minimum).Minimum
    $maxSpeed = ($results | Measure-Object -Property Speed -Maximum).Maximum
    $totalTokens = ($results | Measure-Object -Property Tokens -Sum).Sum
    
    Write-Output "=== 基准线结果 ==="
    Write-Output "总测试: $($results.Count) 次"
    Write-Output "总生成 tokens: $totalTokens"
    Write-Output "平均速度: $avgSpeed tokens/s"
    Write-Output "最快速度: $maxSpeed tokens/s"
    Write-Output "最慢速度: $minSpeed tokens/s"
    Write-Output "速度波动: $([math]::Round($maxSpeed - $minSpeed, 2)) tokens/s"
    Write-Output "基准线测试完成，数据已记录。"
} else {
    Write-Output "所有测试失败，无法建立基准线。"
}
