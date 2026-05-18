# Luồng Hoạt Động Của Ứng Dụng (App Flows)

Tài liệu này ghi lại chi tiết các luồng hoạt động chính (workflows) và logic nghiệp vụ bên trong ứng dụng Step Tracker.

## 1. Luồng Khởi Động Ứng Dụng (App Initialization Flow)
Khi người dùng mở ứng dụng, các bước sau sẽ diễn ra:
- **Khởi tạo Local Storage:** Ứng dụng khởi tạo `Hive` và mở các box lưu trữ cần thiết (ví dụ: `steps_box`, `settings_box`).
- **Kiểm tra quyền (Permissions):** Yêu cầu hoặc kiểm tra quyền truy cập cảm biến chuyển động (`ACTIVITY_RECOGNITION` trên Android, `NSMotionUsageDescription` trên iOS).
- **Khởi tạo Notification:** Khởi tạo cấu hình cho `flutter_local_notifications` để chuẩn bị gửi thông báo khi đạt mục tiêu.
- **Tải dữ liệu ban đầu:** Đọc dữ liệu số bước chân hiện tại trong ngày và mục tiêu từ Hive thông qua Riverpod Providers để render lên màn hình Dashboard.

## 2. Luồng Đếm Bước Chân (Step Tracking Flow)
Đây là luồng cốt lõi của ứng dụng, hoạt động theo thời gian thực (real-time):
- **Lắng nghe Sensor:** Sử dụng package `pedometer` để đăng ký lắng nghe sự kiện từ cảm biến đếm bước chân của thiết bị.
- **Cập nhật State:** Mỗi khi có thay đổi từ cảm biến, sự kiện (event) được gửi về `StepProvider` (Riverpod).
- **Tính toán:** Provider tính toán số bước đi được trong ngày hôm nay (dựa trên tổng số bước trừ đi số bước ở lần khởi động cuối của ngày).
- **Lưu trữ:** Lưu số bước chân mới nhất vào `Hive` để không bị mất dữ liệu khi đóng app.
- **Kiểm tra Mục Tiêu (Goal Check):** So sánh số bước hiện tại với mục tiêu ngày (Daily Goal).
  - Nếu số bước `>=` mục tiêu và chưa gửi thông báo trong ngày -> Kích hoạt gửi Notification chúc mừng.
- **Cập nhật UI:** Giao diện trên màn hình Dashboard (Progress vòng tròn, số liệu) tự động re-render nhờ Riverpod lắng nghe sự thay đổi của state.

## 3. Luồng Quản Lý Mục Tiêu (Goal Management)
- Người dùng vào màn hình **Settings** hoặc **Goals** để thay đổi mục tiêu số bước chân mỗi ngày.
- Giá trị mới được lưu vào `Hive` (settings_box).
- State của `GoalProvider` cập nhật.
- Màn hình Dashboard lập tức phản hồi: Cập nhật lại thanh tiến độ (Progress bar) dựa trên mục tiêu mới.

## 4. Luồng Lưu Trữ & Thống Kê (Statistics Flow)
Để có thể hiển thị biểu đồ theo tuần/tháng:
- **Lưu trữ lịch sử:** Mỗi khi qua ngày mới, ứng dụng sẽ lưu trữ chốt số liệu của ngày cũ vào một danh sách lịch sử trong Hive.
- **Truy xuất dữ liệu:** Khi người dùng mở màn hình **Statistics**, `StatisticsProvider` sẽ đọc toàn bộ lịch sử các ngày.
- **Hiển thị Biểu đồ:** Chuyển đổi dữ liệu từ Hive sang định dạng của `fl_chart` để vẽ biểu đồ dạng cột (BarChart) hoặc đường (LineChart), cho phép người dùng xem xu hướng đi bộ của mình trong 7 ngày gần nhất.

## 5. Luồng Thông Báo (Notification Flow)
- Ứng dụng theo dõi trạng thái "Đã thông báo hôm nay chưa?" (lưu cờ `is_notified_today` trong Hive).
- Khi phát hiện số bước đạt chỉ tiêu, hệ thống gọi `flutter_local_notifications` hiển thị một Local Notification.
- Đánh dấu cờ `is_notified_today = true` để không spam thông báo nếu người dùng tiếp tục đi bộ.
- Cờ này sẽ được reset về `false` khi sang ngày mới.
