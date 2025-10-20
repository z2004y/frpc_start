@echo off
title FRPC Manager
color 0A

:menu
cls
echo ========================================
echo          FRPC Manager v1.0
echo ========================================
echo.
echo  1. Start FRPC
echo  2. Start FRPC (Hide Window)
echo  3. Stop FRPC
echo  4. Check FRPC Status
echo  5. View Config File
echo  6. Test Config File
echo  7. Exit
echo.
echo ========================================
set /p choice=Please select (1-7): 

if "%choice%"=="1" goto start
if "%choice%"=="2" goto start_hidden
if "%choice%"=="3" goto stop
if "%choice%"=="4" goto status
if "%choice%"=="5" goto view_config
if "%choice%"=="6" goto test_config
if "%choice%"=="7" goto end
goto menu

:start
cls
echo ========================================
echo          Starting FRPC
echo ========================================
echo.

set FRPC_PATH=frpc.exe
set CONFIG_PATH=frpc.ini

if not exist "%FRPC_PATH%" (
    echo [ERROR] frpc.exe not found!
    echo Please put this script in the same directory as frpc.exe
    echo.
    pause
    goto menu
)

if not exist "%CONFIG_PATH%" (
    echo [ERROR] frpc.ini not found!
    echo Please make sure the config file exists
    echo.
    pause
    goto menu
)

echo [INFO] Starting FRPC...
echo [CONFIG] %CONFIG_PATH%
echo [TIME] %date% %time%
echo.
echo Press Ctrl+C to stop FRPC
echo ========================================
echo.

"%FRPC_PATH%" -c "%CONFIG_PATH%"

echo.
echo ========================================
echo [INFO] FRPC stopped at %time%
echo ========================================
pause
goto menu

:start_hidden
cls
echo ========================================
echo     Starting FRPC (Hidden Mode)
echo ========================================
echo.

set FRPC_PATH=frpc.exe
set CONFIG_PATH=frpc.ini

if not exist "%FRPC_PATH%" (
    echo [ERROR] frpc.exe not found!
    pause
    goto menu
)

if not exist "%CONFIG_PATH%" (
    echo [ERROR] frpc.ini not found!
    pause
    goto menu
)

echo Creating VBS helper script...
echo Set ws = CreateObject("Wscript.Shell") > frpc_hidden.vbs
echo ws.run "cmd /c frpc.exe -c frpc.ini", 0 >> frpc_hidden.vbs

echo Starting FRPC in hidden mode...
cscript //nologo frpc_hidden.vbs

timeout /t 2 >nul
tasklist /fi "imagename eq frpc.exe" 2>nul | find /i "frpc.exe" >nul
if %errorlevel%==0 (
    echo [SUCCESS] FRPC started in background
    echo [TIME] %date% %time%
    del frpc_hidden.vbs >nul 2>&1
) else (
    echo [ERROR] Failed to start FRPC
    del frpc_hidden.vbs >nul 2>&1
)
echo.
echo Use option 3 to stop FRPC
pause
goto menu

:stop
cls
echo ========================================
echo          Stopping FRPC
echo ========================================
echo.
taskkill /f /im frpc.exe >nul 2>&1
if %errorlevel%==0 (
    echo [SUCCESS] FRPC stopped successfully
) else (
    echo [INFO] FRPC is not running
)
echo.
pause
goto menu

:status
cls
echo ========================================
echo          FRPC Status
echo ========================================
echo.
tasklist /fi "imagename eq frpc.exe" 2>nul | find /i "frpc.exe" >nul
if %errorlevel%==0 (
    echo [STATUS] FRPC is RUNNING
    echo.
    tasklist /fi "imagename eq frpc.exe" /fo table
) else (
    echo [STATUS] FRPC is NOT running
)
echo.
pause
goto menu

:view_config
cls
echo ========================================
echo          Config File Content
echo ========================================
echo.
if exist "frpc.ini" (
    type frpc.ini
) else (
    echo [ERROR] frpc.ini not found!
)
echo.
echo ========================================
pause
goto menu

:test_config
cls
echo ========================================
echo          Testing Config File
echo ========================================
echo.
if not exist "frpc.exe" (
    echo [ERROR] frpc.exe not found!
    pause
    goto menu
)
if not exist "frpc.ini" (
    echo [ERROR] frpc.ini not found!
    pause
    goto menu
)
echo Testing configuration...
echo.
frpc.exe verify -c frpc.ini
echo.
if %errorlevel%==0 (
    echo [SUCCESS] Config file is valid!
) else (
    echo [ERROR] Config file has errors!
)
echo.
pause
goto menu

:end
cls
echo.
echo Thank you for using FRPC Manager!
echo.
timeout /t 2 >nul
exit