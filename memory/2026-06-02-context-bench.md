## Context Length Benchmark Test
**Date:** 2026-06-02 15:34
**Model:** qwen3.6:latest (23GB)
**GPU:** RTX 3090 (24GB)
**Method:** chat API, 2 runs per size, averaged
**Fixed prompt:** 要求模型输出至少1000字

| Context (tokens) | Avg Time (ms) | Output Tokens | TPS |
|--|--|--|--|
|0|37967|59|1.55
|500|26855|26|0.97
|2000|73975|200|2.70
|4000|90120|59|0.65
|6000|76338|52|0.68
|8000|77274|57|0.74
|10000|46728|83|1.78
|15000|48279|13|0.27
|30000|61937|44|0.71