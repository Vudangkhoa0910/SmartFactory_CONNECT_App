# 🌐 Hệ Thống Đa Ngôn Ngữ (i18n) - SmartFactory CONNECT

## 📋 Tổng Quan

Hệ thống đa ngôn ngữ đã được nâng cấp hoàn toàn để hỗ trợ Tiếng Việt (VI) và Tiếng Nhật (JA) một cách dễ dàng và linh hoạt.

### ✅ Đã Hoàn Thành

1. ✅ **Widget Toggle Ngôn Ngữ** - 3 phiên bản:
   - `LanguageToggleButton` - Full version với animation
   - `LanguageToggleButtonCompact` - Compact cho header
   - `LanguageToggleIconButton` - Icon button cho AppBar

2. ✅ **Cập Nhật ARB Files**:
   - Thêm 65+ keys mới
   - Phân loại rõ ràng theo chức năng
   - Translation đầy đủ VI/JA

3. ✅ **Refactor Screens**:
   - Login Screen ✅
   - Report Screens ✅ 
   - Idea Box Screens ✅
   - Profile & Settings ✅
   - Home Header ✅

4. ✅ **Tích Hợp UI**:
   - Login Screen: Toggle button trong body
   - Home Header: Compact version
   - Settings: Full language picker

---

## 🎨 Widget Toggle Ngôn Ngữ

### 1. LanguageToggleButton (Full)
```dart
const LanguageToggleButton()
```
- **Vị trí**: Login screen, standalone screens
- **Đặc điểm**: 
  - Kích thước 100x40
  - Animation trượt mượt mà
  - Theme trắng-đỏ đồng bộ
  - Hiển thị VI | JA

### 2. LanguageToggleButtonCompact
```dart
const LanguageToggleButtonCompact()
```
- **Vị trí**: Home header, toolbars
- **Đặc điểm**:
  - Nhỏ gọn với icon ngôn ngữ
  - Hiển thị code (VI/JA)
  - Border đỏ mỏng

### 3. LanguageToggleIconButton
```dart
const LanguageToggleIconButton()
```
- **Vị trí**: AppBar actions
- **Đặc điểm**:
  - Icon button tròn
  - Chỉ hiển thị code
  - Tooltip đa ngôn ngữ

---

## 📝 Cách Sử Dụng

### Thêm Text i18n Mới

#### 1. Thêm vào ARB files

**app_vi.arb:**
```json
{
  "myNewKey": "Văn bản tiếng Việt"
}
```

**app_ja.arb:**
```json
{
  "myNewKey": "日本語テキスト"
}
```

#### 2. Generate Localization
```bash
flutter gen-l10n
```

#### 3. Sử dụng trong Code
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.myNewKey)
```

### Text với Tham Số

**ARB:**
```json
{
  "welcomeMessage": "Xin chào {name}!",
  "@welcomeMessage": {
    "placeholders": {
      "name": {"type": "String"}
    }
  }
}
```

**Dart:**
```dart
Text(l10n.welcomeMessage('Khoa'))
```

---

## 🗂️ Cấu Trúc ARB Files

### Phân Loại Sections

```
@@_NAVIGATION          - Navigation labels
@@_USER_ROLES          - User role names
@@_COMMON_ACTIONS      - Common buttons/actions
@@_LOGIN_SCREEN        - Login screen specific
@@_REPORT_HANDLING     - Report management
@@_COMPONENTS_PRODUCTION - Technical components
@@_DEPARTMENTS_CATEGORIES - Departments & categories
@@_IDEA_BOX_SPECIFIC   - Idea box features
@@_CHAT_AI             - AI chat messages
@@_ERROR_MESSAGES      - Error messages
@@_SUCCESS_MESSAGES    - Success messages
@@_TIME_LABELS         - Time formatting
```

### Keys Quan Trọng

| Category | Key | VI | JA |
|----------|-----|----|----|
| Tabs | `tabNew` | MỚI | 新規 |
| Tabs | `tabProcessing` | XỬ LÝ | 処理中 |
| Tabs | `tabCompleted` | HOÀN THÀNH | 完了 |
| Idea Box | `whiteBox` | Hòm trắng | ホワイトボックス |
| Idea Box | `pinkBox` | Hòm hồng | ピンクボックス |
| Components | `componentMotor` | Động cơ | モーター |
| Actions | `handleIncident` | Xử lý sự cố | 対応する |

---

## 🔧 Thêm Widget Toggle vào Screen Mới

### Ví Dụ 1: Full Button trong Body
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        children: [
          // Your content
          const LanguageToggleButton(),
        ],
      ),
    ),
  );
}
```

### Ví Dụ 2: Compact trong Header
```dart
Row(
  children: [
    // User info
    const Spacer(),
    const LanguageToggleButtonCompact(),
  ],
)
```

### Ví Dụ 3: Icon trong AppBar
```dart
AppBar(
  title: Text('Title'),
  actions: [
    const LanguageToggleIconButton(),
  ],
)
```

---

## 🎯 Best Practices

### ✅ Nên Làm

1. **Luôn sử dụng i18n cho text hiển thị**
```dart
// ✅ Đúng
Text(l10n.submit)

// ❌ Sai
Text('Gửi')
```

2. **Đặt tên key rõ ràng, có ngữ cảnh**
```dart
// ✅ Đúng
"reportSubmitSuccess": "Gửi báo cáo thành công"

// ❌ Sai  
"success": "Thành công"
```

3. **Group keys theo màn hình/chức năng**
```json
{
  "@@_REPORT_SCREEN": "================ REPORT SCREEN ================",
  "reportTitle": "...",
  "reportDescription": "...",
  "reportSubmit": "..."
}
```

4. **Sử dụng placeholders cho dynamic text**
```dart
// ✅ Đúng
"itemsCount": "{count} items",

// ❌ Sai - Hardcode số
"twoItems": "2 items"
```

### ❌ Không Nên

1. Hardcode text tiếng Việt/Nhật trong code
2. Duplicate keys với nội dung giống nhau
3. Quên thêm translation cho cả 2 ngôn ngữ
4. Đặt tên key không rõ nghĩa (vd: `text1`, `label2`)

---

## 📊 Thống Kê Cập Nhật

### Files Đã Refactor
- ✅ `report_handle_screen.dart`
- ✅ `suggestions_screen.dart`
- ✅ `create_idea_screen.dart`
- ✅ `idea_box_list_screen.dart`
- ✅ `leader_report_management_screen.dart`
- ✅ `login_screen.dart`
- ✅ `home_header.dart`

### Keys Đã Thêm
- **Report Handling**: 10 keys
- **Components & Production**: 13 keys
- **Departments**: 5 keys
- **Idea Box**: 15 keys
- **Chat & AI**: 2 keys
- **Other**: 20 keys
- **TOTAL**: 65+ new keys

---

## 🚀 Hướng Dẫn Mở Rộng Sau Này

### Thêm Ngôn Ngữ Mới (vd: English)

1. **Tạo file ARB mới**
```bash
touch lib/l10n/app_en.arb
```

2. **Copy structure từ app_vi.arb**
```json
{
  "@@locale": "en",
  "loginTitle": "Login",
  // ... translate all keys
}
```

3. **Cập nhật LanguageProvider**
```dart
static const Locale english = Locale('en');
static const List<Locale> supportedLocales = [
  vietnamese, 
  japanese,
  english, // Add here
];
```

4. **Cập nhật language names map**
```dart
static const Map<String, String> languageNames = {
  'vi': 'Tiếng Việt',
  'ja': '日本語',
  'en': 'English', // Add here
};
```

5. **Generate lại**
```bash
flutter gen-l10n
```

### Dynamic Content từ Database

Cho nội dung động (tin tức, báo cáo user tạo), lưu multi-language trong DB:

**Database Schema Example:**
```sql
CREATE TABLE news (
  id INT PRIMARY KEY,
  title_vi VARCHAR(255),
  title_ja VARCHAR(255),
  content_vi TEXT,
  content_ja TEXT
);
```

**Usage in Code:**
```dart
String getLocalizedTitle(NewsModel news) {
  final locale = LanguageProvider().currentLocale.languageCode;
  return locale == 'vi' ? news.titleVi : news.titleJa;
}
```

---

## 🐛 Troubleshooting

### Lỗi: "No AppLocalizations found"
```dart
// Solution: Wrap app với localizationsDelegates
MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: LanguageProvider.supportedLocales,
  locale: _languageProvider.currentLocale,
)
```

### Text không đổi khi switch language
```dart
// Solution: Ensure widget rebuilds when language changes
class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    LanguageProvider().addListener(_onLanguageChanged);
  }
  
  void _onLanguageChanged() {
    setState(() {});
  }
  
  @override
  void dispose() {
    LanguageProvider().removeListener(_onLanguageChanged);
    super.dispose();
  }
}
```

### ARB file bị lỗi format
```bash
# Validate ARB files
flutter gen-l10n --verbose
```

---

## 📚 Tài Liệu Tham Khảo

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package](https://pub.dev/packages/intl)

---

## 🎉 Kết Luận

Hệ thống đa ngôn ngữ đã được thiết lập hoàn chỉnh với:
- ✅ UI/UX đẹp, đồng bộ theme
- ✅ Dễ dàng thêm text mới
- ✅ Scalable cho nhiều ngôn ngữ
- ✅ Best practices & clean code
- ✅ Fully documented

**Next Steps:**
1. Test kỹ trên tất cả screens
2. Thu thập feedback từ users
3. Tiếp tục refactor các screens còn lại
4. Cân nhắc thêm ngôn ngữ khác (English?)

---

**Created by**: GitHub Copilot
**Date**: December 14, 2025
**Version**: 1.0.0
