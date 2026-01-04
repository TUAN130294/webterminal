@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
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
echo.

set "choice="
set /p "choice=Chon so (0-6): "

if "!choice!"=="1" goto INSTALL
if "!choice!"=="2" goto START
if "!choice!"=="3" goto STOP
if "!choice!"=="4" goto RESTART
if "!choice!"=="5" goto STATUS
if "!choice!"=="6" goto CLEANUP
if "!choice!"=="0" goto EXIT

echo Lua chon khong hop le: [!choice!]
timeout /t 2 >nul
goto MENU

:INSTALL
cls
echo ===============================================
echo   CAI DAT VA KHOI DONG
echo ===============================================
echo.

echo [1/6] Kiem tra Node.js...
node --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] Node.js chua cai!
    echo Tai tu: https://nodejs.org
    goto WAIT_AND_MENU
)
echo [OK] Node.js da co
echo.

echo [2/6] Kiem tra PM2...
pm2 --version >nul 2>&1
if !errorlevel! neq 0 (
    echo PM2 chua co, dang cai dat...
    echo Vui long cho...
    echo.
    call npm install -g pm2 pm2-windows-startup
    if !errorlevel! neq 0 (
        echo [ERROR] Cai PM2 that bai!
        echo Kiem tra Internet va quyen Administrator
        goto WAIT_AND_MENU
    )
    echo [OK] PM2 da cai xong
) else (
    echo [OK] PM2 da co san
)
echo.

echo [3/6] Dung cac processes cu...
pm2 stop all >nul 2>&1
pm2 delete all >nul 2>&1
echo [OK] Done
echo.

echo [4/6] Tao folder logs...
if not exist logs mkdir logs
echo [OK] Done
echo.

echo [5/6] Khoi dong Web Terminal...
pm2 start ecosystem.config.js
set "PM2_RESULT=!errorlevel!"
if !PM2_RESULT! neq 0 (
    echo [ERROR] Khoi dong that bai! Code: !PM2_RESULT!
    echo.
    echo Logs:
    pm2 logs web-terminal --lines 10 --nostream 2>nul
    goto WAIT_AND_MENU
)
echo [OK] Dang khoi dong...
timeout /t 3 >nul
echo.

echo [6/6] Mo trinh duyet...
start "" "http://localhost:9000"
echo [OK] Done
echo.

echo ===============================================
echo   HOAN TAT!
echo ===============================================
echo.
echo Web Terminal: http://localhost:9000
echo.
goto WAIT_AND_MENU

:START
cls
echo Dang khoi dong...
pm2 start web-terminal 2>nul || pm2 start ecosystem.config.js
echo.
echo [OK] Da khoi dong
echo Web: http://localhost:9000
goto WAIT_AND_MENU

:STOP
cls
echo Dang dung...
pm2 stop web-terminal 2>nul
echo.
echo [OK] Da dung
goto WAIT_AND_MENU

:RESTART
cls
echo Dang khoi dong lai...
pm2 restart web-terminal 2>nul || pm2 start ecosystem.config.js
echo.
echo [OK] Da khoi dong lai
echo Web: http://localhost:9000
goto WAIT_AND_MENU

:STATUS
cls
echo ===============================================
echo   TRANG THAI HE THONG
echo ===============================================
echo.
echo --- Node.js ---
node --version 2>nul || echo Chua cai
echo.
echo --- PM2 ---
pm2 --version 2>nul || echo Chua cai
echo.
echo --- Processes ---
pm2 list 2>nul
echo.
echo --- Port 9000 ---
netstat -ano 2>nul | findstr ":9000" || echo Khong co process nao dung port 9000
echo.
goto WAIT_AND_MENU

:CLEANUP
cls
echo ===============================================
echo   DON DEP
echo ===============================================
echo.
echo Dang don dep tat ca processes...
pm2 delete all >nul 2>&1
pm2 kill >nul 2>&1
echo.
echo Dang giai phong port 9000...
for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr ":9000"') do (
    echo Kill PID: %%a
    taskkill /F /PID %%a >nul 2>&1
)
echo.
echo [OK] Da don dep xong!
echo Chon 1 de cai dat lai.
goto WAIT_AND_MENU

:WAIT_AND_MENU
echo.
echo Nhan phim bat ky de quay lai menu...
pause >nul
goto MENU

:EXIT
cls
echo.
echo Tam biet!
echo Web Terminal: http://localhost:9000
echo.
timeout /t 2 >nul
exit /b 0
