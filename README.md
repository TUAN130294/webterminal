# Web Terminal 🖥️

Terminal trên trình duyệt web với tích hợp Claude Code Sessions. Truy cập terminal từ điện thoại, tablet hoặc bất kỳ thiết bị nào.

## ✨ Tính Năng

- 🖥️ Terminal đầy đủ tính năng trên web (xterm.js)
- 🤖 Tích hợp Claude Code Sessions - resume session dễ dàng
- 🎯 Hỗ trợ nhiều AI Profiles: Claude, Agy, GLM, Codex
- 📁 Directory picker - chọn thư mục làm việc
- 📱 Truy cập từ điện thoại/tablet qua mạng LAN
- 🔄 Tự động chạy với Windows (PM2 Service)
- ⚡ Không cần đăng nhập - mở là dùng

## 🚀 Cài Đặt

### Yêu Cầu
- [Node.js](https://nodejs.org) v18+
- [Git](https://git-scm.com) (cho Git Bash)
- Windows với quyền Administrator

### 1 Click Setup
```bash
# Clone repo
git clone https://github.com/TUAN130294/webterminal.git
cd webterminal

# Cài dependencies
npm install
```

Sau đó chạy **MANAGER.bat** → Bấm **1**

## 🛠️ Quản Lý - MANAGER.bat

```
===== WEB TERMINAL MANAGER =====

  1. Cài đặt và khởi động (PM2)
  2. Khởi động
  3. Dừng
  4. Khởi động lại
  5. Xem trạng thái
  6. Xem logs
  7. Cài Windows Service
  0. Thoát
```

### Cài Windows Service (Tự động chạy khi boot)
1. Chạy **MANAGER.bat** as Administrator
2. Bấm **7** - Cài Windows Service
3. PM2 sẽ tự khởi động cùng Windows

## 💻 Sử Dụng

1. Truy cập: **http://localhost:9000**
2. Sidebar trái hiển thị Claude Sessions
3. Bấm **+ New Terminal** hoặc click session để resume
4. Chọn thư mục → Chọn AI Profile → Confirm

### AI Profiles
| Profile | Mô tả |
|---------|-------|
| 🤖 Claude | Claude Code mặc định |
| 🧠 Agy | Antigravity mode |
| 🧬 GLM | GLM mode |
| 📜 Codex | Codex mode |
| 💻 Bash Only | Terminal thuần, không AI |

## 📱 Truy Cập Từ Điện Thoại

1. Tìm IP máy tính: `ipconfig`
2. Kết nối cùng WiFi
3. Truy cập: `http://<IP>:9000`

## 📁 Cấu Trúc

```
webterminal/
├── server.js              # Express + Socket.IO server
├── ecosystem.config.js    # PM2 config
├── package.json
├── public/
│   └── index.html         # Frontend (xterm.js)
├── logs/                   # PM2 logs
├── MANAGER.bat            # 🚀 Quản lý chính
└── CLAUDE.md              # Hướng dẫn cho Claude Code
```

## 🔧 Cấu Hình

### Đổi Port
Sửa `ecosystem.config.js`:
```javascript
env: {
    PORT: 9000  // Đổi port ở đây
}
```

### Đổi User Profile Path
Sửa `server.js` dòng 53:
```javascript
const ACTUAL_USER_HOME = 'C:\\Users\\YOUR_USERNAME';
```

## ❌ Khắc Phục Sự Cố

### "No sessions found"
- Bình thường nếu chưa có Claude history
- Bấm **+ New Terminal** để tạo mới

### Terminal không hiển thị
1. Kiểm tra PM2: `pm2 list`
2. Xem logs: `pm2 logs web-terminal`
3. Restart: `pm2 restart web-terminal`

### Lỗi khi chạy CCS
- Đảm bảo Git đã cài và trong PATH
- Kiểm tra `CLAUDE_CODE_GIT_BASH_PATH` trong server.js

## 🛡️ Bảo Mật

- Chỉ sử dụng trong mạng LAN tin cậy
- Không expose ra Internet công cộng
- Sử dụng VPN nếu cần truy cập từ xa

## 📄 License

MIT License

---

**Chạy `MANAGER.bat` → Bấm 1 → Xong! 🚀**
