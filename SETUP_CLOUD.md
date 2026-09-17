# REALITY: FELONY V9 — đăng nhập + đồng bộ cloud

Bản này chia quyền thành:

- `member` / mật khẩu `1`: chỉ đọc và nghe.
- `admin` / mật khẩu `120`: viết, sửa, xóa và đồng bộ.

## 1. Tạo Supabase project

Tạo một project Supabase miễn phí. Trong Dashboard mở **SQL Editor** và chạy toàn bộ file `supabase_setup.sql`.

## 2. Lấy URL và publishable/anon key

Trong project mở phần **Connect / API** và lấy:

- Project URL, dạng `https://xxxxx.supabase.co`
- Publishable key (`sb_publishable_...`) hoặc, với project cũ, `anon` key.

KHÔNG dùng `service_role` hoặc `secret` key trong `index.html`.

## 3. Dán cấu hình vào index.html

Tìm:

```js
const SUPABASE_URL="PASTE_SUPABASE_URL_HERE";
const SUPABASE_ANON_KEY="PASTE_SUPABASE_ANON_KEY_HERE";
```

thay bằng URL và publishable/anon key của project.

## 4. Đưa index.html lên GitHub

Upload `index.html` mới vào repository, thay file cũ, rồi Commit changes. Có thể giữ `supabase_setup.sql` và file hướng dẫn trong repository hoặc xóa chúng sau khi cấu hình xong.

## 5. Cách hoạt động

- Khi đăng nhập, website gọi `get_site_data()` để lấy bản dữ liệu chung.
- Admin sửa nội dung: website gọi `save_site_data()` và dữ liệu được lưu vào Supabase.
- Thành viên hoặc thiết bị khác mở lại website: dữ liệu chung được tải xuống.
- Voice/chia trang vẫn chạy ở trình duyệt, không bị ảnh hưởng.

## 6. Lưu ý bảo mật

Mật khẩu `1` và `120` theo đúng yêu cầu của bạn là rất yếu. Bản này dùng database function để không cho trình duyệt ghi trực tiếp vào bảng; function chỉ nhận ghi khi mật khẩu admin là `120`. Tuy vậy, đây vẫn là mô hình đơn giản phù hợp cho dự án cá nhân. Nếu website có dữ liệu quan trọng, nên chuyển sang Supabase Auth với tài khoản admin thật và mật khẩu mạnh.

Publishable/anon key có thể nằm trong frontend khi quyền database được giới hạn đúng; tuyệt đối không đưa service-role/secret key vào website.
