@echo off
echo --- 测试 1 ---
for /f "tokens=1-4 delims=/ " %%a in ("%%date%%") do set YYYY=%%a&set MM=%%b&set DD=%%c
setlocal enabledelayedexpansion
for /f "tokens=1-2 delims=:." %%a in ("%%time%%") do set start_hh=%%a&set start_mm=%%b
for %%i in (1 2 3) do (
    echo --- 测试 %%i ---
    curl -s http://localhost:11434/api/generate -d "{\"model\":\"qwen3.6\",\"prompt\":\"用一句话回答：1+1等于几？\",\"stream\":false}" > %temp%\gpu_test_%i%.json
    echo done
)
pause
