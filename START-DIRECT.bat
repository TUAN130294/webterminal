@echo off
chcp 65001 >nul
cd /d "%~dp0"

title Web Terminal - Chạy Trực Tiếp

cls
echo ===============================================
echo      WEB TERMINAL - CHẠY TRỰC TIẾP
echo      (Không cần PM2)
echo ===============================================
echo.
echo Script này sẽ chạy Web Terminal trực tiếp
echo mà không cần PM2 (tránh lỗi quyền truy cập).
echo.
echo Lưu ý: Cửa sổ này phải mở để server chạy.
echo Đóng cửa sổ = dừng server.
echo.
set /p confirm="Bắt đầu? (y/N): "
if /i not "%confirm%"=="y" exit /b 0

echo.
echo [1/3] Kiểm tra Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] Cần cài Node.js từ: https://nodejs.org
    pause
    exit /b 1
)
node --version
echo [✓] Node.js OK

echo [2/3] Dọn dẹp port 9000...
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 >nul

netstat -ano | findstr ":9000" >nul 2>&1
if %errorlevel% equ 0 (
    echo [!] Port 9000 vẫn bận, đang force kill...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":9000"') do (
        taskkill /F /PID %%a >nul 2>&1
    )
    timeout /t 2 >nul
)
echo [✓] Port đã sạch

echo [3/3] Khởi động Web Terminal...
echo.
echo ===============================================
echo      WEB TERMINAL ĐANG CHẠY!
echo ===============================================
echo.
echo Truy cập: http://localhost:9000
echo.
echo Từ điện thoại:
echo   1. Tìm IP máy tính: ipconfig
echo   2. Truy cập: http://[IP]:9000
echo.
echo Nhấn Ctrl+C để dừng server.
echo.
echo ===============================================
echo.

:: Start server directly
node server.js