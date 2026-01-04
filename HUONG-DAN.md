# Web Terminal - Hướng Dẫn Sử Dụng

## 🚀 1 CLICK SETUP - SIÊU ĐỠN GIẢN!

### Bước 1: Chuẩn Bị
- Tải và cài Node.js từ: https://nodejs.org

### Bước 2: 1 Click Setup
1. **Double-click** vào `WEB-TERMINAL.bat`
2. Chọn **[1]** - Cài đặt và khởi động
3. Truy cập: http://localhost:9000

**Xong! Chỉ 1 click! 🎉**

---

## 🛠️ Web Terminal Manager

Chạy `WEB-TERMINAL.bat` để quản lý:

| Tùy chọn | Chức năng |
|----------|-----------|
| **[1]** | 🚀 **1 Click Setup** - Cài đặt hoàn toàn tự động |
| **[2]** | ▶️ Khởi động Web Terminal |
| **[3]** | ⏹️ Dừng Web Terminal |
| **[4]** | 🔄 Khởi động lại |
| **[5]** | 📊 Xem trạng thái chi tiết |
| **[6]** | 📝 Xem logs |
| **[7]** | 🛠️ Cài Windows Service (tự chạy khi khởi động) |
| **[8]** | ❌ Gỡ Windows Service |
| **[9]** | 🧹 Dọn dẹp hoàn toàn (khi có lỗi) |
| **[10]** | 🔧 Khắc phục sự cố |

---

## 📱 Truy Cập Từ Điện Thoại

1. **Tìm IP máy tính:**
   - Mở Command Prompt (CMD)
   - Gõ: `ipconfig`
   - Tìm "IPv4 Address" (ví dụ: 192.168.1.100)

2. **Trên điện thoại:**
   - Kết nối cùng WiFi với máy tính
   - Mở trình duyệt: `http://192.168.1.100:9000`

---

## 💡 Cách Sử Dụng Web Terminal

1. **Truy cập**: http://localhost:9000
2. **Tạo Terminal**: Nhấn **"+ New Terminal"** (nút màu xanh)
3. **Chọn thư mục**: Hoặc để mặc định
4. **Nhấn**: **"Create Terminal"**
5. **Sử dụng**: Gõ lệnh như terminal bình thường!

Ví dụ lệnh:
- `dir` - Xem files/folders
- `cd folder_name` - Vào thư mục
- `cls` - Xóa màn hình
- `ipconfig` - Xem IP máy tính

---

## ❌ Khắc Phục Lỗi

### 🔴 Bất kỳ lỗi nào
1. Chạy `WEB-TERMINAL-MANAGER.bat` as Administrator
2. Chọn **[9]** - Dọn dẹp hoàn toàn
3. Chọn **[1]** - 1 Click Setup lại
4. Nếu vẫn lỗi → Restart máy tính

### 🔴 "No sessions found"
1. Nhấn **"+ New Terminal"**
2. Nhấn **"Create Terminal"**

### 🔴 Không truy cập được từ điện thoại
1. Kiểm tra cùng mạng WiFi
2. Tắt Windows Firewall tạm thời
3. Kiểm tra IP đúng: `ipconfig`

### 🔴 Khi tắt terminal thì mất kết nối
- Chạy `WEB-TERMINAL-MANAGER.bat` → **[7]** để cài Windows Service
- Sau đó Web Terminal sẽ chạy nền, không cần giữ cửa sổ mở

---

## 🌐 Chia Sẻ Với Bạn Bè

### 🏠 Mạng LAN (Khuyến nghị)
1. Cài Windows Service: **[7]** trong Manager
2. Tìm IP: `ipconfig`
3. Chia sẻ: `http://[IP]:9000`

### 🌍 Internet (Ngrok)
1. Tải ngrok: https://ngrok.com
2. Chạy: `ngrok http 9000`
3. Chia sẻ URL ngrok

---

## 📁 Files Quan Trọng (Đã Dọn Dẹp)

| File | Mục đích |
|------|----------|
| `WEB-TERMINAL-MANAGER.bat` | **🚀 APP QUẢN LÝ CHÍNH** |
| `force-cleanup.bat` | Dọn dẹp khẩn cấp |
| `server.js` | Server chính |
| `ecosystem.config.js` | Config PM2 |

---

## ⚠️ Lưu Ý Bảo Mật
- Chỉ chia sẻ với người tin tưởng
- Không expose ra Internet công cộng
- Sử dụng VPN khi cần thiết

---

**🎯 Nhớ: Chỉ cần 1 click! `WEB-TERMINAL-MANAGER.bat` → [1] → Xong!**

**Chúc bạn sử dụng vui vẻ! 🚀**