# Web Terminal 🖥️

Web Terminal cho phép bạn sử dụng terminal/command line qua trình duyệt web, rất tiện cho việc sử dụng trên điện thoại hoặc chia sẻ với bạn bè.

## ✨ Tính Năng

- ✅ Terminal đầy đủ tính năng trên web
- ✅ Truy cập từ điện thoại/tablet
- ✅ Chia sẻ qua mạng LAN
- ✅ File explorer tích hợp
- ✅ Hỗ trợ Windows (Git Bash/PowerShell)

## 🚀 Cài Đặt Nhanh

### Yêu Cầu
- [Node.js](https://nodejs.org) (v18+)
- Windows với quyền Administrator

### Cách 1: Chạy Trực Tiếp (Đơn Giản Nhất)
```bash
# 1. Clone repo
git clone https://github.com/TUAN130294/webterminal.git
cd webterminal

# 2. Cài dependencies
npm install

# 3. Chạy server
node server.js

# 4. Mở trình duyệt: http://localhost:9000
```

### Cách 2: Dùng Script (Windows)
1. **Chuột phải** vào `START-DIRECT.bat`
2. Chọn **"Run as Administrator"**
3. Truy cập: http://localhost:9000

### Cách 3: Dùng PM2 (Chạy Nền)
```bash
# Cài PM2
npm install -g pm2

# Chạy với PM2
pm2 start ecosystem.config.js

# Xem trạng thái
pm2 list
```

## 📱 Truy Cập Từ Điện Thoại

1. **Tìm IP máy tính:**
   ```bash
   ipconfig
   ```
   Tìm "IPv4 Address" (ví dụ: 192.168.1.100)

2. **Truy cập từ điện thoại:**
   - Kết nối cùng WiFi với máy tính
   - Mở trình duyệt: `http://192.168.1.100:9000`

## 🛠️ Các Script Hỗ Trợ (Windows)

| File | Mục đích |
|------|----------|
| `START-DIRECT.bat` | **Chạy trực tiếp (khuyến nghị)** |
| `pm2-manager.bat` | Quản lý PM2 chi tiết |
| `force-cleanup.bat` | Dọn dẹp khi có lỗi |

## 📁 Cấu Trúc Project

```
webterminal/
├── server.js           # Server chính
├── ecosystem.config.js # Config PM2
├── package.json        # Dependencies
├── public/
│   └── index.html      # Giao diện web
├── logs/               # Thư mục logs
├── START-DIRECT.bat    # Script chạy trực tiếp
├── pm2-manager.bat     # Script quản lý PM2
└── HUONG-DAN.md        # Hướng dẫn tiếng Việt
```

## ⚙️ Cấu Hình

### Đổi Port
Mặc định port 9000. Để đổi:
```bash
# Cách 1: Environment variable
PORT=8080 node server.js

# Cách 2: Sửa ecosystem.config.js
env: {
    PORT: 8080
}
```

## ❌ Khắc Phục Sự Cố

### Lỗi "Port 9000 đã được sử dụng"
```bash
# Windows
taskkill /F /IM node.exe

# Hoặc chạy force-cleanup.bat
```

### Không truy cập được từ điện thoại
1. Kiểm tra cùng mạng WiFi
2. Tắt Windows Firewall tạm thời
3. Kiểm tra IP đúng chưa

## ⚠️ Lưu Ý Bảo Mật

- Chỉ chia sẻ với người tin tưởng
- Không expose ra Internet công cộng
- Sử dụng VPN khi cần thiết

## 📄 License

MIT License

---

**Chúc bạn sử dụng vui vẻ! 🚀**