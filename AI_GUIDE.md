# AI_GUIDE — Mobile App (MOBILE)

> Tài liệu ngữ cảnh cho AI/dev tiếp nhận. Đọc xong là đủ để code tiếp app mobile.
> Cập nhật khi thêm feature lớn.

## 1. Đây là gì
App di động (Android/iOS) + web, cho học viên/phụ huynh của hệ thống quản lý trung tâm đào tạo. Dựng từ **Very Good Core** (scaffold production của Very Good Ventures, sinh bằng `very_good_cli`). Đã thêm **luồng đăng nhập** gọi vào backend thật (`BE/`, port 9090).

Package Dart: **`deca_mobile`** (tên thư mục là `MOBILE`, không ảnh hưởng).

## 2. Công nghệ
| Thành phần | Lựa chọn |
|---|---|
| Framework | Flutter 3.41, Dart 3.11 |
| State management | **Bloc/Cubit** (`bloc` ^9, `flutter_bloc` ^9) |
| HTTP | `http` (đã thêm) |
| Kiến trúc | Feature-first + flavor (dev/staging/prod), i18n, test + CI sẵn |
| Lint | `very_good_analysis` (nghiêm; nhiều rule là `info`, không chặn chạy) |

## 3. Cách chạy
```powershell
# Web (Chrome) — chạy ngay trên Windows
flutter run -d chrome --target lib/main_development.dart --web-port 7357

# Android emulator (cần Android SDK) — ĐỔI baseUrl sang 10.0.2.2:9090 (xem mục 6)
flutter run --flavor development --target lib/main_development.dart
```
- Có **3 entry point**: `lib/main_development.dart`, `main_staging.dart`, `main_production.dart` → đều gọi `bootstrap()` (trong `lib/bootstrap.dart`) → dựng `App`.
- **KHÔNG chạy `flutter run` trống** (không có `lib/main.dart`).
- **iOS**: code chạy chung, nhưng biên dịch iOS **bắt buộc macOS/Xcode** (Windows không build được — dùng CI như Codemagic). Android build được trên Windows.
- Cần **BE chạy ở 9090** (xem `BE/AI_GUIDE.md`). Đăng nhập sẵn `admin` / `Admin@123` (form điền sẵn).

## 4. Cấu trúc thư mục (`lib/`)
```
main_development.dart / main_staging.dart / main_production.dart   # entry theo flavor
bootstrap.dart                 # khởi tạo chung (BlocObserver, error handling) rồi runApp
app/
  app.dart                     # barrel
  view/app.dart                # MaterialApp + Provider + điều hướng Login<->Home theo AuthStatus
auth/                          # <-- FEATURE ĐÃ THÊM
  data/auth_repository.dart    # gọi BE: login()/logout(), giữ access/refresh token, baseUrl
  cubit/auth_cubit.dart        # AuthCubit + AuthState + enum AuthStatus
  view/login_page.dart         # màn login (form username/password)
home/
  view/home_page.dart          # màn sau đăng nhập: hiện fullName, username, roles + nút logout
counter/                       # feature mẫu của Very Good Core (KHÔNG dùng nữa, giữ lại)
l10n/                          # i18n (arb files)
```

## 5. Luồng code chính (cách đi luồng)
```
main_development.dart -> bootstrap(() => const App())
App (app/view/app.dart):
  RepositoryProvider(AuthRepository)
    -> BlocProvider(AuthCubit(repo))
       -> MaterialApp.home = BlocBuilder<AuthCubit, AuthState>:
            AuthStatus.authenticated -> HomePage
            ngược lại                -> LoginPage
```
Luồng đăng nhập:
```
LoginPage: nhập username/password -> context.read<AuthCubit>().login(u, p)
AuthCubit.login: emit(loading)
  -> AuthRepository.login(): POST http://localhost:9090/api/v1/auth/login
       body {username, password}; đọc res.data.accessToken + res.data.user
  -> thành công: emit(AuthState(authenticated, user))  -> App rebuild -> HomePage
  -> thất bại : emit(AuthState(failure, error))         -> LoginPage hiện SnackBar
HomePage: đọc user qua context.select((AuthCubit c) => c.state.user); nút logout -> AuthCubit.logout()
```

## 6. Nối backend — điểm cấu hình
- File: **`lib/auth/data/auth_repository.dart`**, hằng `baseUrl`.
  - Web/desktop: `http://localhost:9090`
  - **Android emulator: `http://10.0.2.2:9090`** (localhost của emulator ≠ máy host)
  - Thiết bị thật: `http://<IP-máy-chạy-BE>:9090`
- BE đã bật CORS `*` nên Flutter web gọi thẳng được (không cần proxy).
- Response BE: `{ success, data, error }`. Repository đọc `body['data']`.
- **Token JWT hiện giữ trong RAM** (`_accessToken` trong repository) — mất khi reload. Muốn bền: thêm `shared_preferences` (web+mobile dễ) hoặc `flutter_secure_storage`, nạp lại lúc khởi động và đổi `App` để check token sẵn có.

## 7. Cách THÊM một feature mới (vd: "Lịch học")
1. Tạo thư mục `lib/<feature>/` với 3 lớp: `data/<feature>_repository.dart`, `cubit/<feature>_cubit.dart`, `view/<feature>_page.dart`.
2. Repository gọi API qua `http`, **gắn header** `Authorization: Bearer <token>` (lấy token từ `AuthRepository.accessToken` — cân nhắc inject `AuthRepository` vào repository mới).
3. Cung cấp Cubit qua `BlocProvider` (ở `app.dart` hoặc cục bộ trong route).
4. Thêm điều hướng (hiện app dùng `home:` đơn giản; nếu cần nhiều màn → cân nhắc thêm `go_router`).
5. Thêm dependency: `flutter pub add <pkg>`.
6. Chuỗi văn bản hiển thị: thêm vào `lib/l10n/arb/app_en.arb` (+ các locale) nếu muốn i18n.

## 8. Quy ước & lưu ý
- Theo pattern **Cubit**: state là class bất biến + `copyWith`; logic trong Cubit; UI chỉ `read`/`watch`/`select`.
- `flutter analyze` còn vài cảnh báo **`info`** (very_good_analysis: độ dài dòng, `on` clause…) — không phải lỗi, không chặn chạy. Dọn dần nếu muốn "xanh".
- Test mẫu ở `test/` — khi đổi `app.dart` nhớ cập nhật `test/app/view/app_test.dart`.
- Khi restart nhanh trên web có thể kẹt cổng 7357 → kill tiến trình Dart cũ rồi chạy lại.
- Git remote: `https://github.com/phiconght/decaMobilev2`.
