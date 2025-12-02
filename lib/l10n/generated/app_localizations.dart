import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('vi'),
  ];

  /// No description provided for @navReports.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get navReports;

  /// No description provided for @navIdeaBox.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng'**
  String get navIdeaBox;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get navSettings;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get navNotifications;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @submit.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get submit;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In vi, this message translates to:
  /// **'Lọc'**
  String get filter;

  /// No description provided for @refresh.
  ///
  /// In vi, this message translates to:
  /// **'Làm mới'**
  String get refresh;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @back.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get back;

  /// No description provided for @next.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In vi, this message translates to:
  /// **'Trước đó'**
  String get previous;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi'**
  String get error;

  /// No description provided for @success.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo'**
  String get warning;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @yes.
  ///
  /// In vi, this message translates to:
  /// **'Có'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In vi, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get done;

  /// No description provided for @apply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get reset;

  /// No description provided for @clear.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get clear;

  /// No description provided for @selectAll.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tất cả'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chọn tất cả'**
  String get deselectAll;

  /// No description provided for @noData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết quả'**
  String get noResults;

  /// No description provided for @seeAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get seeAll;

  /// No description provided for @more.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get more;

  /// No description provided for @less.
  ///
  /// In vi, this message translates to:
  /// **'Ít hơn'**
  String get less;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get thisMonth;

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn trở lại'**
  String get loginSubtitle;

  /// No description provided for @employeeId.
  ///
  /// In vi, this message translates to:
  /// **'Mã nhân viên'**
  String get employeeId;

  /// No description provided for @enterEmployeeId.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã nhân viên'**
  String get enterEmployeeId;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu'**
  String get enterPassword;

  /// No description provided for @loginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginButton;

  /// No description provided for @loggingIn.
  ///
  /// In vi, this message translates to:
  /// **'Đang đăng nhập...'**
  String get loggingIn;

  /// No description provided for @rememberMe.
  ///
  /// In vi, this message translates to:
  /// **'Ghi nhớ đăng nhập'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPassword;

  /// No description provided for @loginFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thất bại'**
  String get loginFailed;

  /// No description provided for @invalidCredentials.
  ///
  /// In vi, this message translates to:
  /// **'Mã nhân viên hoặc mật khẩu không đúng'**
  String get invalidCredentials;

  /// No description provided for @pleaseEnterEmployeeId.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mã nhân viên'**
  String get pleaseEnterEmployeeId;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get pleaseEnterPassword;

  /// No description provided for @biometricLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập bằng sinh trắc học'**
  String get biometricLogin;

  /// No description provided for @useBiometric.
  ///
  /// In vi, this message translates to:
  /// **'Sử dụng vân tay/Face ID'**
  String get useBiometric;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị không hỗ trợ sinh trắc học'**
  String get biometricNotAvailable;

  /// No description provided for @biometricNotEnrolled.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đăng ký sinh trắc học trên thiết bị'**
  String get biometricNotEnrolled;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực sinh trắc học thất bại'**
  String get biometricAuthFailed;

  /// No description provided for @pleaseAuthenticate.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác thực để đăng nhập'**
  String get pleaseAuthenticate;

  /// No description provided for @loginWithBiometric.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập bằng vân tay/Face ID'**
  String get loginWithBiometric;

  /// No description provided for @orLoginWithPassword.
  ///
  /// In vi, this message translates to:
  /// **'Hoặc đăng nhập bằng mật khẩu'**
  String get orLoginWithPassword;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất?'**
  String get logoutConfirmMessage;

  /// No description provided for @homeGreeting.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng đến với SmartFactory Connect'**
  String get homeSubtitle;

  /// No description provided for @quickActions.
  ///
  /// In vi, this message translates to:
  /// **'Truy cập nhanh'**
  String get quickActions;

  /// No description provided for @newReport.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo mới'**
  String get newReport;

  /// No description provided for @newIdea.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng mới'**
  String get newIdea;

  /// No description provided for @scanQR.
  ///
  /// In vi, this message translates to:
  /// **'Quét QR'**
  String get scanQR;

  /// No description provided for @viewNews.
  ///
  /// In vi, this message translates to:
  /// **'Xem tin tức'**
  String get viewNews;

  /// No description provided for @recentReports.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo gần đây'**
  String get recentReports;

  /// No description provided for @recentIdeas.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng gần đây'**
  String get recentIdeas;

  /// No description provided for @newsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tin tức & Sự kiện'**
  String get newsTitle;

  /// No description provided for @allNews.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả tin tức'**
  String get allNews;

  /// No description provided for @noNewsAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin tức nào'**
  String get noNewsAvailable;

  /// No description provided for @loadingNews.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải tin tức...'**
  String get loadingNews;

  /// No description provided for @newsAndEvents.
  ///
  /// In vi, this message translates to:
  /// **'Tin tức & Sự kiện'**
  String get newsAndEvents;

  /// No description provided for @newsDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết tin tức'**
  String get newsDetail;

  /// No description provided for @publishedAt.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đăng'**
  String get publishedAt;

  /// No description provided for @author.
  ///
  /// In vi, this message translates to:
  /// **'Tác giả'**
  String get author;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @newsCategories.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục tin tức'**
  String get newsCategories;

  /// No description provided for @announcement.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get announcement;

  /// No description provided for @event.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện'**
  String get event;

  /// No description provided for @policy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách'**
  String get policy;

  /// No description provided for @training.
  ///
  /// In vi, this message translates to:
  /// **'Đào tạo'**
  String get training;

  /// No description provided for @achievement.
  ///
  /// In vi, this message translates to:
  /// **'Thành tựu'**
  String get achievement;

  /// No description provided for @other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get other;

  /// No description provided for @readMore.
  ///
  /// In vi, this message translates to:
  /// **'Đọc thêm'**
  String get readMore;

  /// No description provided for @shareNews.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get shareNews;

  /// No description provided for @relatedNews.
  ///
  /// In vi, this message translates to:
  /// **'Tin liên quan'**
  String get relatedNews;

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Không có thông báo mới'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu tất cả đã đọc'**
  String get markAllRead;

  /// No description provided for @clearAllNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả thông báo'**
  String get clearAllNotifications;

  /// No description provided for @notificationSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt thông báo'**
  String get notificationSettings;

  /// No description provided for @newNotification.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo mới'**
  String get newNotification;

  /// No description provided for @unreadNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo chưa đọc'**
  String get unreadNotifications;

  /// No description provided for @profile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ cá nhân'**
  String get profile;

  /// No description provided for @personalInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get personalInfo;

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get editProfile;

  /// No description provided for @accountSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt tài khoản'**
  String get accountSettings;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phone;

  /// No description provided for @department.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ban'**
  String get department;

  /// No description provided for @position.
  ///
  /// In vi, this message translates to:
  /// **'Chức vụ'**
  String get position;

  /// No description provided for @role.
  ///
  /// In vi, this message translates to:
  /// **'Vai trò'**
  String get role;

  /// No description provided for @joinDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày vào làm'**
  String get joinDate;

  /// No description provided for @employeeCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã nhân viên'**
  String get employeeCode;

  /// No description provided for @avatarUpload.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi ảnh đại diện'**
  String get avatarUpload;

  /// No description provided for @saveChanges.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get saveChanges;

  /// No description provided for @discardChanges.
  ///
  /// In vi, this message translates to:
  /// **'Hủy thay đổi'**
  String get discardChanges;

  /// No description provided for @changePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu hiện tại'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu mới'**
  String get confirmPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu thành công'**
  String get passwordChanged;

  /// No description provided for @passwordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get passwordMismatch;

  /// No description provided for @invalidCurrentPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu hiện tại không đúng'**
  String get invalidCurrentPassword;

  /// No description provided for @personalInfoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get personalInfoTitle;

  /// No description provided for @editPersonalInfo.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa thông tin'**
  String get editPersonalInfo;

  /// No description provided for @updateSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật thành công'**
  String get updateSuccess;

  /// No description provided for @updateFailed.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật thất bại'**
  String get updateFailed;

  /// No description provided for @enterFullName.
  ///
  /// In vi, this message translates to:
  /// **'Nhập họ và tên'**
  String get enterFullName;

  /// No description provided for @enterEmail.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email'**
  String get enterEmail;

  /// No description provided for @enterPhone.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số điện thoại'**
  String get enterPhone;

  /// No description provided for @invalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại không hợp lệ'**
  String get invalidPhone;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In vi, this message translates to:
  /// **'Chung'**
  String get general;

  /// No description provided for @appearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @japanese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Nhật'**
  String get japanese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Anh'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In vi, this message translates to:
  /// **'Chủ đề'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ sáng'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get systemDefault;

  /// No description provided for @pushNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo đẩy'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo qua email'**
  String get emailNotifications;

  /// No description provided for @soundEnabled.
  ///
  /// In vi, this message translates to:
  /// **'Âm thanh'**
  String get soundEnabled;

  /// No description provided for @vibrationEnabled.
  ///
  /// In vi, this message translates to:
  /// **'Rung'**
  String get vibrationEnabled;

  /// No description provided for @privacy.
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư'**
  String get privacy;

  /// No description provided for @dataSync.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ dữ liệu'**
  String get dataSync;

  /// No description provided for @autoSync.
  ///
  /// In vi, this message translates to:
  /// **'Tự động đồng bộ'**
  String get autoSync;

  /// No description provided for @syncNow.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ ngay'**
  String get syncNow;

  /// No description provided for @lastSynced.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ lần cuối'**
  String get lastSynced;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get about;

  /// No description provided for @version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get version;

  /// No description provided for @termsOfService.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản dịch vụ'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật'**
  String get privacyPolicy;

  /// No description provided for @helpSupport.
  ///
  /// In vi, this message translates to:
  /// **'Trợ giúp & Hỗ trợ'**
  String get helpSupport;

  /// No description provided for @contactUs.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get contactUs;

  /// No description provided for @feedback.
  ///
  /// In vi, this message translates to:
  /// **'Gửi phản hồi'**
  String get feedback;

  /// No description provided for @rateApp.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá ứng dụng'**
  String get rateApp;

  /// No description provided for @clearCache.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ nhớ đệm'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa bộ nhớ đệm'**
  String get cacheCleared;

  /// No description provided for @reportList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách báo cáo'**
  String get reportList;

  /// No description provided for @myReports.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo của tôi'**
  String get myReports;

  /// No description provided for @allReports.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả báo cáo'**
  String get allReports;

  /// No description provided for @createReport.
  ///
  /// In vi, this message translates to:
  /// **'Tạo báo cáo'**
  String get createReport;

  /// No description provided for @filterReports.
  ///
  /// In vi, this message translates to:
  /// **'Lọc báo cáo'**
  String get filterReports;

  /// No description provided for @sortReports.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp'**
  String get sortReports;

  /// No description provided for @sortByDate.
  ///
  /// In vi, this message translates to:
  /// **'Theo ngày'**
  String get sortByDate;

  /// No description provided for @sortByPriority.
  ///
  /// In vi, this message translates to:
  /// **'Theo mức độ'**
  String get sortByPriority;

  /// No description provided for @sortByStatus.
  ///
  /// In vi, this message translates to:
  /// **'Theo trạng thái'**
  String get sortByStatus;

  /// No description provided for @noReportsFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy báo cáo nào'**
  String get noReportsFound;

  /// No description provided for @noReportsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có báo cáo nào'**
  String get noReportsYet;

  /// No description provided for @createFirstReport.
  ///
  /// In vi, this message translates to:
  /// **'Hãy tạo báo cáo đầu tiên!'**
  String get createFirstReport;

  /// No description provided for @pullToRefresh.
  ///
  /// In vi, this message translates to:
  /// **'Kéo để làm mới'**
  String get pullToRefresh;

  /// No description provided for @reportCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} báo cáo'**
  String reportCount(int count);

  /// No description provided for @createNewReport.
  ///
  /// In vi, this message translates to:
  /// **'Tạo báo cáo mới'**
  String get createNewReport;

  /// No description provided for @editReport.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa báo cáo'**
  String get editReport;

  /// No description provided for @reportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu đề'**
  String get reportTitle;

  /// No description provided for @enterReportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tiêu đề báo cáo'**
  String get enterReportTitle;

  /// No description provided for @reportDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết'**
  String get reportDescription;

  /// No description provided for @enterReportDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết vấn đề...'**
  String get enterReportDescription;

  /// No description provided for @reportCategory.
  ///
  /// In vi, this message translates to:
  /// **'Phân loại'**
  String get reportCategory;

  /// No description provided for @selectCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chọn phân loại'**
  String get selectCategory;

  /// No description provided for @reportPriority.
  ///
  /// In vi, this message translates to:
  /// **'Mức độ ưu tiên'**
  String get reportPriority;

  /// No description provided for @selectPriority.
  ///
  /// In vi, this message translates to:
  /// **'Chọn mức độ'**
  String get selectPriority;

  /// No description provided for @reportLocation.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí'**
  String get reportLocation;

  /// No description provided for @enterLocation.
  ///
  /// In vi, this message translates to:
  /// **'Nhập vị trí xảy ra sự cố'**
  String get enterLocation;

  /// No description provided for @reportDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Bộ phận'**
  String get reportDepartment;

  /// No description provided for @selectDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Chọn bộ phận'**
  String get selectDepartment;

  /// No description provided for @attachments.
  ///
  /// In vi, this message translates to:
  /// **'Tệp đính kèm'**
  String get attachments;

  /// No description provided for @addPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh'**
  String get addPhoto;

  /// No description provided for @addVideo.
  ///
  /// In vi, this message translates to:
  /// **'Thêm video'**
  String get addVideo;

  /// No description provided for @takePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get takePhoto;

  /// No description provided for @recordVideo.
  ///
  /// In vi, this message translates to:
  /// **'Quay video'**
  String get recordVideo;

  /// No description provided for @chooseFromGallery.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ thư viện'**
  String get chooseFromGallery;

  /// No description provided for @removeAttachment.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tệp đính kèm'**
  String get removeAttachment;

  /// No description provided for @submitReport.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo'**
  String get submitReport;

  /// No description provided for @reportSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo đã được gửi'**
  String get reportSubmitted;

  /// No description provided for @reportSubmitFailed.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo thất bại'**
  String get reportSubmitFailed;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tiêu đề'**
  String get pleaseEnterTitle;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mô tả'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn phân loại'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseSelectPriority.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn mức độ'**
  String get pleaseSelectPriority;

  /// No description provided for @pleaseSelectDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn bộ phận'**
  String get pleaseSelectDepartment;

  /// No description provided for @discardReportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hủy báo cáo?'**
  String get discardReportTitle;

  /// No description provided for @discardReportMessage.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi của bạn sẽ không được lưu. Bạn có chắc chắn muốn thoát?'**
  String get discardReportMessage;

  /// No description provided for @continueEditing.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục chỉnh sửa'**
  String get continueEditing;

  /// No description provided for @discardReport.
  ///
  /// In vi, this message translates to:
  /// **'Hủy báo cáo'**
  String get discardReport;

  /// No description provided for @photo.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In vi, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @photos.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In vi, this message translates to:
  /// **'Video'**
  String get videos;

  /// No description provided for @addMedia.
  ///
  /// In vi, this message translates to:
  /// **'Thêm phương tiện'**
  String get addMedia;

  /// No description provided for @maxPhotosReached.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt số lượng ảnh tối đa'**
  String get maxPhotosReached;

  /// No description provided for @maxVideosReached.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt số lượng video tối đa'**
  String get maxVideosReached;

  /// No description provided for @permissionRequired.
  ///
  /// In vi, this message translates to:
  /// **'Cần cấp quyền'**
  String get permissionRequired;

  /// No description provided for @cameraPermission.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng cấp quyền truy cập camera'**
  String get cameraPermission;

  /// No description provided for @galleryPermission.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng cấp quyền truy cập thư viện ảnh'**
  String get galleryPermission;

  /// No description provided for @microphonePermission.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng cấp quyền truy cập microphone'**
  String get microphonePermission;

  /// No description provided for @goToSettings.
  ///
  /// In vi, this message translates to:
  /// **'Mở cài đặt'**
  String get goToSettings;

  /// No description provided for @reportDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết báo cáo'**
  String get reportDetail;

  /// No description provided for @reportInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin báo cáo'**
  String get reportInfo;

  /// No description provided for @reportStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get reportStatus;

  /// No description provided for @reportCreatedAt.
  ///
  /// In vi, this message translates to:
  /// **'Ngày tạo'**
  String get reportCreatedAt;

  /// No description provided for @reportUpdatedAt.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật lần cuối'**
  String get reportUpdatedAt;

  /// No description provided for @reportedBy.
  ///
  /// In vi, this message translates to:
  /// **'Người báo cáo'**
  String get reportedBy;

  /// No description provided for @assignedTo.
  ///
  /// In vi, this message translates to:
  /// **'Người xử lý'**
  String get assignedTo;

  /// No description provided for @resolution.
  ///
  /// In vi, this message translates to:
  /// **'Cách xử lý'**
  String get resolution;

  /// No description provided for @comments.
  ///
  /// In vi, this message translates to:
  /// **'Bình luận'**
  String get comments;

  /// No description provided for @addComment.
  ///
  /// In vi, this message translates to:
  /// **'Thêm bình luận'**
  String get addComment;

  /// No description provided for @enterComment.
  ///
  /// In vi, this message translates to:
  /// **'Nhập bình luận...'**
  String get enterComment;

  /// No description provided for @sendComment.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get sendComment;

  /// No description provided for @noComments.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bình luận nào'**
  String get noComments;

  /// No description provided for @timeline.
  ///
  /// In vi, this message translates to:
  /// **'Tiến trình xử lý'**
  String get timeline;

  /// No description provided for @viewAttachments.
  ///
  /// In vi, this message translates to:
  /// **'Xem tệp đính kèm'**
  String get viewAttachments;

  /// No description provided for @reportHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử báo cáo'**
  String get reportHistory;

  /// No description provided for @historyEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lịch sử'**
  String get historyEmpty;

  /// No description provided for @filterByStatus.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo trạng thái'**
  String get filterByStatus;

  /// No description provided for @filterByPriority.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo mức độ'**
  String get filterByPriority;

  /// No description provided for @filterByDate.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo ngày'**
  String get filterByDate;

  /// No description provided for @dateRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng thời gian'**
  String get dateRange;

  /// No description provided for @fromDate.
  ///
  /// In vi, this message translates to:
  /// **'Từ ngày'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In vi, this message translates to:
  /// **'Đến ngày'**
  String get toDate;

  /// No description provided for @applyFilter.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get applyFilter;

  /// No description provided for @clearFilter.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ lọc'**
  String get clearFilter;

  /// No description provided for @statusAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get statusAll;

  /// No description provided for @statusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xử lý'**
  String get statusPending;

  /// No description provided for @statusProcessing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý'**
  String get statusProcessing;

  /// No description provided for @statusCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get statusCompleted;

  /// No description provided for @statusClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đã đóng'**
  String get statusClosed;

  /// No description provided for @statusRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get statusRejected;

  /// No description provided for @statusApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get statusApproved;

  /// No description provided for @statusInProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đang tiến hành'**
  String get statusInProgress;

  /// No description provided for @statusOnHold.
  ///
  /// In vi, this message translates to:
  /// **'Tạm hoãn'**
  String get statusOnHold;

  /// No description provided for @statusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get statusCancelled;

  /// No description provided for @priorityAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get priorityAll;

  /// No description provided for @priorityUrgent.
  ///
  /// In vi, this message translates to:
  /// **'Khẩn cấp'**
  String get priorityUrgent;

  /// No description provided for @priorityHigh.
  ///
  /// In vi, this message translates to:
  /// **'Cao'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In vi, this message translates to:
  /// **'Thấp'**
  String get priorityLow;

  /// No description provided for @categoryMachine.
  ///
  /// In vi, this message translates to:
  /// **'Máy móc'**
  String get categoryMachine;

  /// No description provided for @categoryEquipment.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị'**
  String get categoryEquipment;

  /// No description provided for @categorySafety.
  ///
  /// In vi, this message translates to:
  /// **'An toàn'**
  String get categorySafety;

  /// No description provided for @categoryQuality.
  ///
  /// In vi, this message translates to:
  /// **'Chất lượng'**
  String get categoryQuality;

  /// No description provided for @categoryProcess.
  ///
  /// In vi, this message translates to:
  /// **'Quy trình'**
  String get categoryProcess;

  /// No description provided for @categoryEnvironment.
  ///
  /// In vi, this message translates to:
  /// **'Môi trường'**
  String get categoryEnvironment;

  /// No description provided for @categoryMaintenance.
  ///
  /// In vi, this message translates to:
  /// **'Bảo trì'**
  String get categoryMaintenance;

  /// No description provided for @categoryOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get categoryOther;

  /// No description provided for @ideaBox.
  ///
  /// In vi, this message translates to:
  /// **'Hộp ý tưởng'**
  String get ideaBox;

  /// No description provided for @ideaList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách ý tưởng'**
  String get ideaList;

  /// No description provided for @myIdeas.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng của tôi'**
  String get myIdeas;

  /// No description provided for @allIdeas.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả ý tưởng'**
  String get allIdeas;

  /// No description provided for @createIdea.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ý tưởng'**
  String get createIdea;

  /// No description provided for @submitIdea.
  ///
  /// In vi, this message translates to:
  /// **'Gửi ý tưởng'**
  String get submitIdea;

  /// No description provided for @ideaSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng đã được gửi'**
  String get ideaSubmitted;

  /// No description provided for @noIdeasFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy ý tưởng nào'**
  String get noIdeasFound;

  /// No description provided for @noIdeasYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ý tưởng nào'**
  String get noIdeasYet;

  /// No description provided for @createFirstIdea.
  ///
  /// In vi, this message translates to:
  /// **'Hãy chia sẻ ý tưởng đầu tiên!'**
  String get createFirstIdea;

  /// No description provided for @ideaCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} ý tưởng'**
  String ideaCount(int count);

  /// No description provided for @filterIdeas.
  ///
  /// In vi, this message translates to:
  /// **'Lọc ý tưởng'**
  String get filterIdeas;

  /// No description provided for @sortIdeas.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp'**
  String get sortIdeas;

  /// No description provided for @mostRecent.
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get mostRecent;

  /// No description provided for @mostLiked.
  ///
  /// In vi, this message translates to:
  /// **'Được thích nhiều nhất'**
  String get mostLiked;

  /// No description provided for @mostCommented.
  ///
  /// In vi, this message translates to:
  /// **'Nhiều bình luận nhất'**
  String get mostCommented;

  /// No description provided for @createNewIdea.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ý tưởng mới'**
  String get createNewIdea;

  /// No description provided for @editIdea.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa ý tưởng'**
  String get editIdea;

  /// No description provided for @ideaTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu đề ý tưởng'**
  String get ideaTitle;

  /// No description provided for @enterIdeaTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tiêu đề ý tưởng'**
  String get enterIdeaTitle;

  /// No description provided for @ideaDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả ý tưởng'**
  String get ideaDescription;

  /// No description provided for @enterIdeaDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết ý tưởng của bạn...'**
  String get enterIdeaDescription;

  /// No description provided for @ideaCategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get ideaCategory;

  /// No description provided for @selectIdeaCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục'**
  String get selectIdeaCategory;

  /// No description provided for @ideaBenefit.
  ///
  /// In vi, this message translates to:
  /// **'Lợi ích dự kiến'**
  String get ideaBenefit;

  /// No description provided for @enterIdeaBenefit.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả lợi ích của ý tưởng...'**
  String get enterIdeaBenefit;

  /// No description provided for @ideaCost.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí ước tính'**
  String get ideaCost;

  /// No description provided for @enterIdeaCost.
  ///
  /// In vi, this message translates to:
  /// **'Nhập chi phí ước tính'**
  String get enterIdeaCost;

  /// No description provided for @ideaImplementation.
  ///
  /// In vi, this message translates to:
  /// **'Cách thực hiện'**
  String get ideaImplementation;

  /// No description provided for @enterIdeaImplementation.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả cách thực hiện ý tưởng...'**
  String get enterIdeaImplementation;

  /// No description provided for @addIdeaAttachment.
  ///
  /// In vi, this message translates to:
  /// **'Thêm tệp đính kèm'**
  String get addIdeaAttachment;

  /// No description provided for @pleaseEnterIdeaTitle.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tiêu đề ý tưởng'**
  String get pleaseEnterIdeaTitle;

  /// No description provided for @pleaseEnterIdeaDescription.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mô tả ý tưởng'**
  String get pleaseEnterIdeaDescription;

  /// No description provided for @pleaseSelectIdeaCategory.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn danh mục'**
  String get pleaseSelectIdeaCategory;

  /// No description provided for @discardIdeaTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hủy ý tưởng?'**
  String get discardIdeaTitle;

  /// No description provided for @discardIdeaMessage.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi của bạn sẽ không được lưu. Bạn có chắc chắn muốn thoát?'**
  String get discardIdeaMessage;

  /// No description provided for @continueEditingIdea.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục chỉnh sửa'**
  String get continueEditingIdea;

  /// No description provided for @discardIdea.
  ///
  /// In vi, this message translates to:
  /// **'Hủy ý tưởng'**
  String get discardIdea;

  /// No description provided for @ideaDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết ý tưởng'**
  String get ideaDetail;

  /// No description provided for @ideaInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin ý tưởng'**
  String get ideaInfo;

  /// No description provided for @ideaStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get ideaStatus;

  /// No description provided for @ideaCreatedAt.
  ///
  /// In vi, this message translates to:
  /// **'Ngày tạo'**
  String get ideaCreatedAt;

  /// No description provided for @ideaUpdatedAt.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật lần cuối'**
  String get ideaUpdatedAt;

  /// No description provided for @ideaSubmittedBy.
  ///
  /// In vi, this message translates to:
  /// **'Người gửi'**
  String get ideaSubmittedBy;

  /// No description provided for @ideaReviewedBy.
  ///
  /// In vi, this message translates to:
  /// **'Người xét duyệt'**
  String get ideaReviewedBy;

  /// No description provided for @ideaLikes.
  ///
  /// In vi, this message translates to:
  /// **'Lượt thích'**
  String get ideaLikes;

  /// No description provided for @likeIdea.
  ///
  /// In vi, this message translates to:
  /// **'Thích'**
  String get likeIdea;

  /// No description provided for @unlikeIdea.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ thích'**
  String get unlikeIdea;

  /// No description provided for @shareIdea.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get shareIdea;

  /// No description provided for @ideaComments.
  ///
  /// In vi, this message translates to:
  /// **'Bình luận'**
  String get ideaComments;

  /// No description provided for @addIdeaComment.
  ///
  /// In vi, this message translates to:
  /// **'Thêm bình luận'**
  String get addIdeaComment;

  /// No description provided for @enterIdeaComment.
  ///
  /// In vi, this message translates to:
  /// **'Nhập bình luận...'**
  String get enterIdeaComment;

  /// No description provided for @sendIdeaComment.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get sendIdeaComment;

  /// No description provided for @noIdeaComments.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bình luận nào'**
  String get noIdeaComments;

  /// No description provided for @reviewIdea.
  ///
  /// In vi, this message translates to:
  /// **'Xét duyệt'**
  String get reviewIdea;

  /// No description provided for @approveIdea.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt ý tưởng'**
  String get approveIdea;

  /// No description provided for @rejectIdea.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối ý tưởng'**
  String get rejectIdea;

  /// No description provided for @ideaApproved.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng đã được duyệt'**
  String get ideaApproved;

  /// No description provided for @ideaRejected.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng đã bị từ chối'**
  String get ideaRejected;

  /// No description provided for @rejectReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do từ chối'**
  String get rejectReason;

  /// No description provided for @enterRejectReason.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lý do từ chối...'**
  String get enterRejectReason;

  /// No description provided for @ideaStatusAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get ideaStatusAll;

  /// No description provided for @ideaStatusDraft.
  ///
  /// In vi, this message translates to:
  /// **'Bản nháp'**
  String get ideaStatusDraft;

  /// No description provided for @ideaStatusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get ideaStatusPending;

  /// No description provided for @ideaStatusUnderReview.
  ///
  /// In vi, this message translates to:
  /// **'Đang xem xét'**
  String get ideaStatusUnderReview;

  /// No description provided for @ideaStatusApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get ideaStatusApproved;

  /// No description provided for @ideaStatusRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get ideaStatusRejected;

  /// No description provided for @ideaStatusImplementing.
  ///
  /// In vi, this message translates to:
  /// **'Đang triển khai'**
  String get ideaStatusImplementing;

  /// No description provided for @ideaStatusImplemented.
  ///
  /// In vi, this message translates to:
  /// **'Đã triển khai'**
  String get ideaStatusImplemented;

  /// No description provided for @ideaStatusClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đã đóng'**
  String get ideaStatusClosed;

  /// No description provided for @ideaCategoryImprovement.
  ///
  /// In vi, this message translates to:
  /// **'Cải tiến'**
  String get ideaCategoryImprovement;

  /// No description provided for @ideaCategoryInnovation.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mới'**
  String get ideaCategoryInnovation;

  /// No description provided for @ideaCategoryCostSaving.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm'**
  String get ideaCategoryCostSaving;

  /// No description provided for @ideaCategorySafety.
  ///
  /// In vi, this message translates to:
  /// **'An toàn'**
  String get ideaCategorySafety;

  /// No description provided for @ideaCategoryQuality.
  ///
  /// In vi, this message translates to:
  /// **'Chất lượng'**
  String get ideaCategoryQuality;

  /// No description provided for @ideaCategoryProductivity.
  ///
  /// In vi, this message translates to:
  /// **'Năng suất'**
  String get ideaCategoryProductivity;

  /// No description provided for @ideaCategoryEnvironment.
  ///
  /// In vi, this message translates to:
  /// **'Môi trường'**
  String get ideaCategoryEnvironment;

  /// No description provided for @ideaCategoryWorkplace.
  ///
  /// In vi, this message translates to:
  /// **'Nơi làm việc'**
  String get ideaCategoryWorkplace;

  /// No description provided for @ideaCategoryOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get ideaCategoryOther;

  /// No description provided for @camera.
  ///
  /// In vi, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @scanQRCode.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã QR'**
  String get scanQRCode;

  /// No description provided for @scanBarcode.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã vạch'**
  String get scanBarcode;

  /// No description provided for @flashOn.
  ///
  /// In vi, this message translates to:
  /// **'Bật đèn flash'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In vi, this message translates to:
  /// **'Tắt đèn flash'**
  String get flashOff;

  /// No description provided for @switchCamera.
  ///
  /// In vi, this message translates to:
  /// **'Đổi camera'**
  String get switchCamera;

  /// No description provided for @frontCamera.
  ///
  /// In vi, this message translates to:
  /// **'Camera trước'**
  String get frontCamera;

  /// No description provided for @backCamera.
  ///
  /// In vi, this message translates to:
  /// **'Camera sau'**
  String get backCamera;

  /// No description provided for @capturing.
  ///
  /// In vi, this message translates to:
  /// **'Đang chụp...'**
  String get capturing;

  /// No description provided for @captureFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh thất bại'**
  String get captureFailed;

  /// No description provided for @qrCodeDetected.
  ///
  /// In vi, this message translates to:
  /// **'Đã phát hiện mã QR'**
  String get qrCodeDetected;

  /// No description provided for @barcodeDetected.
  ///
  /// In vi, this message translates to:
  /// **'Đã phát hiện mã vạch'**
  String get barcodeDetected;

  /// No description provided for @invalidQRCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR không hợp lệ'**
  String get invalidQRCode;

  /// No description provided for @scanAgain.
  ///
  /// In vi, this message translates to:
  /// **'Quét lại'**
  String get scanAgain;

  /// No description provided for @processingImage.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý ảnh...'**
  String get processingImage;

  /// No description provided for @zoomIn.
  ///
  /// In vi, this message translates to:
  /// **'Phóng to'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhỏ'**
  String get zoomOut;

  /// No description provided for @chat.
  ///
  /// In vi, this message translates to:
  /// **'Trò chuyện'**
  String get chat;

  /// No description provided for @aiAssistant.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý AI'**
  String get aiAssistant;

  /// No description provided for @aiChatTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý SmartFactory'**
  String get aiChatTitle;

  /// No description provided for @chatWithAI.
  ///
  /// In vi, this message translates to:
  /// **'Chat với AI'**
  String get chatWithAI;

  /// No description provided for @typeMessage.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tin nhắn...'**
  String get typeMessage;

  /// No description provided for @sendMessage.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get sendMessage;

  /// No description provided for @aiThinking.
  ///
  /// In vi, this message translates to:
  /// **'Đang suy nghĩ...'**
  String get aiThinking;

  /// No description provided for @aiTyping.
  ///
  /// In vi, this message translates to:
  /// **'AI đang trả lời...'**
  String get aiTyping;

  /// No description provided for @noMessages.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin nhắn nào'**
  String get noMessages;

  /// No description provided for @startConversation.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu cuộc trò chuyện'**
  String get startConversation;

  /// No description provided for @chatHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử chat'**
  String get chatHistory;

  /// No description provided for @clearChat.
  ///
  /// In vi, this message translates to:
  /// **'Xóa cuộc trò chuyện'**
  String get clearChat;

  /// No description provided for @clearChatConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa tất cả tin nhắn?'**
  String get clearChatConfirm;

  /// No description provided for @chatCleared.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa cuộc trò chuyện'**
  String get chatCleared;

  /// No description provided for @aiWelcomeMessage.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào! Tôi là trợ lý AI của SmartFactory. Tôi có thể giúp gì cho bạn?'**
  String get aiWelcomeMessage;

  /// No description provided for @aiErrorMessage.
  ///
  /// In vi, this message translates to:
  /// **'Xin lỗi, đã xảy ra lỗi. Vui lòng thử lại.'**
  String get aiErrorMessage;

  /// No description provided for @aiNoResponseMessage.
  ///
  /// In vi, this message translates to:
  /// **'Không nhận được phản hồi. Vui lòng thử lại.'**
  String get aiNoResponseMessage;

  /// No description provided for @speechToText.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển giọng nói thành văn bản'**
  String get speechToText;

  /// No description provided for @listeningMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đang lắng nghe...'**
  String get listeningMessage;

  /// No description provided for @stopListening.
  ///
  /// In vi, this message translates to:
  /// **'Dừng lắng nghe'**
  String get stopListening;

  /// No description provided for @voiceInputNotAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Nhập liệu bằng giọng nói không khả dụng'**
  String get voiceInputNotAvailable;

  /// No description provided for @copyMessage.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get copyMessage;

  /// No description provided for @messageCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép tin nhắn'**
  String get messageCopied;

  /// No description provided for @leaderReportManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý báo cáo'**
  String get leaderReportManagement;

  /// No description provided for @pendingReports.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo chờ duyệt'**
  String get pendingReports;

  /// No description provided for @reviewReport.
  ///
  /// In vi, this message translates to:
  /// **'Xét duyệt báo cáo'**
  String get reviewReport;

  /// No description provided for @approveReport.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt báo cáo'**
  String get approveReport;

  /// No description provided for @rejectReport.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối báo cáo'**
  String get rejectReport;

  /// No description provided for @reportApproved.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo đã được duyệt'**
  String get reportApproved;

  /// No description provided for @reportRejected.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo đã bị từ chối'**
  String get reportRejected;

  /// No description provided for @assignReport.
  ///
  /// In vi, this message translates to:
  /// **'Phân công xử lý'**
  String get assignReport;

  /// No description provided for @selectAssignee.
  ///
  /// In vi, this message translates to:
  /// **'Chọn người xử lý'**
  String get selectAssignee;

  /// No description provided for @assignedSuccessfully.
  ///
  /// In vi, this message translates to:
  /// **'Phân công thành công'**
  String get assignedSuccessfully;

  /// No description provided for @rejectReasonLabel.
  ///
  /// In vi, this message translates to:
  /// **'Lý do từ chối'**
  String get rejectReasonLabel;

  /// No description provided for @enterRejectReasonPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lý do từ chối báo cáo...'**
  String get enterRejectReasonPlaceholder;

  /// No description provided for @reviewNotes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú xét duyệt'**
  String get reviewNotes;

  /// No description provided for @enterReviewNotes.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú xét duyệt...'**
  String get enterReviewNotes;

  /// No description provided for @updateReportStatus.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật trạng thái'**
  String get updateReportStatus;

  /// No description provided for @statusUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái đã được cập nhật'**
  String get statusUpdated;

  /// No description provided for @resolutionDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết xử lý'**
  String get resolutionDetails;

  /// No description provided for @enterResolutionDetails.
  ///
  /// In vi, this message translates to:
  /// **'Nhập chi tiết cách xử lý...'**
  String get enterResolutionDetails;

  /// No description provided for @markAsResolved.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu đã xử lý'**
  String get markAsResolved;

  /// No description provided for @reopenReport.
  ///
  /// In vi, this message translates to:
  /// **'Mở lại báo cáo'**
  String get reopenReport;

  /// No description provided for @closeReport.
  ///
  /// In vi, this message translates to:
  /// **'Đóng báo cáo'**
  String get closeReport;

  /// No description provided for @viewStatistics.
  ///
  /// In vi, this message translates to:
  /// **'Xem thống kê'**
  String get viewStatistics;

  /// No description provided for @reportStatistics.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê báo cáo'**
  String get reportStatistics;

  /// No description provided for @totalReports.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số báo cáo'**
  String get totalReports;

  /// No description provided for @pendingCount.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xử lý'**
  String get pendingCount;

  /// No description provided for @processingCount.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý'**
  String get processingCount;

  /// No description provided for @completedCount.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get completedCount;

  /// No description provided for @thisWeekStats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê tuần này'**
  String get thisWeekStats;

  /// No description provided for @thisMonthStats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê tháng này'**
  String get thisMonthStats;

  /// No description provided for @voiceInput.
  ///
  /// In vi, this message translates to:
  /// **'Nhập bằng giọng nói'**
  String get voiceInput;

  /// No description provided for @tapToSpeak.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để nói'**
  String get tapToSpeak;

  /// No description provided for @listening.
  ///
  /// In vi, this message translates to:
  /// **'Đang nghe...'**
  String get listening;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý...'**
  String get processing;

  /// No description provided for @voiceRecognitionError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi nhận dạng giọng nói'**
  String get voiceRecognitionError;

  /// No description provided for @tryAgain.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng thử lại'**
  String get tryAgain;

  /// No description provided for @noSpeechDetected.
  ///
  /// In vi, this message translates to:
  /// **'Không phát hiện giọng nói'**
  String get noSpeechDetected;

  /// No description provided for @speechRecognitionNotAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Nhận dạng giọng nói không khả dụng'**
  String get speechRecognitionNotAvailable;

  /// No description provided for @errorGeneral.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi. Vui lòng thử lại.'**
  String get errorGeneral;

  /// No description provided for @errorNetwork.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi máy chủ. Vui lòng thử lại sau.'**
  String get errorServer;

  /// No description provided for @errorTimeout.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu quá thời gian. Vui lòng thử lại.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không có quyền thực hiện thao tác này.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy dữ liệu yêu cầu.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.'**
  String get errorValidation;

  /// No description provided for @errorUpload.
  ///
  /// In vi, this message translates to:
  /// **'Tải lên thất bại. Vui lòng thử lại.'**
  String get errorUpload;

  /// No description provided for @errorDownload.
  ///
  /// In vi, this message translates to:
  /// **'Tải xuống thất bại. Vui lòng thử lại.'**
  String get errorDownload;

  /// No description provided for @errorSaveData.
  ///
  /// In vi, this message translates to:
  /// **'Lưu dữ liệu thất bại. Vui lòng thử lại.'**
  String get errorSaveData;

  /// No description provided for @errorLoadData.
  ///
  /// In vi, this message translates to:
  /// **'Tải dữ liệu thất bại. Vui lòng thử lại.'**
  String get errorLoadData;

  /// No description provided for @errorEmptyField.
  ///
  /// In vi, this message translates to:
  /// **'Trường này không được để trống'**
  String get errorEmptyField;

  /// No description provided for @errorInvalidFormat.
  ///
  /// In vi, this message translates to:
  /// **'Định dạng không hợp lệ'**
  String get errorInvalidFormat;

  /// No description provided for @errorFileTooLarge.
  ///
  /// In vi, this message translates to:
  /// **'Tệp quá lớn. Vui lòng chọn tệp nhỏ hơn.'**
  String get errorFileTooLarge;

  /// No description provided for @errorUnsupportedFormat.
  ///
  /// In vi, this message translates to:
  /// **'Định dạng tệp không được hỗ trợ.'**
  String get errorUnsupportedFormat;

  /// No description provided for @successSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu thành công'**
  String get successSaved;

  /// No description provided for @successDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa thành công'**
  String get successDeleted;

  /// No description provided for @successUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật thành công'**
  String get successUpdated;

  /// No description provided for @successSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi thành công'**
  String get successSubmitted;

  /// No description provided for @successUploaded.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải lên thành công'**
  String get successUploaded;

  /// No description provided for @successDownloaded.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải xuống thành công'**
  String get successDownloaded;

  /// No description provided for @successCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép'**
  String get successCopied;

  /// No description provided for @confirmDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa mục này? Hành động này không thể hoàn tác.'**
  String get confirmDeleteMessage;

  /// No description provided for @confirmDiscard.
  ///
  /// In vi, this message translates to:
  /// **'Hủy thay đổi'**
  String get confirmDiscard;

  /// No description provided for @confirmDiscardMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có những thay đổi chưa lưu. Bạn có chắc muốn hủy?'**
  String get confirmDiscardMessage;

  /// No description provided for @confirmLogout.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đăng xuất'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'**
  String get confirmLogoutMessage;

  /// No description provided for @confirmSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận gửi'**
  String get confirmSubmit;

  /// No description provided for @confirmSubmitMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn gửi? Thông tin sẽ không thể chỉnh sửa sau khi gửi.'**
  String get confirmSubmitMessage;

  /// No description provided for @searchPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm...'**
  String get searchPlaceholder;

  /// No description provided for @commentPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Viết bình luận...'**
  String get commentPlaceholder;

  /// No description provided for @notePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú...'**
  String get notePlaceholder;

  /// No description provided for @descriptionPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mô tả...'**
  String get descriptionPlaceholder;

  /// No description provided for @titlePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tiêu đề...'**
  String get titlePlaceholder;

  /// No description provided for @justNow.
  ///
  /// In vi, this message translates to:
  /// **'Vừa xong'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In vi, this message translates to:
  /// **'{count} phút trước'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In vi, this message translates to:
  /// **'{count} giờ trước'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày trước'**
  String daysAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In vi, this message translates to:
  /// **'{count} tuần trước'**
  String weeksAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In vi, this message translates to:
  /// **'{count} tháng trước'**
  String monthsAgo(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ja', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja':
      return AppLocalizationsJa();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
