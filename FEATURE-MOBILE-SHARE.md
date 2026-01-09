# 📱 Mobile Terminal Share Feature

## Tổng Quan

Tính năng chia sẻ terminal cho phép truy cập terminal đang chạy trên máy tính từ điện thoại hoặc thiết bị khác thông qua QR Code hoặc link.

## 🎯 2 Modes Sử Dụng

### **Mode 1: Traditional Mode (Chế độ truyền thống)**
Đây là chế độ sử dụng ban đầu của ứng dụng:
- **Tạo terminal mới**: Chọn thư mục và AI profile để tạo session mới
- **Resume session**: Chọn từ danh sách Claude sessions đã lưu trong history
- **Use case**: Làm việc bình thường trên máy tính, quản lý nhiều sessions

**Flow:**
```
Desktop → New Terminal → Chọn thư mục → Chọn AI profile → Terminal chạy
Desktop → Resume → Chọn session từ history → Terminal khôi phục
```

### **Mode 2: Quick Access Mode (Chế độ truy cập nhanh - MỚI)** ⭐
Chế độ mới cho phép truy cập terminal đang ACTIVE ngay lập tức:
- **Share terminal đang chạy**: Không cần tạo mới, chia sẻ terminal hiện tại
- **Access từ mobile**: Quét QR code hoặc dùng link để mở ngay trên điện thoại
- **Real-time sync**: Xem output và điều khiển (nếu có quyền) từ xa
- **Use case**: Di chuyển giữa thiết bị, theo dõi process, demo, collaboration

**Flow:**
```
Desktop → Terminal đang chạy → Click "Share" → QR hiển thị
Mobile → Quét QR → Terminal mở ngay → Xem/điều khiển real-time
```

## 📊 So Sánh 2 Modes

| Tiêu chí | Mode 1 (Traditional) | Mode 2 (Quick Access) |
|----------|---------------------|----------------------|
| **Mục đích** | Tạo/khôi phục session | Chia sẻ session đang chạy |
| **Nguồn** | History hoặc tạo mới | Terminal active hiện tại |
| **Thiết bị** | Chủ yếu desktop | Desktop + Mobile |
| **Sync** | Không (mỗi client riêng) | Real-time sync |
| **Quyền** | Full access | Read-only hoặc Full |
| **Thời hạn** | Vĩnh viễn (trong history) | 1 giờ (link hết hạn) |
| **Use case** | Công việc thường ngày | Di động, remote, demo |

## 🚀 Cách Sử Dụng Mode 2 (Quick Access)

### Bước 1: Tạo Share Link (Desktop)
1. Mở terminal bình thường (Mode 1)
2. Chạy các lệnh, process như bình thường
3. Click nút **"📱 Share"** trên toolbar
4. Chọn chế độ chia sẻ:
   - **OK** = Read-Only (chỉ xem, không gõ được)
   - **Cancel** = Full Access (điều khiển đầy đủ)
5. QR Code hiển thị ngay lập tức

### Bước 2: Truy Cập Từ Mobile
**Cách 1: Quét QR Code (Khuyến nghị)**
1. Mở Camera app trên điện thoại
2. Hướng camera vào QR code trên màn hình máy tính
3. Tap vào notification xuất hiện
4. Terminal mở ngay trong browser

**Cách 2: Dùng Link**
1. Click "📋 Copy" để copy link
2. Gửi link qua chat/email/...
3. Mở link trên thiết bị khác
4. Terminal hiển thị ngay

### Bước 3: Sử Dụng Terminal Trên Mobile
- **Xem output**: Tất cả output từ desktop hiển thị real-time
- **Gõ lệnh**: Dùng bàn phím điện thoại (nếu có quyền Full Access)
- **Phím đặc biệt**: Dùng toolbar phía dưới:
  - Ctrl+C, Tab, Esc
  - Arrow keys (↑ ↓ ← →)
  - Virtual keyboard với số và ký tự đặc biệt
- **Scroll**: Vuốt để xem lịch sử output

### Bước 4: Quản Lý Share Links
- **Xem active links**: Trong share dialog, phần "Active Share Links"
- **Revoke link**: Click nút "Revoke" để hủy quyền truy cập ngay
- **Link auto-expire**: Tự động hết hạn sau 1 giờ

## 🔐 Bảo Mật

### Share Link Security
- **Random token**: 32 ký tự hex (16 bytes entropy)
- **Expiration**: Tự động hết hạn sau 1 giờ
- **Revoke anytime**: Chủ terminal có thể hủy link bất cứ lúc nào
- **Terminal dependency**: Link không hoạt động nếu terminal gốc đã đóng

### Access Control
- **Read-Only Mode**:
  - Chỉ nhận output
  - Không gửi được input
  - Không resize được terminal
  - An toàn cho presentation/demo

- **Full Access Mode**:
  - Xem và điều khiển đầy đủ
  - Gõ lệnh như local
  - Resize terminal
  - Dùng cho collaboration/remote work

### Best Practices
1. ✅ Dùng Read-Only cho demo/presentation
2. ✅ Dùng Full Access cho team collaboration
3. ✅ Revoke link ngay sau khi dùng xong
4. ✅ Không share link chứa thông tin nhạy cảm
5. ⚠️ Link có thời hạn, nhưng vẫn nên revoke sớm

## 💡 Use Cases Thực Tế

### 1. Di Chuyển Giữa Thiết Bị
**Tình huống**: Đang build project trên máy, cần đi họp
```
Desktop: npm run build (chạy)
→ Click Share → QR code
→ Đi họp, mang theo điện thoại
Mobile: Quét QR → Xem build progress
→ Build xong, thấy notification ngay
```

### 2. Demo Cho Client/Team
**Tình huống**: Present kết quả cho client qua video call
```
Desktop: Terminal chạy server/logs
→ Share (Read-Only)
→ Share screen với QR code
Client: Quét QR → Xem logs real-time trên điện thoại của họ
→ Không lo về screen resolution, client xem trực tiếp
```

### 3. Remote Debugging
**Tình huống**: Team member cần help debug lỗi
```
Desktop: Terminal có lỗi đang chạy
→ Share (Full Access)
→ Gửi link cho team member
Teammate: Mở link → Xem lỗi → Gõ lệnh debug
→ Cả 2 cùng xem và sửa real-time
```

### 4. Monitoring Production
**Tình huống**: Server deployment, muốn theo dõi từ xa
```
Desktop: ssh production → tail -f logs
→ Share (Read-Only)
Mobile: Quét QR
→ Đi ăn trưa vẫn theo dõi logs
→ Có lỗi, thấy ngay trên điện thoại
```

### 5. Teaching/Training
**Tình huống**: Dạy junior developer
```
Instructor Desktop: Terminal demo code
→ Share (Read-Only)
Students: Quét QR → Xem trên điện thoại
→ Không cần nhìn projector, xem terminal rõ ràng
→ Scroll lại xem lịch sử commands
```

## 🎨 UI/UX Features

### Desktop Interface
- **Share Button**: Nút "📱 Share" trên toolbar
- **QR Dialog**: Modal hiển thị QR code lớn, dễ quét
- **Link Copy**: Copy link một cú click
- **Active Shares List**: Xem tất cả links đang active
- **Revoke Button**: Hủy từng link riêng lẻ
- **Expiration Timer**: Hiển thị thời gian còn lại

### Mobile Interface
- **Responsive Layout**: Tự động fit màn hình điện thoại
- **Touch-Optimized**: Buttons đủ lớn để tap
- **Virtual Keyboard**: Phím đặc biệt dễ dàng
- **Status Indicator**: Dot màu xanh/đỏ cho online/offline
- **Read-Only Badge**: Hiển thị rõ nếu chỉ xem
- **Auto-Fit Terminal**: Terminal resize theo màn hình
- **Gesture Support**: Swipe để scroll

## 🔧 Technical Details

### Architecture
```
┌─────────────┐         ┌─────────────┐
│   Desktop   │         │   Mobile    │
│  (Original) │         │  (Shared)   │
└──────┬──────┘         └──────┬──────┘
       │                       │
       │  Socket.IO            │  Socket.IO
       │  (spawn)              │  (auth: token)
       │                       │
       ├───────────────────────┤
       │                       │
   ┌───▼───────────────────────▼───┐
   │         Server                │
   │  activeTerminals Map          │
   │  shareLinks Map               │
   │  ┌─────────────────────────┐  │
   │  │  PTY Process (shared)   │  │
   │  │  - Only 1 process       │  │
   │  │  - Multiple consumers   │  │
   │  └─────────────────────────┘  │
   └───────────────────────────────┘
```

### Data Flow
1. **Desktop spawns terminal**: PTY process created, stored in activeTerminals
2. **Desktop clicks Share**: Generate token, create QR, store in shareLinks
3. **Mobile scans QR**: Extract token from URL
4. **Mobile connects**: Socket.IO with auth token
5. **Server validates**: Check token in shareLinks, check expiration
6. **Server connects**: Attach mobile socket to existing PTY process
7. **Bidirectional sync**:
   - PTY output → Desktop + Mobile
   - Desktop input → PTY
   - Mobile input → PTY (if Full Access)

### APIs

#### POST /api/terminal/share
**Request:**
```json
{
  "sessionId": "abc123def456",
  "socketId": "xyz789",
  "readOnly": true
}
```

**Response:**
```json
{
  "token": "32-char-hex-token",
  "link": "http://localhost:9000/mobile/32-char-hex-token",
  "qrCode": "data:image/png;base64,...",
  "expires": "2026-01-09T05:00:00.000Z"
}
```

#### GET /api/terminal/active-shares
**Response:**
```json
[
  {
    "token": "12345678...",
    "sessionId": "abc12345",
    "created": "1/9/2026, 4:00:00 AM",
    "expires": "1/9/2026, 5:00:00 AM",
    "readOnly": true,
    "isActive": true
  }
]
```

#### DELETE /api/terminal/share/:token
**Response:**
```json
{
  "success": true,
  "message": "Share link revoked"
}
```

#### GET /mobile/:token
**Returns:** HTML page (mobile.html) hoặc error page

### Socket.IO Events

#### Client → Server
- `spawn`: Tạo terminal mới (desktop)
- `input`: Gửi keystroke (desktop + mobile if Full Access)
- `resize`: Thay đổi kích thước terminal

#### Server → Client
- `session-info`: Thông tin session (sessionId, socketId)
- `connected`: Kết nối thành công (mobile)
- `output`: Terminal output data
- `error`: Lỗi kết nối

### Storage
- **activeTerminals Map**:
  - Key: socket.id
  - Value: { sessionId, cwd, ptyProcess, createdAt }

- **shareLinks Map**:
  - Key: token (32 hex chars)
  - Value: { sessionId, socketId, created, expires, readOnly }

### Cleanup
- **Auto cleanup**: Expired links removed khi GET /api/terminal/active-shares
- **On disconnect**: activeTerminals entry deleted
- **On revoke**: shareLinks entry deleted immediately

## 📈 Future Enhancements

### Planned Features
- [ ] Multiple mobile devices cùng lúc
- [ ] Session recording/playback
- [ ] File upload/download trong mobile
- [ ] Collaborative cursor (show who's typing)
- [ ] Chat sidebar cho team collaboration
- [ ] Notification khi có lệnh chạy xong
- [ ] PWA support (install as app)
- [ ] Offline mode với cached data
- [ ] Custom expiration time (5 min, 1 hour, 1 day)
- [ ] Password protection cho share links
- [ ] Whitelist IP addresses
- [ ] Usage analytics (bao nhiêu người đã access)

### Possible Improvements
- WebRTC cho peer-to-peer connection
- End-to-end encryption cho sensitive data
- Persistent share links (không expire)
- Share link history (audit log)
- Multiple permission levels (read, write, admin)
- Bandwidth optimization cho mobile

## 🐛 Troubleshooting

### QR Code Không Quét Được
- Đảm bảo QR code hiển thị đủ lớn và rõ
- Thử zoom in/out trên browser
- Dùng option "Copy Link" thay vì quét

### Mobile Không Kết Nối
- Check xem desktop terminal còn chạy không
- Verify link chưa hết hạn (< 1 giờ)
- Thử revoke và tạo link mới
- Check firewall/network (cùng mạng?)

### Read-Only Nhưng Vẫn Muốn Gõ
- Revoke link hiện tại
- Tạo link mới với mode "Full Access"
- Scan QR code mới

### Link Hết Hạn Quá Nhanh
- Hiện tại hardcoded 1 giờ
- Có thể extend bằng cách sửa `3600000` trong server.js
- Hoặc tạo link mới khi cần

### Performance Issues
- Giảm terminal output (clear screen thường xuyên)
- Tắt animations không cần thiết
- Dùng Read-Only mode nếu chỉ cần xem

---

**Version**: 1.0.0
**Last Updated**: 2026-01-09
**Author**: Claude Code
