# Web Terminal - Hướng Dẫn Sử Dụng

## 🚀 Cài Đặt Siêu Nhanh (Khuyến Nghị)

### Bước 1: Chuẩn Bị
- Tải và cài Node.js từ: https://nodejs.org
- Đảm bảo có quyền Administrator

### Bước 2: Cài Đặt
1. **Chuột phải** vào file `INSTALL.bat`
2. Chọn **"Run as Administrator"**
3. Nhấn `y` và chờ hoàn tất
4. Truy cập: http://localhost:9000

**Xong! Chỉ 2 bước! 🎉**

---

## 📱 Truy Cập Từ Điện Thoại

1. **Tìm IP máy tính:**
   - Mở Command Prompt (CMD)
   - Gõ: `ipconfig`
   - Tìm "IPv4 Address" (ví dụ: 192.168.1.100)

2. **Truy cập từ điện thoại:**
   - Kết nối cùng WiFi với máy tính
   - Mở trình duyệt trên điện thoại
   - Vào: `http://192.168.1.100:9000`

---

## 🛠️ Các Script Hỗ Trợ

| File | Mục đích | Khi nào dùng |
|------|----------|---------------|
| `INSTALL.bat` | **Cài đặt chính** | Lần đầu cài đặt |
| `pm2-manager.bat` | Quản lý chi tiết | Khi cần quản lý/debug |
| `force-cleanup.bat` | Dọn dẹp mạnh | Khi có lỗi nghiêm trọng |
| `test-setup.bat` | Test nhanh | Kiểm tra hoạt động |

---

## 🔧 Quản Lý Đơn Giản

### Lệnh PM2 Cơ Bản
```bash
pm2 list                    # Xem trạng thái
pm2 stop web-terminal       # Dừng
pm2 start web-terminal      # Khởi động
pm2 restart web-terminal    # Khởi động lại
pm2 logs web-terminal       # Xem logs
```

### PM2 Manager (Giao diện menu)
- Chạy `pm2-manager.bat` as Administrator
- **[1]** Khởi động
- **[2]** Dừng  
- **[4]** Xem trạng thái
- **[5]** Xem logs
- **[11]** Dọn dẹp hoàn toàn

---

## ❌ Khắc Phục Sự Cố

### Lỗi thường gặp:

#### 🔴 "Port 9000 đã được sử dụng"
```bash
# Giải pháp 1: Dọn dẹp nhanh
pm2 kill
taskkill /F /IM node.exe

# Giải pháp 2: Dọn dẹp mạnh
# Chạy force-cleanup.bat
```

#### 🔴 "PM2 không hoạt động"
```bash
# Cài lại PM2
npm install -g pm2 pm2-windows-startup
```

#### 🔴 "Không truy cập được từ điện thoại"
1. Kiểm tra cùng mạng WiFi
2. Tắt Windows Firewall tạm thời
3. Kiểm tra IP đúng chưa: `ipconfig`

#### 🔴 "Service crash liên tục"
1. Chạy `force-cleanup.bat`
2. Restart máy tính
3. Chạy lại `INSTALL.bat`

### Quy trình khắc phục tổng quát:
```
1. Chạy force-cleanup.bat
2. Restart máy tính (nếu cần)
3. Chạy INSTALL.bat
4. Nếu vẫn lỗi → cài lại Node.js
```

---

## 🌐 Chia Sẻ Với Bạn Bè

### 🏠 Mạng LAN (Khuyến nghị)
1. Cài đặt bằng `INSTALL.bat`
2. Tìm IP: `ipconfig`
3. Chia sẻ: `http://[IP]:9000`

### 🌍 Internet (Ngrok)
1. Tải ngrok: https://ngrok.com
2. Chạy: `ngrok http 9000`
3. Chia sẻ URL ngrok

### 📱 Hotspot
1. Bật hotspot trên máy tính
2. Bạn bè kết nối hotspot
3. Truy cập: `http://192.168.137.1:9000`

---

## ⚠️ Lưu Ý Bảo Mật
- Chỉ chia sẻ với người tin tưởng
- Không expose ra Internet công cộng
- Sử dụng VPN khi cần thiết
- Có thể đổi port trong PM2 Manager → [9]

---

## 🆘 Hỗ Trợ Khẩn Cấp

### Khi mọi thứ đều thất bại:
1. Gỡ cài đặt Node.js hoàn toàn
2. Restart máy tính
3. Cài lại Node.js từ nodejs.org
4. Chạy `INSTALL.bat`

### Liên hệ hỗ trợ:
- Chạy `pm2 logs web-terminal` để lấy logs
- Chụp màn hình lỗi
- Mô tả các bước đã thực hiện

---

**🎯 Mục tiêu: Bạn bè chỉ cần chạy `INSTALL.bat` là xong!**

**Chúc bạn sử dụng vui vẻ! 🚀**