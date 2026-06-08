@echo off
:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Administrator privileges confirmed.
) else (
    echo [ERROR] Please right-click and "Run as Administrator".
    pause
    exit /b
)

set SERVICE_NAME=OpenClawGateway
set EXE_PATH=C:\Users\48856\AppData\Roaming\npm\openclaw.cmd
set APP_ARGS=gateway start

echo Installing %SERVICE_NAME%...
:: Check if nssm is installed, if not, try to download or warn
where nssm >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] NSSM not found in PATH.
    echo Please install NSSM first or let me know so I can provide a download link.
    pause
    exit /b
)

nssm install %SERVICE_NAME% "%EXE_PATH%" %APP_ARGS%
nssm set %SERVICE_NAME% AppDirectory "C:\Users\48856\.openclaw\workspace"
nssm set %SERVICE_NAME% Description "OpenClaw Gateway - Core Service for AI Agent"
nssm set %SERVICE_NAME% StartAutomatic

echo.
echo [SUCCESS] OpenClaw Gateway service installed successfully!
echo Starting service...
nssm start %SERVICE_NAME%
pause
