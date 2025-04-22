@echo off
setlocal EnableDelayedExpansion
:: ========== USER CONFIGURABLE VARIABLES ==========
set "AUTO_OPEN=true"
set "NGROK_DOMAIN=your_domain_here"
set "NGROK_PATH=your_ngrok_path_here"
set "N8N_PORT=5678"
set "STARTUP_TIMEOUT=7"
:: ==================================================

:: Check for ngrok executable
if not exist "%NGROK_PATH%" (
    echo [ERROR] Ngrok executable not found at: %NGROK_PATH%
    goto end
)

:: Check if the processes are already running
tasklist /FI "WINDOWTITLE eq Ngrok*" | find "cmd.exe" > nul
if not errorlevel 1 (
    echo Ngrok is already running. Skipping launch.
    goto check_n8n
)

:: Start ngrok in its own window (with /B flag to start without creating a new window)
start "Ngrok" /B cmd /k "title Ngrok && "%NGROK_PATH%" http %N8N_PORT% --domain=%NGROK_DOMAIN%"

:check_n8n
:: Check if n8n is already running
tasklist /FI "WINDOWTITLE eq n8n*" | find "cmd.exe" > nul
if not errorlevel 1 (
    echo n8n is already running. Skipping launch.
    goto browser_open
)

:: Wait a moment for ngrok to start
timeout /t 2 /nobreak > nul

:: Start n8n in its own window with the environment variable set
start "n8n" /B cmd /k "title n8n && set WEBHOOK_URL=https://%NGROK_DOMAIN%/ && n8n start"

:browser_open
:: Wait for services to be ready before opening the browser
timeout /t %STARTUP_TIMEOUT% /nobreak > nul

:: Optional: open formatted URL
if /I "%AUTO_OPEN%"=="true" (
    start https://%NGROK_DOMAIN%/home/workflows
)

echo Script completed successfully.
echo Press any key to exit...
pause > nul

:end