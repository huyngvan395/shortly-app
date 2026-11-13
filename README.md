# 📱 Shortly App - Multiplatform Social E-commerce Application

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Badge"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Badge"/>
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase Badge"/>
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="Postgres Badge"/>
  <img src="https://img.shields.io/badge/Release-v1.0.0-success?style=for-the-badge&logo=android" alt="Release Badge"/>
</p>

---

## 📥 TẢI VỀ ỨNG DỤNG (DOWNLOAD RELEASE APK)

Phiên bản Release APK chính thức đã được xuất bản và sẵn sàng để tải xuống và cài đặt trực tiếp trên các thiết bị Android:

<p align="center">
  <a href="https://github.com/huyngvan395/shortly-app/releases/download/v1.0.0/app-release.apk">
    <img src="https://img.shields.io/badge/Bấm_Để_Tải_Xuống_APK_Release_(v1.0.1)-2ea44f?style=for-the-badge&logo=android&logoColor=white" alt="Tải APK Release" height="45"/>
  </a>
</p>

* ⬇️ **Link tải trực tiếp file APK:** [Tải app-release.apk (v1.0.1)](https://github.com/huyngvan395/shortly-app/releases/download/v1.0.0/app-release.apk)
* 🔗 **Trang GitHub Releases:** [Shortly App Releases v1.0.1](https://github.com/huyngvan395/shortly-app/releases)
* 📦 **Tên tệp biên dịch:** `app-release.apk`
* ⚖️ **Dung lượng:** `249.9 MB` (đã bao gồm đầy đủ native engines cho Agora RTC, Video Player và Camera)
* 📂 **Đường dẫn cục bộ sau khi build:**
  ```text
  build/app/outputs/flutter-apk/app-release.apk
  ```

> [!TIP]
> **Cài đặt nhanh qua ADB:** Nếu thiết bị Android của bạn đã kết nối với máy tính và bật USB Debugging, bạn có thể cài đặt trực tiếp file APK bằng lệnh:
> ```bash
> adb install -r build/app/outputs/flutter-apk/app-release.apk
> ```

---

## 📝 Tổng Quan Dự Án (Project Overview)

**Shortly App** là nền tảng ứng dụng di động đa nền tảng đột phá kết hợp giữa **Mạng xã hội video ngắn** và **Sàn thương mại điện tử đa đối tác** (Mô hình **Social E-Commerce** hay **Shoppertainment**).

Dự án được xây dựng dựa trên kiến trúc phần mềm tiêu chuẩn doanh nghiệp (**Clean Architecture**), phân tách rõ ràng các tầng trách nhiệm, kết hợp hệ thống dịch vụ đám mây **Supabase BaaS**, **Agora RTC Livestream**, **Cloudinary CDN** và **OpenRouter AI**.

---

## ✨ Các Tính Năng Nổi Bật (Key Features)

### 🎥 1. Mạng Xã Hội Video Ngắn & Sáng Tạo Nội Dung (Shoppertainment)
* **Video Feed Tràn Màn Hình:** Trải nghiệm lướt video mượt mà chuẩn phong cách TikTok, thả tim, bình luận tương tác đa tầng và chia sẻ.
* **Gắn Thẻ Sản Phẩm (Product Tagging):** Người sáng tạo có thể gắn trực tiếp link sản phẩm vào video, cho phép người xem bấm mua ngay khi đang thưởng thức clip.
* **Bộ Công Cụ Tạo Video (Video Creator & Editor):** Quay video camera, chọn nhạc trực tuyến (`Music Search`), áp dụng bộ lọc màu và chỉnh sửa trước khi đăng.
* **Livestream Tương Tác Hai Chiều:** Tích hợp công nghệ **Agora RTC Engine** với cơ chế cấp token động cho phép phát trực tiếp và xem livestream theo thời gian thực.
* **Tìm Kiếm Đa Năng (Advanced Search):** Tìm kiếm thông minh sản phẩm, video, nhà sáng tạo nội dung với tab phân loại trực quan.

### 🛒 2. Phân Hệ Thương Mại Điện Tử & Vận Chuyển (E-commerce Lifecycle)
* **Danh Mục & Chi Tiết Sản Phẩm:** Khám phá sản phẩm đa dạng từ các thương hiệu chính hãng, phân loại ngành hàng, đánh giá sao và bình luận của người mua.
* **Giỏ Hàng & Quản Lý Đơn Hàng:** Giỏ hàng thông minh, hỗ trợ mua ngay (`Direct Order`), áp mã giảm giá và quản lý nhiều địa chỉ giao hàng.
* **Theo Dõi Vận Chuyển Thời Gian Thực (Order Tracking):** Cập nhật chi tiết từng chặng của đơn hàng (Đã đặt $\rightarrow$ Đã xác nhận $\rightarrow$ Đang giao $\rightarrow$ Giao thành công).
* **Ví Điện Tử (In-App Wallet):** Tích hợp quản lý số dư, nạp tiền và theo dõi lịch sử biến động số dư.

### 🏪 3. Phân Hệ Nhà Bán Hàng (Seller Center)
* **Cổng Đăng Ký Gian Hàng:** Cho phép người dùng nâng cấp tài khoản lên đối tác bán hàng.
* **Quản Lý Sản Phẩm:** Giao diện thêm mới, sửa đổi thông tin sản phẩm và theo dõi tồn kho chuyên nghiệp.

### 💬 4. Trò Chuyện & Thông Báo Thời Gian Thực (Realtime Messaging & Notifications)
* **Real-time Chat:** Trò chuyện trực tiếp giữa Khách hàng và Shop qua kết nối Supabase Realtime Channels, gửi hình ảnh và tin nhắn thoại.
* **In-App Push Banner:** Thông báo nổi tự động đẩy trong ứng dụng khi có cập nhật trạng thái đơn hàng, tương tác hoặc tin nhắn mới.

### 👑 5. Phân Hệ Quản Trị Hệ Thống (Super Admin Portal)
* **Admin Login & RBAC Guard:** Phân quyền vai trò quản trị viên chặt chẽ.
* **Kiểm Duyệt Toàn Diện:** Kiểm duyệt video ngắn, phê duyệt mở shop thương hiệu, quản trị tài khoản người dùng và giám sát doanh số toàn sàn.

---

## 🏛️ Kiến Trúc Hệ Thống & Công Nghệ (Tech Stack)

* **Mobile Framework:** **Flutter 3.38+** & **Dart 3.10+** (Hỗ trợ Android, iOS, Web).
* **Quản Lý Trạng Thái (State Management):** **Flutter BLoC** (tách biệt hoàn toàn Business Logic khỏi UI).
* **Service Locator (DI):** **GetIt** (`injector.dart`).
* **Định Tuyến (Routing):** **GoRouter** (`app_router.dart`, `admin_router.dart`).
* **Cơ Sở Dữ Liệu & Backend:** **Supabase BaaS** (PostgreSQL) với chính sách bảo mật **Row-Level Security (RLS)** trên toàn bộ bảng dữ liệu.
* **Truyền Thông Thời Gian Thực & RTC:** **Agora RTC Engine**, **Supabase Realtime Streams**.
* **Đa Phương Tiện:** **Cloudinary CDN** lưu trữ video, ảnh đại diện và chứng từ sản phẩm.
* **Trí Tuệ Nhân Tạo:** **OpenRouter AI** hỗ trợ tìm kiếm sản phẩm thông minh.

---

## 📂 Cấu Trúc Thư Mục Clean Architecture

```text
lib/
├── core/                       # Tài nguyên & Cấu hình dùng chung
│   ├── constants/              # Màu sắc (AppColors), Strings, Themes
│   ├── network/                # Supabase Client, Http Handler
│   ├── services/               # Agora RTC, Cloudinary, Push Notifications
│   └── utils/                  # Format tiền tệ, thời gian, video cache
│
├── features/                   # Mô-đun tính năng chuẩn Feature-First
│   ├── auth/                   # Đăng nhập, Đăng ký, OAuth Callback
│   ├── chat/                   # Nhắn tin Realtime, Voice Message, Attachment
│   ├── comment/                # Bình luận video đa cấp, thả cảm xúc
│   ├── ecommerce/              # Sàn thương mại điện tử
│   │   ├── address/            # Quản lý sổ địa chỉ giao hàng
│   │   ├── admin/              # Super Admin Portal (Videos, Users, Shops, Orders)
│   │   ├── cart/               # Giỏ hàng & Đồng bộ
│   │   ├── checkout/           # Thanh toán, Voucher & Vận chuyển
│   │   ├── order/              # Vòng đời đơn hàng & Order Tracking
│   │   ├── product/            # Danh sách & Chi tiết sản phẩm
│   │   ├── review/             # Đánh giá & Phản hồi sản phẩm
│   │   └── shop/               # Hồ sơ Shop & Seller Center
│   ├── feed/                   # Infinite Scroll Feed & Tìm kiếm nâng cao
│   ├── notification/           # Trung tâm thông báo
│   ├── profile/                # Trang cá nhân, Video đã lưu, Cài đặt bảo mật
│   ├── video/                  # Quay video, Livestream RTC, Video Editor
│   └── wallet/                 # Ví điện tử & Lịch sử giao dịch
│
├── di/                         # Dependency Injection Service Locator
└── routes/                     # Cấu hình App & Admin GoRouter
```

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Mã Nguồn (Getting Started)

### 1. Tải dependencies
```bash
flutter pub get
```

### 2. Chạy ứng dụng trên thiết bị / máy ảo
```bash
flutter run
```

### 3. Đóng gói file APK Release
```bash
flutter build apk --release
```

---

## 🗄️ Cấu Trúc Cơ Sở Dữ Liệu (Database Schema)

Cơ sở dữ liệu hoàn chỉnh của dự án nằm tại tệp [database.sql](database.sql):
* Định nghĩa bảng đầy đủ (Profiles, Videos, Products, Orders, Carts, Shops, Comments, Notifications, Tracking Events...).
* Seed data phong phú các thương hiệu mỹ phẩm nổi tiếng cùng danh mục sản phẩm mẫu.
* Hệ thống Triggers tự động cập nhật số lượng và đánh giá.
* Chính sách bảo mật hàng đầu với PostgreSQL Row-Level Security (RLS).
