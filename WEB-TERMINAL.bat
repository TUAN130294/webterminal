@echo off
chcp 65001 >nul
cd /d "%~dp0"

:MENU
cls
echo ===============================================
echo      WEB TERMINAL MANAGER
echo ===============================================
echo.
echo   1. Cai dat va khoi dong (1 Click)
echo   2. Khoi dong
echo   3. Dung
echo   4. Khoi dong lai
echo   5. Xem trang thai
echo   6. Don dep
echo   0. Thoat
echo.
echo ===============================================

set /p choice=Chon so: 

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto START
if "%choice%"=="3" goto STOP
if "%choice%"=="4" goto RESTART
if "%choice%"=="5" goto STATUS
if "%choice%"=="6" goto CLEANUP
if "%choice%"=="0" exit
goto MENU

:INSTALL
cls
echo Dang cai dat...
echo.

node --version
if errorlevel 1 (
    echo Loi: Node.js chua cai!
    pause
    goto MENU
)

taskkill /F /IM node.exe >nul 2>&1

npm install -g pm2 pm2-windows-startup
if errorlevel 1 (
    echo Loi: Cai PM2 that bai!
    pause
    goto MENU
)

pm2 kill >nul 2>&1
timeout /t 2 >nul

pm2 start ecosystem.config.js
if errorlevel 1 (
    echo Loi: Khoi dong that bai!
    pause
    goto MENU
)

start http://localhost:9000

echo.
echo Hoan tat! Truy cap: http://localhost:9000
pause
goto MENU

:START
cls
pm2 start web-terminal 2>nul
if errorlevel 1 pm2 start ecosystem.config.js
echo Da khoi dong
pause
goto MENU

:STOP
cls
pm2 stop web-terminal 2>nul
echo Da dung
pause
goto MENU

:RESTART
cls
pm2 restart web-terminal 2>nul
if errorlevel 1 pm2 start ecosystem.config.js
echo Da khoi dong lai
pause
goto MENU

:STATUS
cls
echo Node.js:
node --version
echo.
echo PM2:
pm2 --version
echo.
echo Processes:
pm2 list
echo.
echo Port 9000:
netstat -ano | findstr ":9000"
echo.
pause
goto MENU

:CLEANUP
cls
pm2 kill >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1
echo Da don dep
pause
goto MENU