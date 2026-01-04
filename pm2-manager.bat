@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: QUAN TRỌNG: CD vào thư mục của bat file
cd /d "%~dp0"

:: ===============================================
::    PM2 MANAGER - WEB TERMINAL
::    Quản lý Web Terminal nhanh chóng
:: ===============================================

title PM2 Manager - Web Terminal

:: Find PM2 location
set "PM2_CMD="
set "PM2_BASE="
set "PM2_FOUND=0"
set "USING_NPX=0"

:: Check if pm2 is in PATH
where pm2 >nul 2>&1
if %errorlevel% equ 0 (
    set "PM2_CMD=pm2"
    set "PM2_BASE=pm2"
    set "PM2_FOUND=1"
    goto FOUND_PM2
)

:: Check common npm global locations with quotes
if exist "%APPDATA%\npm\pm2.cmd" (
    set "PM2_CMD=%APPDATA%\npm\pm2.cmd"
    set "PM2_BASE=%APPDATA%\npm\pm2.cmd"
    set "PM2_FOUND=1"
    goto FOUND_PM2
)

if exist "%USERPROFILE%\AppData\Roaming\npm\pm2.cmd" (
    set "PM2_CMD=%USERPROFILE%\AppData\Roaming\npm\pm2.cmd"
    set "PM2_BASE=%USERPROFILE%\AppData\Roaming\npm\pm2.cmd"
    set "PM2_FOUND=1"
    goto FOUND_PM2
)

:: Check npx pm2
where npx >nul 2>&1
if %errorlevel% equ 0 (
    set "PM2_CMD=npx pm2"
    set "PM2_BASE=npx pm2"
    set "USING_NPX=1"
    set "PM2_FOUND=1"
    goto FOUND_PM2
)

:: PM2 not found - show setup guide
cls
echo ===============================================
echo    PM2 CHƯA ĐƯỢC CÀI ĐẶT!
echo ===============================================
echo.
echo Web Terminal cần PM2 để chạy như Windows Service.
echo.
echo HAI BƯỚC ĐỂ CÀI ĐẶT:
echo.
echo 1. Chuột phải vào file này
echo    [ ] Run as Administrator
echo.
echo 2. Nhấn phím bất kỳ để cài đặt tự động
echo.
echo HOẶC cài đặt thủ công:
echo   npm install -g pm2 pm2-windows-startup
echo.
pause

:: Auto install
cls
echo ===============================================
echo       ĐANG CÀI ĐẶT PM2...
echo ===============================================
echo.
call npm install -g pm2 pm2-windows-startup
echo.
if %errorlevel% equ 0 (
    echo.
    echo [✓] Cài đặt thành công!
    echo.
    echo Nhấn phím bất kỳ để tiếp tục...
    pause >nul
    goto RESTART_BAT
) else (
    echo.
    echo [✗] Cài đặt thất bại!
    echo.
    echo Kiểm tra:
    echo   - Kết nối internet
    echo   - Quyền Administrator
    echo   - Node.js đã được cài đặt
    echo.
    pause
    exit /b 1
)

:FOUND_PM2

:: ===============================================
::           MAIN MENU
:: ===============================================
:MAIN
cls
echo ===============================================
echo      PM2 MANAGER - WEB TERMINAL
echo ===============================================
echo.
echo Trạng thái PM2: %PM2_CMD%
echo.
echo   CÁC CHỨC NĂNH CHÍNH:
echo.
echo   [1] Khởi động Web Terminal
echo   [2] Dừng Web Terminal
echo   [3] Khởi động lại (Restart)
echo   [4] Xem trạng thái (Process list)
echo   [5] Xem logs (50 dòng gần nhất)
echo   [6] Flush logs (Xóa logs cũ)
echo.
echo   [7] Cài đặt làm Windows Service
echo       ← Tự động chạy khi开机
echo.
echo   [8] Hủy Windows Service
echo.
echo   [9] Đổi port (mặc định: 9000)
echo.
echo  [10] Kill/Reset tất cả
echo  [11] Dọn dẹp hoàn toàn (Clean Install)
echo       ← Xóa tất cả, cài lại từ đầu
echo.
echo  [12] Hướng dẫn sử dụng
echo  [13] Chẩn đoán sự cố (Troubleshoot)
echo.
echo   [0] Thoát
echo.
echo ===============================================
echo.

set /p choice="Nhập số (0-13): "

if "%choice%"=="1" goto START
if "%choice%"=="2" goto STOP
if "%choice%"=="3" goto RESTART
if "%choice%"=="4" goto LIST
if "%choice%"=="5" goto LOGS
if "%choice%"=="6" goto FLUSH
if "%choice%"=="7" goto INSTALL_SERVICE
if "%choice%"=="8" goto UNINSTALL_SERVICE
if "%choice%"=="9" goto SET_PORT
if "%choice%"=="10" goto KILL_ALL
if "%choice%"=="11" goto CLEAN_INSTALL
if "%choice%"=="12" goto GUIDE
if "%choice%"=="13" goto TROUBLESHOOT
if "%choice%"=="0" goto EXIT

echo.
echo Lựa chọn không hợp lệ! Nhấn phím bất kỳ...
pause >nul
goto MAIN

:: ===============================================
::           FUNCTIONS
:: ===============================================

:START
cls
echo ===============================================
echo    KHỞI DỘNG WEB TERMINAL
echo ===============================================
echo.

:: Clean up any existing PM2 instance first
echo [Dọn dẹp] Xóa instance cũ nếu có...
%PM2_BASE% delete web-terminal >nul 2>&1

:: Check if port 9000 is already in use
echo [Kiểm tra] Đang kiểm tra port 9000...
netstat -ano | findstr ":9000 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [!] CẢNH BÁO: Port 9000 đã được sử dụng!
    echo.
    echo Danh sách process đang dùng port 9000:
    netstat -ano | findstr ":9000 "
    echo.
    set /p kill="Kill process và tiếp tục? (y/N): "
    if /i not "!kill!"=="y" (
        echo.
        echo Hủy khởi động. Thử:
        echo   - Chọn [9] để đổi port
        echo   - Hoặc dừng process đang dùng port 9000
        echo.
        pause
        goto MAIN
    )

    :: Kill processes on port 9000 more thoroughly
    echo.
    echo [Đang dừng] Đang kill process trên port 9000...
    
    :: Kill all node processes
    taskkill /F /IM node.exe >nul 2>&1
    
    :: Kill PM2 daemon
    %PM2_BASE% kill >nul 2>&1
    
    :: Force kill processes using port 9000
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":9000 "') do (
        taskkill /F /PID %%a >nul 2>&1
    )
    
    timeout /t 5 >nul
    echo [✓] Đã dừng process
    
    :: Double check port is free
    netstat -ano | findstr ":9000 " >nul 2>&1
    if %errorlevel% equ 0 (
        echo [!] Port 9000 vẫn bận! Thử lại sau hoặc đổi port.
        pause
        goto MAIN
    )
)

:: Start the service
echo [Khởi động] Đang start Web Terminal...
%PM2_BASE% start ecosystem.config.js

:: Wait and verify
timeout /t 3 >nul
%PM2_BASE% list | findstr "web-terminal" | findstr "online" >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo [✓] Đã khởi động Web Terminal thành công!
    echo.
    echo Truy cập: http://localhost:9000
    echo.
) else (
    echo.
    echo [✗] Khởi động thất bại hoặc service crashed!
    echo.
    echo Xem chi tiết:
    %PM2_BASE% list
    echo.
    echo Xem logs lỗi:
    %PM2_BASE% logs web-terminal --lines 10 --nostream
    echo.
)
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:STOP
cls
echo ===============================================
echo       DỪNG WEB TERMINAL
echo ===============================================
echo.
%PM2_BASE% stop web-terminal
echo.
echo [✓] Đã dừng Web Terminal
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:RESTART
cls
echo ===============================================
echo     KHỞI ĐỘNG LẠI (RESTART)
echo ===============================================
echo.
%PM2_BASE% restart web-terminal
echo.
echo [✓] Đã khởi động lại Web Terminal
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:LIST
cls
echo ===============================================
echo      TRẠNG THÁI PROCESS
echo ===============================================
echo.
%PM2_BASE% list
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:LOGS
cls
echo ===============================================
echo      LOGS 50 DÒNG GẦN NHẤT
echo ===============================================
echo.
%PM2_BASE% logs web-terminal --lines 50 --nostream
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:FLUSH
cls
echo ===============================================
echo       FLUSH LOGS
echo ===============================================
echo.
echo Xóa tất cả logs cũ...
echo.
%PM2_BASE% flush
echo.
echo [✓] Đã flush logs
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:INSTALL_SERVICE
cls
echo ===============================================
echo   CÀI LÀM WINDOWS SERVICE
echo ===============================================
echo.
echo Điều này sẽ:
echo   - Dọn dẹp tất cả process cũ
echo   - Khởi động Web Terminal
echo   - Cài đặt PM2 Windows Service
echo   - Web Terminal tự động chạy khi开机
echo   - Lưu config hiện tại
echo.
set /p confirm="Tiếp tục? (y/N): "
if /i not "%confirm%"=="y" goto MAIN

:: Check npm exists
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [✗] KHÔNG TÌM THẤY npm!
    echo.
    echo Cài Node.js từ: https://nodejs.org
    echo.
    pause
    goto MAIN
)

echo.
echo [0/6] Đang dọn dẹp hoàn toàn...

:: Kill all node processes first
echo [Dọn dẹp] Đang dừng tất cả Node.js processes...
taskkill /F /IM node.exe >nul 2>&1

:: Kill PM2 daemon
echo [Dọn dẹp] Đang dừng PM2 daemon...
%PM2_BASE% kill >nul 2>&1

:: Wait for processes to fully terminate
timeout /t 5 >nul

:: Check if port is still in use and force kill if needed
netstat -ano | findstr ":9000 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [Dọn dẹp] Port 9000 vẫn bận, đang force kill...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":9000 "') do (
        taskkill /F /PID %%a >nul 2>&1
    )
    timeout /t 3 >nul
    
    :: Final check
    netstat -ano | findstr ":9000 " >nul 2>&1
    if %errorlevel% equ 0 (
        echo [✗] KHÔNG THỂ DỌN DẸP PORT 9000!
        echo.
        echo Port vẫn bị chiếm bởi:
        netstat -ano | findstr ":9000 "
        echo.
        echo Hãy:
        echo   1. Restart máy tính
        echo   2. Hoặc chọn [9] để đổi port khác
        echo   3. Hoặc chạy force-cleanup.bat
        echo.
        pause
        goto MAIN
    )
)

echo [✓] Đã dọn dẹp hoàn toàn

echo [1/6] Đang kiểm tra config...

:: Check file exists first
if not exist "ecosystem.config.js" (
    echo [✗] ecosystem.config.js KHÔNG TỒN TẠI!
    echo.
    echo Đang tạo file config mới...
    call :CREATE_CONFIG
    echo [✓] Đã tạo config mới
    goto SKIP_CONFIG_CHECK
)

:: Validate config syntax using temp file for reliable error detection
node -e "try { require('./ecosystem.config.js'); console.log('VALID'); } catch(e) { console.log('ERROR: ' + e.message); process.exit(1); }" > "%TEMP%\config_check.txt" 2>&1
findstr /C:"VALID" "%TEMP%\config_check.txt" >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] ecosystem.config.js KHÔNG HỢP LỆ!
    echo.
    type "%TEMP%\config_check.txt"
    echo.
    echo Đang tạo lại config...
    call :CREATE_CONFIG
    echo [✓] Đã tạo config mới
)
del "%TEMP%\config_check.txt" >nul 2>&1

:SKIP_CONFIG_CHECK
echo [✓] Config hợp lệ

echo [2/6] Đang khởi động Web Terminal...
%PM2_BASE% start ecosystem.config.js

:: Wait longer for startup
echo [Chờ] Đang chờ service khởi động...
timeout /t 5 >nul

:: Check if started successfully
%PM2_BASE% list | findstr "web-terminal" | findstr "online" >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Đã start thành công
    
    :: Double check by testing the port
    timeout /t 2 >nul
    netstat -ano | findstr ":9000.*LISTENING" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [✓] Port 9000 đang listen
    ) else (
        echo [!] Port 9000 không listen - có thể có vấn đề
    )
) else (
    echo [!] Start có vấn đề, xem logs...
    %PM2_BASE% logs web-terminal --lines 10 --nostream
    echo.
    echo Tiếp tục cài đặt service (có thể tự sửa sau)...
)

echo [3/6] Đang cài đặt pm2-windows-startup...
npm install -g pm2-windows-startup >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] Cài pm2-windows-startup thất bại!
    echo.
    echo Kiểm tra: Internet, Administrator rights
    echo.
    pause
    goto MAIN
)
echo [✓] Đã cài pm2-windows-startup

echo [4/6] Đang cài Windows Service...
if %USING_NPX% equ 1 (
    npx pm2-startup install >nul 2>&1
) else (
    pm2-startup install >nul 2>&1
)
if %errorlevel% neq 0 (
    echo [✗] Cài Windows Service thất bại!
    echo.
    echo Cần Administrator rights!
    echo.
    pause
    goto MAIN
)
echo [✓] Đã cài Windows Service

echo [5/6] Đang lưu config...
%PM2_BASE% save >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] Lưu config thất bại!
    echo.
    pause
    goto MAIN
)
echo [✓] Đã lưu config

echo [6/6] Đang khởi động lại để kiểm tra...
%PM2_BASE% restart web-terminal >nul 2>&1
timeout /t 3 >nul

:: Final verification
%PM2_BASE% list | findstr "web-terminal" | findstr "online" >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Service đang chạy tốt
) else (
    echo [!] Service có vấn đề - xem logs để debug
)

echo.
echo ===============================================
echo [✓] HOÀN TẤT CÀI ĐẶT!
echo ===============================================
echo.
echo Web Terminal giờ sẽ:
echo   - Tự động chạy khi Windows开机
echo   - Tự động restart nếu crash
echo.
echo Truy cập: http://localhost:9000
echo.
echo Kiểm tra: nhấn [4] xem status
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:UNINSTALL_SERVICE
cls
echo ===============================================
echo      HỦY WINDOWS SERVICE
echo ===============================================
echo.
echo CẢNH BÁO: Web Terminal sẽ KHÔNG tự
echo          chạy khi开机 nữa!
echo.
set /p confirm="Bạn có chắc? (y/N): "
if /i not "%confirm%"=="y" goto MAIN

echo.
if %USING_NPX% equ 1 (
    npx pm2-startup uninstall
) else (
    pm2-startup uninstall
)
%PM2_BASE% delete all
%PM2_BASE% save
echo.
echo [✓] Đã hủy Windows Service
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:SET_PORT
cls
echo ===============================================
echo       ĐỔI PORT
echo ===============================================
echo.
%PM2_BASE% list
echo.
set /p new_port="Nhập port mới (8000-9999, hoặc Enter để giữ nguyên 9000): "
if "!new_port!"=="" set "new_port=9000"

:: Validate port
echo !new_port!| findstr /r "^[0-9][0-9][0-9][0-9]$" >nul
if errorlevel 1 (
    echo.
    echo [✗] Port không hợp lệ! Phải từ 1000-9999
    echo.
    pause
    goto MAIN
)

:: Update ecosystem.config.js
(
echo module.exports = {
echo     apps: [{
echo         name: 'web-terminal',
echo         script: 'server.js',
echo         instances: 1,
echo         autorestart: true,
echo         watch: false,
echo         max_memory_restart: '1G',
echo         env: {
echo             NODE_ENV: 'production',
echo             PORT: !new_port!
echo         },
echo         error_file: 'logs/error.log',
echo         out_file: 'logs/out.log',
echo         log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
echo     }]
echo };
) > ecosystem.config.js

echo.
echo [✓] Đã cập nhật port thành !new_port!
echo.
echo Khởi động lại để áp dụng?
set /p confirm="Khởi động lại? (y/N): "
if /i "%confirm%"=="y" (
    %PM2_BASE% restart web-terminal
    echo.
    echo [✓] Đã khởi động lại
    echo.
    echo Truy cập: http://localhost:!new_port!
)
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:KILL_ALL
cls
echo ===============================================
echo      KILL/RESET TẤT CẢ
echo ===============================================
echo.
echo CẢNH BÁO: Dừng và xóa TẤT CẢ PM2 processes!
echo.
set /p confirm="Bạn có chắc? (y/N): "
if /i not "%confirm%"=="y" goto MAIN

echo.
%PM2_BASE% delete all
%PM2_BASE% save
echo.
echo [✓] Đã xóa tất cả processes
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:CLEAN_INSTALL
cls
echo ===============================================
echo      DỌN DẸP HOÀN TOÀN (CLEAN INSTALL)
echo ===============================================
echo.
echo CẢNH BÁO: Điều này sẽ:
echo   - Xóa TẤT CẢ PM2 processes và config
echo   - Hủy Windows Service (nếu có)
echo   - Kill tất cả Node.js processes
echo   - Xóa logs cũ
echo   - Cài đặt lại từ đầu
echo.
echo Chỉ dùng khi gặp vấn đề nghiêm trọng!
echo.
set /p confirm="BẠN CÓ CHẮC CHẮN? (yes/no): "
if /i not "%confirm%"=="yes" goto MAIN

echo.
echo [1/8] Đang hủy Windows Service...
if %USING_NPX% equ 1 (
    npx pm2-startup uninstall >nul 2>&1
) else (
    pm2-startup uninstall >nul 2>&1
)
echo [✓] Đã hủy service

echo [2/8] Đang xóa tất cả PM2 processes...
%PM2_BASE% delete all >nul 2>&1
%PM2_BASE% kill >nul 2>&1
echo [✓] Đã xóa PM2 processes

echo [3/8] Đang kill tất cả Node.js processes...
taskkill /F /IM node.exe >nul 2>&1
echo [✓] Đã kill Node.js processes

echo [4/8] Đang force kill processes trên port 9000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":9000 " 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)
echo [✓] Đã kill port 9000

echo [5/8] Đang xóa logs cũ...
if exist "logs" (
    del /Q logs\*.log >nul 2>&1
)
echo [✓] Đã xóa logs

echo [6/8] Đang tạo lại config...
call :CREATE_CONFIG
echo [✓] Đã tạo config mới

echo [7/8] Đang chờ hệ thống ổn định...
timeout /t 5 >nul
echo [✓] Hệ thống đã ổn định

echo [8/8] Đang test khởi động...
%PM2_BASE% start ecosystem.config.js >nul 2>&1
timeout /t 3 >nul

%PM2_BASE% list | findstr "web-terminal" | findstr "online" >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Test thành công!
    %PM2_BASE% stop web-terminal >nul 2>&1
) else (
    echo [!] Test có vấn đề - xem logs để debug
)

echo.
echo ===============================================
echo [✓] DỌN DẸP HOÀN TẤT!
echo ===============================================
echo.
echo Hệ thống đã được reset hoàn toàn.
echo.
echo BƯỚC TIẾP THEO:
echo   - Chọn [7] để cài Windows Service
echo   - Hoặc chọn [1] để khởi động thủ công
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:GUIDE
cls
echo ===============================================
echo       HƯỚNG DẪN SỬ DỤNG
echo ===============================================
echo.
echo 1. LẦN CHẠY ĐẦU (First time setup):
echo    - Chọn [7] để cài Windows Service
echo    - Web Terminal tự chạy khi开机
echo.
echo 2. NẾU GẶP VẤN ĐỀ:
echo    - [11] Dọn dẹp hoàn toàn (Clean Install)
echo    - Sau đó chọn [7] để cài lại
echo.
echo 3. KHỞI ĐỘNG/Stop:
echo    - [1] Khởi động
echo    - [2] Dừng
echo    - [3] Restart
echo.
echo 4. XEM TRẠNG THÁI:
echo    - [4] Process list
echo    - [5] Logs
echo.
echo 5. QUẢN LÝ:
echo    - [6] Flush logs (khi logs quá lớn)
echo    - [10] Kill tất cả (khi bị lỗi)
echo    - [11] Dọn dẹp hoàn toàn (reset hệ thống)
echo.
echo 6. PORT:
echo    - [9] Đổi port (mặc định: 9000)
echo.
echo 7. TRUY CẤP:
echo    - Mở trình duyệt
echo    - http://localhost:9000
echo.
echo 8. CHIA SẺ VỚI BẠN BÈ:
echo    - Cài Windows Service ([7])
echo    - Chia sẻ IP:9000 qua mạng LAN
echo    - Hoặc dùng ngrok để public ra internet
echo.
echo ===============================================
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:TROUBLESHOOT
cls
echo ===============================================
echo       CHẨN ĐOÁN SỰ CỐ
echo ===============================================
echo.
echo [1/6] Kiểm tra PM2 installation...
where pm2 >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] PM2 đã cài đặt
    pm2 --version
) else (
    echo [✗] PM2 CHƯA cài đặt!
)
echo.

echo [2/6] Kiểm tra Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Node.js đã cài đặt
    node --version
) else (
    echo [✗] Node.js CHƯA cài đặt!
)
echo.

echo [3/6] Kiểm tra port 9000...
netstat -ano | findstr ":9000 " >nul 2>&1
if %errorlevel% equ 0 (
    echo [!] Port 9000 ĐANG được sử dụng:
    netstat -ano | findstr ":9000 "
    echo.
    echo → GỢI Ý: Chọn [1] và chọn 'y' để kill process
) else (
    echo [✓] Port 9000 trống (available)
)
echo.

echo [4/6] Kiểm tra PM2 processes...
%PM2_BASE% list
echo.

echo [5/6] Kiểm tra ecosystem.config.js...
if exist "ecosystem.config.js" (
    node -e "try { require('./ecosystem.config.js'); console.log('[✓] Config hợp lệ'); } catch(e) { console.log('[✗] Config LỖI:', e.message); }"
) else (
    echo [✗] File ecosystem.config.js KHÔNG TỒN TẠI!
)
echo.

echo [6/6] Logs gần nhất (nếu có)...
if exist "logs\error-0.log" (
    echo === ERROR LOG (10 dòng cuối) ===
    powershell -Command "Get-Content logs\error-0.log -Tail 10 -ErrorAction SilentlyContinue"
    echo.
)
if exist "logs\out-0.log" (
    echo === OUTPUT LOG (10 dòng cuối) ===
    powershell -Command "Get-Content logs\out-0.log -Tail 10 -ErrorAction SilentlyContinue"
)
echo.

echo ===============================================
echo       GỢI Ý KHẮC PHỤC
echo ===============================================
echo.
echo Nếu service không start:
echo   1. Kiểm tra port 9000 có bị chiếm không
echo   2. Chọn [10] để reset tất cả PM2 processes
echo   3. Chọn [1] để start lại
echo.
echo Nếu service crash ngay lập tức:
echo   - Xem logs phía trên để tìm lỗi
echo   - Thường do port conflict (EADDRINUSE)
echo   - Chọn [9] để đổi sang port khác
echo.
echo Nếu config lỗi:
echo   - Xóa file ecosystem.config.js
echo   - Chọn [1] để tạo lại
echo.
echo ===============================================
echo.
echo Nhấn phím bất kỳ để quay lại menu...
pause >nul
goto MAIN

:EXIT
cls
echo ===============================================
echo       ĐÃ THOÁT
echo ===============================================
echo.
echo Web Terminal vẫn chạy nếu đã cài Service.
echo.
timeout /t 2 >nul
exit /b 0

:RESTART_BAT
:: Restart this batch file
echo.
echo Starting PM2 Manager...
timeout /t 2 >nul
start "" "%~f0"
exit /b 0

:CREATE_CONFIG
:: Create default ecosystem.config.js
(
echo module.exports = {
echo     apps: [{
echo         name: 'web-terminal',
echo         script: 'server.js',
echo         instances: 1,
echo         exec_mode: 'fork',
echo         autorestart: true,
echo         watch: false,
echo         max_memory_restart: '1G',
echo         restart_delay: 5000,
echo         max_restarts: 10,
echo         min_uptime: '10s',
echo         env: {
echo             NODE_ENV: 'production',
echo             PORT: 9000
echo         },
echo         error_file: 'logs/error.log',
echo         out_file: 'logs/out.log',
echo         log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
echo         merge_logs: true,
echo         kill_timeout: 5000
echo     }]
echo };
) > ecosystem.config.js
goto :eof
