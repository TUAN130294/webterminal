@echo off
chcp 65001 >nul
cd /d "%~dp0"

title Force Cleanup - Web Terminal

echo ===============================================
echo      FORCE CLEANUP - WEB TERMINAL
echo ===============================================
echo.
echo CẢNH BÁO: Script này sẽ:
echo   - Kill TẤT CẢ Node.js processes
echo   - Kill TẤT CẢ PM2 processes  
echo   - Force kill processes trên port 9000
echo   - Reset PM2 hoàn toàn
echo.
set /p confirm="Tiếp tục? (y/N): "
if /i not "%confirm%"=="y" exit /b 0

echo.
echo [1/6] Kill tất cả Node.js processes...
taskkill /F /IM node.exe >nul 2>&1
echo [✓] Done

echo [2/6] Kill PM2 daemon...
pm2 kill >nul 2>&1
echo [✓] Done

echo [3/6] Force kill processes trên port 9000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":9000 " 2^>nul') do (
    echo Killing PID %%a
    taskkill /F /PID %%a >nul 2>&1
)
echo [✓] Done

echo [4/6] Chờ hệ thống ổn định...
timeout /t 5 >nul
echo [✓] Done

echo [5/6] Kiểm tra port 9000...
netstat -ano | findstr ":9000" >nul 2>&1
if %errorlevel% equ 0 (
    echo [!] Port 9000 vẫn bận:
    netstat -ano | findstr ":9000"
    echo.
    echo Thử restart máy tính nếu vẫn không được.
) else (
    echo [✓] Port 9000 đã trống
)

echo [6/6] Test khởi động server...
echo Đang test server trong 3 giây...
timeout /t 1 >nul
start /B node server.js
timeout /t 3 >nul

netstat -ano | findstr ":9000.*LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Server test thành công!
    taskkill /F /IM node.exe >nul 2>&1
) else (
    echo [!] Server test thất bại
)

echo.
echo ===============================================
echo      CLEANUP HOÀN TẤT!
echo ===============================================
echo.
echo Bây giờ bạn có thể:
echo   1. Chạy pm2-manager.bat
echo   2. Chọn [7] để cài Windows Service
echo.
pause