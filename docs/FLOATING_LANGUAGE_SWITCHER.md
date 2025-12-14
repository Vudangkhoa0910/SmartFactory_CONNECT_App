# Floating Language Switcher - Nút Chuyển Đổi Ngôn Ngữ Nổi

## 📋 Tổng Quan

Floating Language Switcher là widget nút nổi cho phép chuyển đổi ngôn ngữ VI/JA mọi lúc mọi nơi, thiết kế tương tự ChatBox với khả năng thu gọn/mở rộng.

## 🎨 Đặc Điểm

### ✨ Tính Năng
- **Thu gọn/Mở rộng**: Animation mượt mà như ChatBox
- **Nổi trên UI**: Luôn hiển thị, không bị che khuất
- **Tự động thu gọn**: Sau khi chọn ngôn ngữ
- **Vị trí linh hoạt**: Có thể đặt ở 4 góc màn hình
- **Đồng bộ theme**: Trắng - Đỏ DENSO

### 🎯 Trạng Thái
1. **Thu gọn (56x56px)**: Hiển thị VI hoặc JA trên nền đỏ
2. **Mở rộng (140x56px)**: Hiển thị cả VI và JA để chọn

## 🚀 Cách Sử dụng

### 1. Sử dụng Wrapper Widget (Khuyến nghị)

```dart
import 'package:flutter/material.dart';
import '../widgets/floating_language_switcher.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithFloatingLanguageSwitcher(
      alignment: Alignment.bottomRight, // Vị trí nút
      margin: EdgeInsets.all(16),       // Khoảng cách từ mép
      child: Scaffold(
        appBar: AppBar(title: Text('My Screen')),
        body: Center(child: Text('Content here')),
      ),
    );
  }
}
```

### 2. Sử dụng Trực Tiếp

```dart
import 'package:flutter/material.dart';
import '../widgets/floating_language_switcher.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: Stack(
        children: [
          Center(child: Text('Content here')),
          
          // Floating language switcher
          FloatingLanguageSwitcher(
            alignment: Alignment.bottomLeft,
            margin: EdgeInsets.all(16),
          ),
        ],
      ),
    );
  }
}
```

## 📍 Vị Trí Đặt Nút

### Các Vị Trí Có Sẵn
```dart
// Góc dưới trái (mặc định)
FloatingLanguageSwitcher(
  alignment: Alignment.bottomLeft,
  margin: EdgeInsets.all(16),
)

// Góc dưới phải (tránh ChatBox)
FloatingLanguageSwitcher(
  alignment: Alignment.bottomRight,
  margin: EdgeInsets.only(right: 16, bottom: 80), // Tránh ChatBox
)

// Góc trên trái
FloatingLanguageSwitcher(
  alignment: Alignment.topLeft,
  margin: EdgeInsets.only(left: 16, top: 100), // Tránh AppBar
)

// Góc trên phải
FloatingLanguageSwitcher(
  alignment: Alignment.topRight,
  margin: EdgeInsets.only(right: 16, top: 100),
)
```

### ⚠️ Lưu Ý Vị Trí
- **Tránh ChatBox**: Nếu màn hình có ChatBox, đặt ở góc khác hoặc điều chỉnh margin
- **Tránh AppBar**: Nếu đặt ở góc trên, cần margin top > 80px
- **Tránh BottomNavigationBar**: Nếu đặt ở góc dưới, cần margin bottom > 60px

## 🎛️ Tùy Chọn

### WithFloatingLanguageSwitcher Props

| Prop | Type | Mặc định | Mô tả |
|------|------|----------|-------|
| `child` | Widget | - | Widget con (bắt buộc) |
| `alignment` | Alignment | `Alignment.bottomLeft` | Vị trí nút |
| `margin` | EdgeInsets | `EdgeInsets.all(16)` | Khoảng cách từ mép |
| `enabled` | bool | `true` | Bật/tắt nút |

### FloatingLanguageSwitcher Props

| Prop | Type | Mặc định | Mô tả |
|------|------|----------|-------|
| `alignment` | Alignment | `Alignment.bottomLeft` | Vị trí nút |
| `margin` | EdgeInsets | `EdgeInsets.all(16)` | Khoảng cách từ mép |

## 📱 Ví Dụ Thực Tế

### Ví Dụ 1: Home Screen

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithFloatingLanguageSwitcher(
      alignment: Alignment.bottomLeft,
      margin: EdgeInsets.only(left: 16, bottom: 80), // Tránh bottom nav
      child: Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: HomeContent(),
        bottomNavigationBar: BottomNavigationBar(...),
      ),
    );
  }
}
```

### Ví Dụ 2: Report Screen (Có ChatBox)

```dart
class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithFloatingLanguageSwitcher(
      alignment: Alignment.topRight, // Đặt góc trên vì dưới có ChatBox
      margin: EdgeInsets.only(right: 16, top: 100),
      child: Scaffold(
        appBar: AppBar(title: Text('Report')),
        body: Stack(
          children: [
            ReportContent(),
            ChatBoxButton(), // Góc dưới phải
          ],
        ),
      ),
    );
  }
}
```

### Ví Dụ 3: Tắt Nút Tạm Thời

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithFloatingLanguageSwitcher(
      enabled: false, // Tắt vì đã có LanguageToggleButton trong form
      child: Scaffold(
        body: LoginForm(),
      ),
    );
  }
}
```

## 🎨 Thiết Kế

### Kích Thước
- **Thu gọn**: 56x56px (hình tròn)
- **Mở rộng**: 140x56px (hình thuốc)

### Màu Sắc
- **Nền**: Trắng
- **Viền**: DENSO Red (#DC0032 - `AppColors.error500`)
- **Nền slide**: DENSO Red
- **Chữ được chọn**: Trắng
- **Chữ không chọn**: Xám đậm (`AppColors.gray900`)

### Animation
- **Duration**: 300ms
- **Curve**: `easeInOut`
- **Tự động thu gọn**: Sau 200ms khi chọn ngôn ngữ

## 🔧 Cơ Chế Hoạt Động

1. **Khởi tạo**: Nút ở trạng thái thu gọn, hiển thị ngôn ngữ hiện tại
2. **Tap nút**: Mở rộng, hiển thị cả VI và JA
3. **Chọn ngôn ngữ**: 
   - Gọi `LanguageProvider.setLanguage()`
   - Nền đỏ trượt sang ngôn ngữ được chọn
   - Sau 200ms tự động thu gọn
4. **Tap nút X**: Thu gọn nút ngay lập tức

## ✅ Checklist Tích Hợp

- [ ] Import widget vào màn hình cần dùng
- [ ] Wrap Scaffold với `WithFloatingLanguageSwitcher`
- [ ] Chọn vị trí phù hợp (tránh ChatBox, AppBar, BottomNav)
- [ ] Điều chỉnh margin nếu cần
- [ ] Test thu gọn/mở rộng
- [ ] Test chuyển đổi ngôn ngữ
- [ ] Kiểm tra không che UI quan trọng

## 🎯 Khi Nào Sử Dụng

### ✅ Nên Dùng
- Màn hình không có AppBar với LanguageToggleIconButton
- Màn hình cần chuyển đổi ngôn ngữ nhanh chóng
- Màn hình có nhiều nội dung, scroll dài
- Màn hình fullscreen (video, image viewer)

### ❌ Không Nên Dùng
- Login screen (đã có LanguageToggleButton trong form)
- Màn hình đã có nhiều floating button (tránh rối)
- Màn hình nhỏ, ít nội dung (dùng trong AppBar là đủ)

## 🚨 Lưu Ý Quan Trọng

1. **Không trùng vị trí với ChatBox** (thường ở `bottomRight`)
2. **Margin phải đủ lớn** để không bị AppBar/BottomNav che
3. **Chỉ dùng 1 nút** trên 1 màn hình (tránh duplicate)
4. **Test trên nhiều kích thước màn hình** (phone, tablet)
5. **Z-index**: Nút luôn ở trên cùng nhờ Stack

## 📚 API Reference

### FloatingLanguageSwitcher

```dart
class FloatingLanguageSwitcher extends StatefulWidget {
  final Alignment alignment;
  final EdgeInsets margin;

  const FloatingLanguageSwitcher({
    super.key,
    this.alignment = Alignment.bottomLeft,
    this.margin = const EdgeInsets.all(16),
  });
}
```

### WithFloatingLanguageSwitcher

```dart
class WithFloatingLanguageSwitcher extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  final EdgeInsets margin;
  final bool enabled;

  const WithFloatingLanguageSwitcher({
    super.key,
    required this.child,
    this.alignment = Alignment.bottomLeft,
    this.margin = const EdgeInsets.all(16),
    this.enabled = true,
  });
}
```

## 🎉 Kết Luận

Floating Language Switcher là công cụ mạnh mẽ giúp user chuyển đổi ngôn ngữ mọi lúc mọi nơi, với thiết kế đẹp mắt, animation mượt mà, và dễ dàng tích hợp!
