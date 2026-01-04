# CLAUDE.md

File này cung cấp hướng dẫn cho Claude Code (claude.ai/code) khi làm việc với code trong repository này.

## Tổng quan dự án

Ứng dụng terminal trên nền web, cung cấp truy cập shell qua trình duyệt với hỗ trợ session liên tục. Xây dựng bằng Node.js, Express, Socket.IO và xterm.js.

## Lệnh phát triển

- **Khởi động server:** `npm start` hoặc `node server.js`
- **Cài đặt dependencies:** `npm install`
- **Build Docker image:** `docker build -t web-terminal .`
- **Chạy Docker container:** `docker run -p 3003:3003 -e TERMINAL_TOKEN=your_token web-terminal`

## Kiến trúc

### Các thành phần chính

**server.js** - Server Express + Socket.IO chính
- Phục vụ file frontend tĩnh từ `public/`
- Xác thực kết nối socket qua token
- Quản lý session terminal liên tục bằng node-pty
- Buffer output terminal (giới hạn 50KB) để phát lại khi reconnect

**Pattern Quản lý Session**
- Session được key bằng `sessionId` từ handshake auth của client
- Process PTY tồn tại qua client disconnect trong 30 phút (SESSION_TIMEOUT)
- Khi reconnect, output được buffered sẽ phát lại cho client
- Mỗi socket đăng ký data handler riêng, removed khi disconnect

**Flow Xác thực**
1. Client nhập token ở `/login.html` - lưu vào localStorage
2. Token gửi qua object `auth` của Socket.IO khi handshake
3. Server validate token với `TERMINAL_TOKEN` env var (mặc định: 'erablue2026')
4. Auth thất bại redirect về login page

### Kiến trúc Frontend

**Ba trang HTML:**
- `login.html` - Nhập token, lưu vào localStorage
- `sessions.html` - Chọn session (nút nhanh: claude/work/dev, input tùy chỉnh)
- `index.html` - UI terminal chính với xterm.js

**Protocol Client-Server:**
- Client gửi: `input` (keystrokes), `resize` (kích thước terminal)
- Server emit: `output` (dữ liệu pty)

### Đặc thù Windows

Shell path được hardcode cho Windows Git Bash:
```
C:\Users\15931 - Backend\AppData\Local\Programs\Git\usr\bin\bash.exe
```
Được đặt trong `server.js:49`. Khi sửa cấu hình shell, đảm bảo detection platform hoạt động đúng.

## Files quan trọng

- `server.js` - Express server, xử lý socket, quản lý pty
- `public/index.html` - UI terminal với xterm.js
- `public/login.html` - UI xác thực token
- `public/sessions.html` - Chọn/quản lý session
- `Dockerfile` - Container Alpine Linux với node-pty build deps

## Biến môi trường

- `TERMINAL_TOKEN` - Token xác thực (mặc định: 'erablue2026')
