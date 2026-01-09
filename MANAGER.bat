@echo off
title Web Terminal Manager
cd /d "%~dp0"

:MENU
cls
echo ===== WEB TERMINAL MANAGER =====
echo.
echo   1. Cai dat va khoi dong (PM2)
echo   2. Khoi dong
echo   3. Dung
echo   4. Khoi dong lai
echo   5. Xem trang thai
echo   6. Xem logs
echo   7. Cai Windows Service
echo   8. Share Terminal to Mobile
echo   0. Thoat
echo.
choice /c 123456780 /n /m "Chon: "

if %errorlevel%==9 goto DO_EXIT
if %errorlevel%==8 goto DO_SHARE
if %errorlevel%==7 goto DO_SERVICE
if %errorlevel%==6 goto DO_LOGS
if %errorlevel%==5 goto DO_STATUS
if %errorlevel%==4 goto DO_RESTART
if %errorlevel%==3 goto DO_STOP
if %errorlevel%==2 goto DO_START
if %errorlevel%==1 goto DO_INSTALL

goto MENU

:DO_INSTALL
cls
echo === CAI DAT VA KHOI DONG ===
echo.
echo [1/5] Kiem tra Node.js...
call node --version
if %errorlevel% neq 0 (
    echo [X] Node.js chua cai!
    echo Tai tai: https://nodejs.org/
    pause
    goto MENU
)
echo.

echo [2/5] Kiem tra PM2...
call pm2 --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Dang cai PM2...
    call npm install -g pm2
)
echo [OK] PM2 OK
echo.

echo [3/5] Cai dat dependencies...
if not exist "node_modules" (
    echo Dang cai npm packages...
    call npm install
    if %errorlevel% neq 0 (
        echo [X] Loi cai dat npm packages!
        pause
        goto MENU
    )
) else (
    echo [OK] Dependencies da cai san
)
echo.

echo [4/5] Khoi dong Web Terminal...
call pm2 delete web-terminal >nul 2>&1
call pm2 start ecosystem.config.js
echo.

echo [5/5] Mo trinh duyet...
timeout /t 2 >nul
start http://localhost:9000
echo.
echo === HOAN TAT ===
echo Web Terminal: http://localhost:9000
echo.
pause
goto MENU

:DO_START
cls
echo Khoi dong...
call pm2 start web-terminal 2>nul
if %errorlevel% neq 0 call pm2 start ecosystem.config.js
echo Done! http://localhost:9000
pause
goto MENU

:DO_STOP
cls
echo Dung...
call pm2 stop web-terminal
echo Done!
pause
goto MENU

:DO_RESTART
cls
echo Khoi dong lai...
call pm2 restart web-terminal
echo Done!
pause
goto MENU

:DO_STATUS
cls
echo === TRANG THAI ===
echo.
call pm2 list
echo.
pause
goto MENU

:DO_LOGS
cls
echo === LOGS ===
echo.
call pm2 logs web-terminal --lines 50 --nostream
echo.
pause
goto MENU

:DO_SERVICE
cls
echo === CAI WINDOWS SERVICE ===
echo.
echo Buoc 1: Cai pm2-windows-service
call npm install -g pm2-windows-service
echo.
echo Buoc 2: Cai dat service
call pm2-service-install -n PM2
echo.
echo Buoc 3: Luu PM2 processes
call pm2 save
echo.
echo === HOAN TAT ===
echo PM2 se tu dong chay khi Windows khoi dong.
echo.
pause
goto MENU

:DO_SHARE
cls
echo ===================================
echo   SHARE TERMINAL TO MOBILE
echo ===================================
echo.
echo Dang mo Share Manager...
echo.
timeout /t 1 >nul
start http://localhost:9000/share-manager.html
echo.
echo [OK] Da mo Share Manager trong browser!
echo.
echo Huong dan:
echo   1. Chon terminal tu danh sach
echo   2. Chon che do: Read-Only hoac Full Access
echo   3. Quet QR code tren dien thoai
echo   4. Terminal se mo ngay tren mobile!
echo.
pause
goto MENU

:DO_EXIT
exit
