@echo off
title Web Terminal Manager
cd /d "%~dp0"

:MENU
cls
echo ===== WEB TERMINAL MANAGER =====
echo.
echo   1. Khoi dong (node truc tiep)
echo   2. Dung
echo   3. Xem trang thai
echo   0. Thoat
echo.
choice /c 1230 /n /m "Chon: "

if %errorlevel%==4 goto DO_EXIT
if %errorlevel%==3 goto DO_STATUS
if %errorlevel%==2 goto DO_STOP
if %errorlevel%==1 goto DO_START

goto MENU

:DO_START
cls
echo === KHOI DONG WEB TERMINAL ===
echo.
echo Dang kiem tra port 9000...
for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr ":9000" ^| findstr "LISTENING"') do (
    echo Dang kill process %%a tren port 9000...
    taskkill /F /PID %%a >nul 2>&1
)
echo.
echo Dang khoi dong server...
echo Server se chay trong cua so nay. Dong cua so = dung server.
echo.
echo Mo trinh duyet: http://localhost:9000
echo.
timeout /t 2 >nul
start http://localhost:9000
echo ============================================
echo.
node server.js
pause
goto MENU

:DO_STOP
cls
echo === DUNG SERVER ===
echo.
for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr ":9000" ^| findstr "LISTENING"') do (
    echo Dang kill process %%a...
    taskkill /F /PID %%a >nul 2>&1
)
call pm2 stop web-terminal >nul 2>&1
call pm2 delete web-terminal >nul 2>&1
echo Done!
pause
goto MENU

:DO_STATUS
cls
echo === TRANG THAI ===
echo.
echo --- Port 9000 ---
netstat -ano | findstr ":9000" | findstr "LISTENING"
if %errorlevel% neq 0 echo Khong co process nao chay tren port 9000
echo.
echo --- PM2 ---
call pm2 list 2>nul
echo.
pause
goto MENU

:DO_EXIT
exit
