# Web Terminal 🖥️

Web Terminal cho phép bạn sử dụng terminal/command line qua trình duyệt web, rất tiện cho việc sử dụng trên điện thoại hoặc chia sẻ với bạn bè.

## ✨ Tính Năng

- ✅ Terminal đầy đủ tính năng trên web
- ✅ Truy cập từ điện thoại/tablet
- ✅ Chia sẻ qua mạng LAN
- ✅ File explorer tích hợp
- ✅ Tự động chạy khi Windows khởi động
- ✅ Tự động restart nếu crash

## 🚀 Cài Đặt Siêu Nhanh - 1 CLICK!

### Yêu Cầu
- [Node.js](https://nodejs.org) (v18+)
- Windows với quyền Administrator

### 1 Click Setup (Khuyến Nghị)
1. **Double-click** vào `WEB-TERMINAL.bat`
2. Chọn **[1]** - Cài đặt và khởi động
3. Truy cập: http://localhost:9000

**Xong! Chỉ 1 file duy nhất! 🎉**

### Cách Thủ Công (Nếu Cần)
```bash
# 1. Clone repo
git clone https://github.com/TUAN130294/webterminal.git
cd webterminal

# 2. Cài dependencies
npm install

# 3. Cài PM2
npm install -g pm2 pm2-windows-startup

# 4. Chạy với PM2
pm2 start ecosystem.config.js

# 5. Cài Windows Service
pm2-startup install
pm2 save

# 6. Truy cập: http://localhost:9000
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

## 🛠️ Quản Lý

### Web Terminal Manager (Khuyến Nghị)
Chạy `WEB-TERMINAL.bat`:
- **[1]** 🚀 Cài đặt và khởi động (1 Click)
- **[2]** ▶️ Khởi động
- **[3]** ⏹️ Dừng
- **[4]** 🔄 Khởi động lại
- **[5]** 📊 Xem trạng thái
- **[6]** 📝 Xem logs
- **[7]** 🛠️ Cài Windows Service
- **[9]** 🧹 Dọn dẹp hoàn toàn

### Lệnh PM2 Cơ Bản
```bash
pm2 list                    # Xem trạng thái
pm2 stop web-terminal       # Dừng
pm2 start web-terminal      # Khởi động
pm2 restart web-terminal    # Khởi động lại
pm2 logs web-terminal       # Xem logs
```

## 📁 Cấu Trúc Project (Đã Dọn Dẹp)

```
webterminal/
├── server.js                      # Server chính
├── ecosystem.config.js            # Config PM2
├── package.json                   # Dependencies
├── public/index.html              # Giao diện web
├── logs/                          # Thư mục logs
├── WEB-TERMINAL.bat               # 🚀 FILE DUY NHẤT CẦN DÙNG
└── README.md                      # Hướng dẫn này
```

## 💡 Cách Sử Dụng Web Terminal

1. **Truy cập**: http://localhost:9000
2. **Tạo Terminal**: Nhấn **"+ New Terminal"** (nút xanh)
3. **Chọn thư mục**: Hoặc để mặc định
4. **Nhấn**: **"Create Terminal"**
5. **Sử dụng**: Gõ lệnh như terminal bình thường!

## ❌ Khắc Phục Sự Cố

### "No sessions found"
1. Nhấn **"+ New Terminal"**
2. Chọn **"Create Terminal"**

### Lỗi bất kỳ
1. Chạy `WEB-TERMINAL-MANAGER.bat` as Administrator
2. Chọn **[9]** - Dọn dẹp hoàn toàn
3. Chọn **[1]** - 1 Click Setup lại

### Không truy cập được từ điện thoại
1. Kiểm tra cùng mạng WiFi
2. Tắt Windows Firewall tạm thời
3. Kiểm tra IP đúng chưa: `ipconfig`

## ⚠️ Lưu Ý Bảo Mật

- Chỉ chia sẻ với người tin tưởng
- Không expose ra Internet công cộng
- Sử dụng VPN khi cần thiết

## 📄 License

MIT License

---

**🎯 Mục tiêu: 1 Click là xong! Chạy `WEB-TERMINAL.bat` → [1] → Xong!**

**Chúc bạn sử dụng vui vẻ! 🚀**