@echo off
set TASKNAME=OpenClaw Node
set CMDLINE=cmd /c C:\Users\48856\.openclaw\node.cmd
schtasks /create /tn "%TASKNAME%" /tr "%CMDLINE%" /sc onlogon /ru "%USERNAME%" /f
if %ERRORLEVEL% equ 0 (
    echo SUCCESS: Task created
) else (
    echo FAILED with errorlevel %ERRORLEVEL%
)
