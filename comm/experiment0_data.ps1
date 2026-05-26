# 实验 0 - 测试数据：10 对中英平行句
# 用于验证 bge-m3 的 latent 空间是否包含语言结构

$parallelSentences = @(
    @{ Chinese = "你好，世界"; English = "Hello, world" },
    @{ Chinese = "今天天气很好"; English = "The weather is nice today" },
    @{ Chinese = "我喜欢编程"; English = "I like programming" },
    @{ Chinese = "人工智能正在改变世界"; English = "Artificial intelligence is changing the world" },
    @{ Chinese = "猫坐在桌子上"; English = "The cat is sitting on the table" },
    @{ Chinese = "这本书很有趣"; English = "This book is very interesting" },
    @{ Chinese = "努力学习很重要"; English = "Studying hard is very important" },
    @{ Chinese = "科技让生活更美好"; English = "Technology makes life better" },
    @{ Chinese = "我们一起学习"; English = "Let's learn together" },
    @{ Chinese = "未来充满了可能性"; English = "The future is full of possibilities" }
)

$parallelSentences | ConvertTo-Json | Out-File "Z:\Obsidian_Vault\comm\experiment0_data.json" -Encoding UTF8
Write-Host "[OK] 测试数据已生成: 10 对平行句"
