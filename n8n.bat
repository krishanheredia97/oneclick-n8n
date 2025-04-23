@echo off
setlocal EnableDelayedExpansion

:: ========== USER CONFIGURABLE VARIABLES ==========
set "AUTO_OPEN=true"
set "NGROK_DOMAIN=<your_domain_here>"
set "NGROK_PATH=<your_ngrok_path_here>\ngrok.exe"
set "N8N_PORT=5678"
set "STARTUP_TIMEOUT=7"
:: ==================================================

:: Create a mutex file to ensure single instance
set "MUTEX_FILE=%TEMP%\ngrok_n8n_script.lock"

:: Check if the script is already running
if exist "%MUTEX_FILE%" (
    echo [INFO] Script is already running. Exiting.
    goto end
)

:: Create mutex file
echo Running > "%MUTEX_FILE%"

:: Ensure mutex is removed on script exit
setlocal
call :cleanup_on_exit

:: Check for ngrok executable
if not exist "%NGROK_PATH%" (
    echo [ERROR] Ngrok executable not found at: %NGROK_PATH%
    goto end
)

:: Launch Windows Terminal with two panes: one for ngrok, one for n8n with WEBHOOK_URL
wt ^
    -p "Ngrok" cmd /k "%NGROK_PATH% http --url=%NGROK_DOMAIN% %N8N_PORT%" ^
    ; split-pane -H -p "n8n" cmd /k "set WEBHOOK_URL=https://%NGROK_DOMAIN%/ && n8n start"

:: Wait for ngrok to be ready before opening the browser
timeout /t %STARTUP_TIMEOUT% /nobreak > nul

:: Optional: open formatted URL
if /I "%AUTO_OPEN%"=="true" (
    start https://%NGROK_DOMAIN%/home/workflows
)

:end
:: Remove the mutex file before exiting
if exist "%MUTEX_FILE%" del "%MUTEX_FILE%"
exit /b

:cleanup_on_exit
:: This ensures the mutex is cleaned up even if the script is terminated unexpectedly
if exist "%MUTEX_FILE%" del "%MUTEX_FILE%"
goto :eof