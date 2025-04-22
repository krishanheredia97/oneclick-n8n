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

:: Launch Windows Terminal with two panes: one for ngrok, one for n8n with WEBHOOK_URL
wt ^
    nt -p "Ngrok" cmd /k "\"%NGROK_PATH%\" http --url=%NGROK_DOMAIN% %N8N_PORT%" ^
    ; split-pane -H -p "n8n" cmd /k "set WEBHOOK_URL=https://%NGROK_DOMAIN%/& n8n start"

:: Wait for ngrok to be ready before opening the browser
timeout /t %STARTUP_TIMEOUT% /nobreak > nul

:: Optional: open formatted URL
if /I "%AUTO_OPEN%"=="true" (
    start https://%NGROK_DOMAIN%/home/workflows
)

:end

ngrok http --url=pipefish-pet-husky.ngrok-free.app 80