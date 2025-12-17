// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get navReports => '報告';

  @override
  String get navIdeaBox => 'アイデア';

  @override
  String get navProfile => '個人';

  @override
  String get navSettings => '設定';

  @override
  String get navHome => 'ホーム';

  @override
  String get navNotifications => '通知';

  @override
  String get roleLeader => '管理者';

  @override
  String get roleWorker => '作業員';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get confirm => '確認';

  @override
  String get submit => '送信';

  @override
  String get search => '検索';

  @override
  String get filter => 'フィルター';

  @override
  String get refresh => '更新';

  @override
  String get close => '閉じる';

  @override
  String get back => '戻る';

  @override
  String get next => '次へ';

  @override
  String get previous => '前へ';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get retry => '再試行';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get ok => 'OK';

  @override
  String get done => '完了';

  @override
  String get apply => '適用';

  @override
  String get reset => 'リセット';

  @override
  String get clear => 'クリア';

  @override
  String get selectAll => '全て選択';

  @override
  String get deselectAll => '選択解除';

  @override
  String get noData => 'データなし';

  @override
  String get noResults => '結果なし';

  @override
  String get seeAll => 'すべて見る';

  @override
  String get more => 'もっと見る';

  @override
  String get less => '閉じる';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get thisWeek => '今週';

  @override
  String get thisMonth => '今月';

  @override
  String get all => 'すべて';

  @override
  String get report => '報告';

  @override
  String get sendReport => '報告を送信';

  @override
  String get incidentReport => 'インシデント報告';

  @override
  String get incidentTitle => 'インシデントタイトル';

  @override
  String get enterIncidentTitle => 'インシデントタイトルを入力';

  @override
  String get location => '場所';

  @override
  String get priority => '優先度';

  @override
  String get description => '説明';

  @override
  String get enterDescription => '詳細を入力...';

  @override
  String get attachEvidence => '証拠を添付';

  @override
  String get uploadMedia => 'アップロード';

  @override
  String get stopRecording => '録音停止';

  @override
  String get record => '録音';

  @override
  String get reportSubmitSuccess => '報告を送信しました';

  @override
  String get searchByCodeTitleLocation => 'コード、タイトル、場所で検索...';

  @override
  String get noMatchingResults => '一致する結果がありません';

  @override
  String get noIncidentReports => 'インシデント報告はありません';

  @override
  String get searchByIdOrTitle => 'IDまたはタイトルで検索';

  @override
  String get noReports => '報告はありません';

  @override
  String get rateQuality => '対応品質を評価';

  @override
  String get yourComment => 'コメント';

  @override
  String get optional => '任意';

  @override
  String get thankYouForRating => '評価ありがとうございます！';

  @override
  String get send => '送信';

  @override
  String get helpfulArticle => 'この記事は役に立ちましたか？';

  @override
  String get thankYouForFeedback => 'フィードバックありがとうございます！';

  @override
  String get pageDeveloping => 'このページは開発中です';

  @override
  String get loginTitle => 'ログイン';

  @override
  String get loginSubtitle => 'おかえりなさい';

  @override
  String get employeeId => '社員番号';

  @override
  String get enterEmployeeId => '社員番号を入力';

  @override
  String get password => 'パスワード';

  @override
  String get enterPassword => 'パスワードを入力';

  @override
  String get loginButton => 'ログイン';

  @override
  String get loggingIn => 'ログイン中...';

  @override
  String get rememberMe => 'ログイン状態を保持';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get loginFailed => 'ログイン失敗';

  @override
  String get invalidCredentials => '社員番号またはパスワードが正しくありません';

  @override
  String get pleaseEnterEmployeeId => '社員番号を入力してください';

  @override
  String get pleaseEnterPassword => 'パスワードを入力してください';

  @override
  String get biometricLogin => '生体認証でログイン';

  @override
  String get useBiometric => '指紋/Face IDを使用';

  @override
  String get biometricNotAvailable => '生体認証が利用できません';

  @override
  String get biometricNotEnrolled => '生体認証が登録されていません';

  @override
  String get biometricAuthFailed => '生体認証に失敗しました';

  @override
  String get pleaseAuthenticate => '認証してログインしてください';

  @override
  String get loginWithBiometric => '指紋/Face IDでログイン';

  @override
  String get orLoginWithPassword => 'またはパスワードでログイン';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirmTitle => 'ログアウト';

  @override
  String get logoutConfirmMessage => 'ログアウトしてもよろしいですか？';

  @override
  String homeGreeting(String name) {
    return 'こんにちは、$nameさん！';
  }

  @override
  String get homeSubtitle => 'SmartFactory Connectへようこそ';

  @override
  String get quickActions => 'クイックアクセス';

  @override
  String get newReport => '新規報告';

  @override
  String get newIdea => '新規アイデア';

  @override
  String get scanQR => 'QRスキャン';

  @override
  String get viewNews => 'ニュースを見る';

  @override
  String get recentReports => '最近の報告';

  @override
  String get recentIdeas => '最近のアイデア';

  @override
  String get newsTitle => 'ニュース・イベント';

  @override
  String get allNews => 'すべてのニュース';

  @override
  String get noNewsAvailable => 'ニュースはありません';

  @override
  String get loadingNews => 'ニュースを読み込み中...';

  @override
  String get newsAndEvents => 'ニュース・イベント';

  @override
  String get newsDetail => 'ニュース詳細';

  @override
  String get publishedAt => '公開日';

  @override
  String get author => '投稿者';

  @override
  String get category => 'カテゴリ';

  @override
  String get newsCategories => 'ニュースカテゴリ';

  @override
  String get announcement => 'お知らせ';

  @override
  String get event => 'イベント';

  @override
  String get policy => '規定';

  @override
  String get training => '研修';

  @override
  String get achievement => '成果';

  @override
  String get other => 'その他';

  @override
  String get readMore => '続きを読む';

  @override
  String get shareNews => '共有';

  @override
  String get relatedNews => '関連ニュース';

  @override
  String get notifications => '通知';

  @override
  String get noNotifications => '新しい通知はありません';

  @override
  String get markAllRead => 'すべて既読にする';

  @override
  String get clearAllNotifications => 'すべての通知を削除';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get newNotification => '新着通知';

  @override
  String get unreadNotifications => '未読通知';

  @override
  String get profile => 'プロフィール';

  @override
  String get personalInfo => '個人情報';

  @override
  String get editProfile => 'プロフィール編集';

  @override
  String get accountSettings => 'アカウント設定';

  @override
  String get fullName => '氏名';

  @override
  String get email => 'メールアドレス';

  @override
  String get phone => '電話番号';

  @override
  String get department => '部署';

  @override
  String get position => '役職';

  @override
  String get role => '役割';

  @override
  String get joinDate => '入社日';

  @override
  String get employeeCode => '社員番号';

  @override
  String get profilePhoto => 'プロフィール写真';

  @override
  String get dateOfBirth => '生年月日';

  @override
  String get address => '住所';

  @override
  String get gender => '性別';

  @override
  String get notUpdated => '未更新';

  @override
  String get workInfo => '勤務情報';

  @override
  String get workShift => 'シフト';

  @override
  String get workStatus => '勤務状態';

  @override
  String get avatarUpload => 'プロフィール画像を変更';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get discardChanges => '変更を破棄';

  @override
  String get changePassword => 'パスワード変更';

  @override
  String get currentPassword => '現在のパスワード';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get confirmPassword => 'パスワードを確認';

  @override
  String get passwordChanged => 'パスワードを変更しました';

  @override
  String get passwordMismatch => 'パスワードが一致しません';

  @override
  String get invalidCurrentPassword => '現在のパスワードが正しくありません';

  @override
  String get personalInfoTitle => '個人情報';

  @override
  String get editPersonalInfo => '情報を編集';

  @override
  String get updateSuccess => '更新しました';

  @override
  String get updateFailed => '更新に失敗しました';

  @override
  String get enterFullName => '氏名を入力';

  @override
  String get pleaseEnterFullName => '氏名を入力してください';

  @override
  String get enterEmail => 'メールアドレスを入力';

  @override
  String get enterPhone => '電話番号を入力';

  @override
  String get invalidEmail => '無効なメールアドレス';

  @override
  String get invalidPhone => '無効な電話番号';

  @override
  String get settings => '設定';

  @override
  String get general => '一般';

  @override
  String get appearance => '外観';

  @override
  String get language => '言語';

  @override
  String get vietnamese => 'ベトナム語';

  @override
  String get japanese => '日本語';

  @override
  String get english => '英語';

  @override
  String get theme => 'テーマ';

  @override
  String get lightMode => 'ライトモード';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get systemDefault => 'システム設定';

  @override
  String get pushNotifications => 'プッシュ通知';

  @override
  String get emailNotifications => 'メール通知';

  @override
  String get soundEnabled => 'サウンド';

  @override
  String get vibrationEnabled => 'バイブレーション';

  @override
  String get privacy => 'プライバシー';

  @override
  String get dataSync => 'データ同期';

  @override
  String get autoSync => '自動同期';

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get lastSynced => '最終同期';

  @override
  String get about => 'アプリについて';

  @override
  String get version => 'バージョン';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get helpSupport => 'ヘルプ・サポート';

  @override
  String get contactUs => 'お問い合わせ';

  @override
  String get feedback => 'フィードバック';

  @override
  String get rateApp => 'アプリを評価';

  @override
  String get clearCache => 'キャッシュを削除';

  @override
  String get cacheCleared => 'キャッシュを削除しました';

  @override
  String get reportList => '報告一覧';

  @override
  String get myReports => '自分の報告';

  @override
  String get allReports => 'すべての報告';

  @override
  String get createReport => '報告作成';

  @override
  String get filterReports => '報告をフィルター';

  @override
  String get sortReports => '並べ替え';

  @override
  String get sortByDate => '日付順';

  @override
  String get sortByPriority => '優先度順';

  @override
  String get sortByStatus => '状態順';

  @override
  String get noReportsFound => '報告が見つかりません';

  @override
  String get noReportsYet => '報告はまだありません';

  @override
  String get createFirstReport => '最初の報告を作成しましょう！';

  @override
  String get pullToRefresh => 'プルして更新';

  @override
  String reportCount(int count) {
    return '$count件の報告';
  }

  @override
  String get createNewReport => '新規報告作成';

  @override
  String get editReport => '報告を編集';

  @override
  String get reportTitle => 'タイトル';

  @override
  String get enterReportTitle => '報告タイトルを入力';

  @override
  String get reportDescription => '詳細説明';

  @override
  String get enterReportDescription => '問題の詳細を説明してください...';

  @override
  String get reportCategory => '分類';

  @override
  String get selectCategory => '分類を選択';

  @override
  String get reportPriority => '優先度';

  @override
  String get selectPriority => '優先度を選択';

  @override
  String get reportLocation => '場所';

  @override
  String get enterLocation => '発生場所を入力';

  @override
  String get reportDepartment => '部署';

  @override
  String get selectDepartment => '部署を選択';

  @override
  String get attachments => '添付ファイル';

  @override
  String get addPhoto => '写真を追加';

  @override
  String get addVideo => '動画を追加';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get recordVideo => '動画を撮る';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String get removeAttachment => '添付を削除';

  @override
  String get submitReport => '報告を送信';

  @override
  String get reportSubmitted => '報告を送信しました';

  @override
  String get reportSubmitFailed => '報告の送信に失敗しました';

  @override
  String get pleaseEnterTitle => 'タイトルを入力してください';

  @override
  String get pleaseEnterDescription => '説明を入力してください';

  @override
  String get pleaseSelectCategory => '分類を選択してください';

  @override
  String get pleaseSelectPriority => '優先度を選択してください';

  @override
  String get pleaseSelectDepartment => '部署を選択してください';

  @override
  String get discardReportTitle => '報告を破棄しますか？';

  @override
  String get discardReportMessage => '変更は保存されません。よろしいですか？';

  @override
  String get continueEditing => '編集を続ける';

  @override
  String get discardReport => '報告を破棄';

  @override
  String get photo => '写真';

  @override
  String get video => '動画';

  @override
  String get photos => '写真';

  @override
  String get videos => '動画';

  @override
  String get addMedia => 'メディアを追加';

  @override
  String get maxPhotosReached => '写真の上限に達しました';

  @override
  String get maxVideosReached => '動画の上限に達しました';

  @override
  String get permissionRequired => '許可が必要です';

  @override
  String get permissionDenied => 'アクセス許可が拒否されました';

  @override
  String get cameraPermission => 'カメラへのアクセスを許可してください';

  @override
  String get galleryPermission => 'ギャラリーへのアクセスを許可してください';

  @override
  String get microphonePermission => 'マイクへのアクセスを許可してください';

  @override
  String get goToSettings => '設定を開く';

  @override
  String get reportDetail => '報告詳細';

  @override
  String get reportInfo => '報告情報';

  @override
  String get reportStatus => 'ステータス';

  @override
  String get reportCreatedAt => '作成日';

  @override
  String get createdAt => '作成日';

  @override
  String get reporter => '報告者';

  @override
  String get viewDetail => '詳細を見る';

  @override
  String get confirmCancel => 'キャンセル確認';

  @override
  String get reportUpdatedAt => '最終更新';

  @override
  String get reportedBy => '報告者';

  @override
  String get assignedTo => '担当者';

  @override
  String get resolution => '対応内容';

  @override
  String get comments => 'コメント';

  @override
  String get addComment => 'コメントを追加';

  @override
  String get enterComment => 'コメントを入力...';

  @override
  String get sendComment => '送信';

  @override
  String get noComments => 'コメントはありません';

  @override
  String get timeline => '対応履歴';

  @override
  String get viewAttachments => '添付ファイルを見る';

  @override
  String get reportHistory => '報告履歴';

  @override
  String get historyEmpty => '履歴はありません';

  @override
  String get filterByStatus => '状態でフィルター';

  @override
  String get filterByPriority => '優先度でフィルター';

  @override
  String get filterByDate => '日付でフィルター';

  @override
  String get dateRange => '期間';

  @override
  String get fromDate => '開始日';

  @override
  String get toDate => '終了日';

  @override
  String get applyFilter => '適用';

  @override
  String get clearFilter => 'フィルターをクリア';

  @override
  String get statusAll => 'すべて';

  @override
  String get statusPending => '対応待ち';

  @override
  String get statusProcessing => '対応中';

  @override
  String get statusCompleted => '完了';

  @override
  String get statusClosed => 'クローズ';

  @override
  String get statusRejected => '却下';

  @override
  String get statusApproved => '承認済み';

  @override
  String get statusInProgress => '進行中';

  @override
  String get statusOnHold => '保留中';

  @override
  String get statusCancelled => 'キャンセル';

  @override
  String get priorityAll => 'すべて';

  @override
  String get priorityUrgent => '緊急';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityLow => '低';

  @override
  String get low => '低';

  @override
  String get medium => '中';

  @override
  String get high => '高';

  @override
  String get critical => '緊急';

  @override
  String get categoryMachine => '機械';

  @override
  String get categoryEquipment => '設備';

  @override
  String get categorySafety => '安全';

  @override
  String get categoryQuality => '品質';

  @override
  String get categoryProcess => '工程';

  @override
  String get categoryEnvironment => '環境';

  @override
  String get categoryMaintenance => '保全';

  @override
  String get categoryOther => 'その他';

  @override
  String get categoryTechnical => '技術';

  @override
  String get categoryPersonnel => '人事';

  @override
  String get issueTypeQuality => '品質';

  @override
  String get issueTypeSafety => '安全';

  @override
  String get issueTypePerformance => '効率';

  @override
  String get issueTypeEnergySaving => '省エネ';

  @override
  String get issueTypeProcess => '工程';

  @override
  String get issueTypeWorkEnvironment => '職場環境';

  @override
  String get issueTypeWelfare => '福利厚生';

  @override
  String get issueTypePressure => 'プレッシャー / 人事';

  @override
  String get issueTypePsychologicalSafety => '心理的安全';

  @override
  String get issueTypeFairness => '公平性 - 業務';

  @override
  String get issueTypeOther => 'その他';

  @override
  String get difficultyEasy => '簡単';

  @override
  String get difficultyMedium => '普通';

  @override
  String get difficultyHard => '難しい';

  @override
  String get difficultyVeryHard => 'とても難しい';

  @override
  String get ideaSubmitted => 'アイデアを送信しました';

  @override
  String get ideaUnderReview => '審査中';

  @override
  String get ideaEscalated => '上位へ転送';

  @override
  String get ideaApproved => 'アイデアを承認しました';

  @override
  String get ideaRejected => 'アイデアを却下しました';

  @override
  String get ideaImplementing => '実施中';

  @override
  String get ideaCompleted => '完了';

  @override
  String get biometricFace => 'Face ID';

  @override
  String get biometricFingerprint => '指紋';

  @override
  String get biometricIris => '虹彩';

  @override
  String get biometricGeneric => '生体認証';

  @override
  String get biometricAuthReason => 'ログインのために認証してください';

  @override
  String get connectionSuccess => '接続成功！';

  @override
  String get connectionFailed => 'サーバーに接続できません';

  @override
  String get ideaBox => 'アイデアボックス';

  @override
  String get ideaList => 'アイデア一覧';

  @override
  String get myIdeas => '自分のアイデア';

  @override
  String get allIdeas => 'すべてのアイデア';

  @override
  String get createIdea => 'アイデア作成';

  @override
  String get submitIdea => 'アイデアを送信';

  @override
  String get noIdeasFound => 'アイデアが見つかりません';

  @override
  String get noIdeasYet => 'アイデアはまだありません';

  @override
  String get createFirstIdea => '最初のアイデアを共有しましょう！';

  @override
  String ideaCount(int count) {
    return '$count件のアイデア';
  }

  @override
  String get filterIdeas => 'アイデアをフィルター';

  @override
  String get sortIdeas => '並べ替え';

  @override
  String get mostRecent => '最新順';

  @override
  String get mostLiked => 'いいね順';

  @override
  String get mostCommented => 'コメント順';

  @override
  String get createNewIdea => '新規アイデア作成';

  @override
  String get editIdea => 'アイデアを編集';

  @override
  String get ideaTitle => 'アイデアタイトル';

  @override
  String get enterIdeaTitle => 'アイデアタイトルを入力';

  @override
  String get ideaDescription => 'アイデア説明';

  @override
  String get enterIdeaDescription => 'アイデアの詳細を説明してください...';

  @override
  String get ideaCategory => 'カテゴリ';

  @override
  String get selectIdeaCategory => 'カテゴリを選択';

  @override
  String get ideaBenefit => '期待される効果';

  @override
  String get enterIdeaBenefit => 'アイデアの効果を説明してください...';

  @override
  String get ideaCost => '概算コスト';

  @override
  String get enterIdeaCost => '概算コストを入力';

  @override
  String get ideaImplementation => '実施方法';

  @override
  String get enterIdeaImplementation => '実施方法を説明してください...';

  @override
  String get addIdeaAttachment => '添付ファイルを追加';

  @override
  String get pleaseEnterIdeaTitle => 'アイデアタイトルを入力してください';

  @override
  String get pleaseEnterIdeaDescription => 'アイデアの説明を入力してください';

  @override
  String get pleaseSelectIdeaCategory => 'カテゴリを選択してください';

  @override
  String get discardIdeaTitle => 'アイデアを破棄しますか？';

  @override
  String get discardIdeaMessage => '変更は保存されません。よろしいですか？';

  @override
  String get continueEditingIdea => '編集を続ける';

  @override
  String get discardIdea => 'アイデアを破棄';

  @override
  String get ideaDetail => 'アイデア詳細';

  @override
  String get ideaInfo => 'アイデア情報';

  @override
  String get ideaStatus => '状態';

  @override
  String get ideaCreatedAt => '作成日';

  @override
  String get ideaUpdatedAt => '最終更新';

  @override
  String get ideaSubmittedBy => '提出者';

  @override
  String get ideaReviewedBy => '審査者';

  @override
  String get ideaLikes => 'いいね';

  @override
  String get likeIdea => 'いいね';

  @override
  String get unlikeIdea => 'いいね解除';

  @override
  String get shareIdea => '共有';

  @override
  String get ideaComments => 'コメント';

  @override
  String get addIdeaComment => 'コメントを追加';

  @override
  String get enterIdeaComment => 'コメントを入力...';

  @override
  String get sendIdeaComment => '送信';

  @override
  String get noIdeaComments => 'コメントはありません';

  @override
  String get reviewIdea => '審査';

  @override
  String get approveIdea => 'アイデアを承認';

  @override
  String get rejectIdea => 'アイデアを却下';

  @override
  String get rejectReason => '却下理由';

  @override
  String get enterRejectReason => '却下理由を入力してください...';

  @override
  String get ideaStatusAll => 'すべて';

  @override
  String get ideaStatusDraft => '下書き';

  @override
  String get ideaStatusPending => '審査待ち';

  @override
  String get ideaStatusUnderReview => '審査中';

  @override
  String get ideaStatusApproved => '承認済み';

  @override
  String get ideaStatusRejected => '却下';

  @override
  String get ideaStatusImplementing => '実施中';

  @override
  String get ideaStatusImplemented => '実施済み';

  @override
  String get ideaStatusClosed => 'クローズ';

  @override
  String get ideaCategoryImprovement => '改善';

  @override
  String get ideaCategoryInnovation => '革新';

  @override
  String get ideaCategoryCostSaving => 'コスト削減';

  @override
  String get ideaCategorySafety => '安全';

  @override
  String get ideaCategoryQuality => '品質';

  @override
  String get ideaCategoryProductivity => '生産性';

  @override
  String get ideaCategoryEnvironment => '環境';

  @override
  String get ideaCategoryWorkplace => '職場環境';

  @override
  String get ideaCategoryOther => 'その他';

  @override
  String get camera => 'カメラ';

  @override
  String get scanQRCode => 'QRコードをスキャン';

  @override
  String get scanBarcode => 'バーコードをスキャン';

  @override
  String get flashOn => 'フラッシュオン';

  @override
  String get flashOff => 'フラッシュオフ';

  @override
  String get switchCamera => 'カメラ切替';

  @override
  String get frontCamera => 'フロントカメラ';

  @override
  String get backCamera => 'バックカメラ';

  @override
  String get capturing => '撮影中...';

  @override
  String get captureFailed => '撮影に失敗しました';

  @override
  String get qrCodeDetected => 'QRコードを検出しました';

  @override
  String get barcodeDetected => 'バーコードを検出しました';

  @override
  String get invalidQRCode => '無効なQRコード';

  @override
  String get scanAgain => '再スキャン';

  @override
  String get processingImage => '画像を処理中...';

  @override
  String get zoomIn => '拡大';

  @override
  String get zoomOut => '縮小';

  @override
  String get chat => 'チャット';

  @override
  String get aiAssistant => 'AIアシスタント';

  @override
  String get aiChatTitle => 'SmartFactoryアシスタント';

  @override
  String get chatWithAI => 'AIとチャット';

  @override
  String get typeMessage => 'メッセージを入力...';

  @override
  String get sendMessage => '送信';

  @override
  String get aiThinking => '考え中...';

  @override
  String get aiTyping => 'AIが入力中...';

  @override
  String get noMessages => 'メッセージはありません';

  @override
  String get startConversation => '会話を始める';

  @override
  String get chatHistory => 'チャット履歴';

  @override
  String get clearChat => 'チャットを削除';

  @override
  String get clearChatConfirm => 'すべてのメッセージを削除しますか？';

  @override
  String get chatCleared => 'チャットを削除しました';

  @override
  String get aiWelcomeMessage =>
      'こんにちは！SmartFactoryのAIアシスタントです。何かお手伝いできることはありますか？';

  @override
  String get aiErrorMessage => '申し訳ございません。エラーが発生しました。再度お試しください。';

  @override
  String get aiNoResponseMessage => '応答がありませんでした。再度お試しください。';

  @override
  String get speechToText => '音声入力';

  @override
  String get listeningMessage => '聞いています...';

  @override
  String get stopListening => '停止';

  @override
  String get voiceInputNotAvailable => '音声入力は利用できません';

  @override
  String get copyMessage => 'コピー';

  @override
  String get messageCopied => 'メッセージをコピーしました';

  @override
  String get leaderReportManagement => '報告管理';

  @override
  String get leaderIncidentReport => 'リーダーインシデント報告';

  @override
  String get incidentDetail => 'インシデント詳細';

  @override
  String get senderInfo => '送信者情報';

  @override
  String get confirmAndAddInfo => '確認と情報追加';

  @override
  String get processingInfo => '処理情報';

  @override
  String get detailInfo => '詳細情報';

  @override
  String get componentName => '部品名';

  @override
  String get enterComponentName => '部品名を入力';

  @override
  String get productionLine => '生産ライン';

  @override
  String get enterProductionLine => '生産ライン名を入力';

  @override
  String get workstation => '工程';

  @override
  String get enterWorkstation => '工程を入力';

  @override
  String get detectionDepartment => '発見部門';

  @override
  String get enterDetectionDepartment => '発見部門を入力';

  @override
  String get leaderNotes => 'リーダーメモ';

  @override
  String get enterLeaderNotes => 'リーダーメモを入力...';

  @override
  String get enterLeaderNotesOptional => 'メモを入力（任意）';

  @override
  String get confirmPriority => '優先度を確認';

  @override
  String get locationDevice => '場所 / 設備';

  @override
  String get enterLocationDevice => '場所または設備名を入力';

  @override
  String get pleaseEnterLocation => '場所または設備を入力してください';

  @override
  String get responsibleDepartment => '担当部門';

  @override
  String get completedDate => '完了日';

  @override
  String get image => '画像';

  @override
  String get selectedImages => '選択した画像';

  @override
  String get selectedVideos => '選択した動画';

  @override
  String get recordedAudio => '録音した音声';

  @override
  String get listeningRelease => '聞いています...離すと停止';

  @override
  String get pleaseFillRequiredFields => '必須項目 (*) をすべて入力してください';

  @override
  String get confirmApproval => '承認確認';

  @override
  String get confirmApproveMessage => 'この報告を承認してAdminに送信しますか？';

  @override
  String get approveAndSendToAdmin => '承認して管理者に送信';

  @override
  String get approvedAndSentToAdmin => '承認してAdminに送信しました';

  @override
  String get cannotApproveReport => '報告を承認できません';

  @override
  String get returnToUser => 'ユーザーに返す';

  @override
  String get confirmReturn => '返却確認';

  @override
  String get returnReasonHint => '返却理由（例：写真をもっと明確に）';

  @override
  String get pleaseEnterReturnReason => '返却理由を入力してください';

  @override
  String get returnedToUser => 'ユーザーに返却しました';

  @override
  String get cannotReturnReport => '報告を返却できません';

  @override
  String get acknowledgeReport => '受領マーク';

  @override
  String get acknowledgedReport => '受領マークしました';

  @override
  String get cannotAcknowledgeReport => '受領マークできません';

  @override
  String get sendSolution => '解決策を送信';

  @override
  String get sendSolutionTitle => '解決策を送信';

  @override
  String get enterSolutionHint => '解決策を入力...';

  @override
  String get pleaseEnterSolution => '解決策を入力してください';

  @override
  String get solutionSent => '解決策を送信しました';

  @override
  String get cannotSendSolution => '解決策を送信できません';

  @override
  String get cancelReport => 'キャンセル';

  @override
  String get confirmCancelMessage => 'この報告をキャンセルしますか？この操作は取り消せません。';

  @override
  String get confirmCancelTitle => 'キャンセル確認';

  @override
  String get cancelledByLeader => 'リーダーによりキャンセル';

  @override
  String get reportCancelled => '報告をキャンセルしました';

  @override
  String get cannotCancelReport => '報告をキャンセルできません';

  @override
  String get ratingQuality => '対応品質を評価';

  @override
  String get commentOptional => 'コメント（任意）';

  @override
  String get submitRating => '評価を送信';

  @override
  String get select => '選択';

  @override
  String get pendingReports => '承認待ち報告';

  @override
  String get reviewReport => '報告を審査';

  @override
  String get approveReport => '報告を承認';

  @override
  String get rejectReport => '報告を却下';

  @override
  String get reportApproved => '報告を承認しました';

  @override
  String get reportRejected => '報告を却下しました';

  @override
  String get assignReport => '担当者を割り当て';

  @override
  String get selectAssignee => '担当者を選択';

  @override
  String get assignedSuccessfully => '割り当てました';

  @override
  String get rejectReasonLabel => '却下理由';

  @override
  String get enterRejectReasonPlaceholder => '報告の却下理由を入力してください...';

  @override
  String get reviewNotes => '審査メモ';

  @override
  String get enterReviewNotes => '審査メモを入力してください...';

  @override
  String get updateReportStatus => '状態を更新';

  @override
  String get statusUpdated => '状態を更新しました';

  @override
  String get resolutionDetails => '対応詳細';

  @override
  String get enterResolutionDetails => '対応内容を入力してください...';

  @override
  String get markAsResolved => '解決済みにする';

  @override
  String get reopenReport => '報告を再開';

  @override
  String get closeReport => '報告をクローズ';

  @override
  String get viewStatistics => '統計を見る';

  @override
  String get reportStatistics => '報告統計';

  @override
  String get totalReports => '総報告数';

  @override
  String get pendingCount => '対応待ち';

  @override
  String get processingCount => '対応中';

  @override
  String get completedCount => '完了';

  @override
  String get thisWeekStats => '今週の統計';

  @override
  String get thisMonthStats => '今月の統計';

  @override
  String get voiceInput => '音声入力';

  @override
  String get tapToSpeak => 'タップして話す';

  @override
  String get listening => '聞いています...';

  @override
  String get processing => '処理中...';

  @override
  String get voiceRecognitionError => '音声認識エラー';

  @override
  String get tryAgain => '再度お試しください';

  @override
  String get noSpeechDetected => '音声が検出されませんでした';

  @override
  String get speechRecognitionNotAvailable => '音声認識は利用できません';

  @override
  String get errorGeneral => 'エラーが発生しました。再度お試しください。';

  @override
  String get errorNetwork => 'ネットワークエラー。インターネット接続を確認してください。';

  @override
  String get errorServer => 'サーバーエラー。しばらくしてから再度お試しください。';

  @override
  String get errorTimeout => 'タイムアウトしました。再度お試しください。';

  @override
  String get errorUnauthorized => 'セッションが切れました。再度ログインしてください。';

  @override
  String get errorForbidden => 'この操作を行う権限がありません。';

  @override
  String get errorNotFound => 'データが見つかりませんでした。';

  @override
  String get errorValidation => '入力内容に誤りがあります。確認してください。';

  @override
  String get errorUpload => 'アップロードに失敗しました。再度お試しください。';

  @override
  String get errorDownload => 'ダウンロードに失敗しました。再度お試しください。';

  @override
  String get errorSaveData => 'データの保存に失敗しました。再度お試しください。';

  @override
  String get errorLoadData => 'データの読み込みに失敗しました。再度お試しください。';

  @override
  String get errorEmptyField => 'この項目は必須です';

  @override
  String get errorInvalidFormat => '形式が正しくありません';

  @override
  String get errorFileTooLarge => 'ファイルが大きすぎます。小さいファイルを選択してください。';

  @override
  String get errorUnsupportedFormat => 'サポートされていないファイル形式です。';

  @override
  String get successSaved => '保存しました';

  @override
  String get successDeleted => '削除しました';

  @override
  String get successUpdated => '更新しました';

  @override
  String get successSubmitted => '送信しました';

  @override
  String get successUploaded => 'アップロードしました';

  @override
  String get successDownloaded => 'ダウンロードしました';

  @override
  String get successCopied => 'コピーしました';

  @override
  String get confirmDelete => '削除の確認';

  @override
  String get confirmDeleteMessage => 'この項目を削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get confirmDiscard => '変更を破棄';

  @override
  String get confirmDiscardMessage => '保存されていない変更があります。破棄してもよろしいですか？';

  @override
  String get confirmLogout => 'ログアウトの確認';

  @override
  String get confirmLogoutMessage => 'アプリからログアウトしてもよろしいですか？';

  @override
  String get confirmSubmit => '送信の確認';

  @override
  String get confirmSubmitMessage => '送信してもよろしいですか？送信後は編集できません。';

  @override
  String get searchPlaceholder => '検索...';

  @override
  String get commentPlaceholder => 'コメントを書く...';

  @override
  String get notePlaceholder => 'メモを入力...';

  @override
  String get descriptionPlaceholder => '説明を入力...';

  @override
  String get titlePlaceholder => 'タイトルを入力...';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int count) {
    return '$count分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String daysAgo(int count) {
    return '$count日前';
  }

  @override
  String weeksAgo(int count) {
    return '$count週間前';
  }

  @override
  String monthsAgo(int count) {
    return '$countヶ月前';
  }

  @override
  String get ideaContentTitle => '意見 / 提案内容';

  @override
  String get ideaContentHint => '意見または提案内容を入力してください...';

  @override
  String get imageAddedSuccess => '画像を追加しました';

  @override
  String get permissionDeniedTitle => 'アクセス許可が拒否されました';

  @override
  String permissionDeniedMessage(String permissionType) {
    return 'この機能を使用するには$permissionTypeへのアクセス許可が必要です。設定で許可してください。';
  }

  @override
  String get openSettings => '設定を開く';

  @override
  String imageLabel(int index) {
    return '画像 $index';
  }

  @override
  String get processingBy => '対応者';

  @override
  String get tabProcessing => '対応中';

  @override
  String get tabCompleted => '完了';

  @override
  String get confirmAdditionalInfo => '確認と情報追加';

  @override
  String get issueClassification => '問題分類';

  @override
  String get workstationLabel => '工程';

  @override
  String get detectionDepartmentLabel => '発見部門';

  @override
  String get statusPendingApproval => '承認待ち';

  @override
  String get statusInProcessing => '処理中';

  @override
  String get statusDone => '完了';

  @override
  String get statusClosedLabel => 'クローズ';

  @override
  String get handleIncident => '対応する';

  @override
  String get leaderCanAssignAndUpdate => 'タスクを割り当てたり、ステータスを更新したりできます';

  @override
  String get userCanOnlyViewProgress => '詳細と進捗のみ確認できます';

  @override
  String get suggestionMailbox => '意見箱';

  @override
  String get contentUnderDevelopment => 'コンテンツは開発中です';

  @override
  String get issueType => '問題の種類';

  @override
  String get tabNew => '新規';

  @override
  String get unknownSender => '送信者不明';

  @override
  String get attachedDocuments => '添付資料';

  @override
  String escalatedTo(String escalatedTo) {
    return '$escalatedToに転送';
  }

  @override
  String get componentMotor => 'モーター';

  @override
  String get componentConveyor => 'コンベア';

  @override
  String get componentSensor => 'センサー';

  @override
  String get componentControlValve => '制御弁';

  @override
  String get productionLineA => '製造ラインA';

  @override
  String get productionLineB => '製造ラインB';

  @override
  String get productionLineC => '製造ラインC';

  @override
  String get workstationCasting => '鋳造';

  @override
  String get workstationStamping => 'プレス';

  @override
  String get workstationAssembly => '組立';

  @override
  String get workstationInspection => '検査';

  @override
  String get checkedAndConfirmed => '確認済み';

  @override
  String get categoryAdministrative => '管理';

  @override
  String get departmentQC => '品質管理';

  @override
  String get departmentProduction => '生産';

  @override
  String get departmentMaintenance => '保守';

  @override
  String get departmentSafety => '安全';

  @override
  String get whiteBoxTab => 'ホワイトボックス';

  @override
  String get pinkBoxTab => 'ピンクボックス';

  @override
  String get whiteBox => 'ホワイトボックス';

  @override
  String get publicVisibility => '誰でも見られる';

  @override
  String get pinkBox => 'ピンクボックス';

  @override
  String get privateVisibility => '自分だけが見られる';

  @override
  String get anonymousInfoMessage => '完全匿名で送信する場合はスキップできます';

  @override
  String get employeeIdExample => '例: NV001';

  @override
  String get submissionDate => '送信日 *';

  @override
  String get tapToEnterIdeaContent => 'クリックして意見や提案内容を入力...';

  @override
  String get ideaContentMinLength => '提案内容は最低10文字必要です';

  @override
  String get difficultyLevelOptional => '難易度（任意）';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get personalInfoAnonymousNote => '個人情報は任意です。空欄にすると、提案は完全に匿名になります。';

  @override
  String get photoLibrary => 'フォトライブラリ';

  @override
  String get errorSelectingImage => '画像選択エラー';

  @override
  String get aiGreetingMessage => 'こんにちは！どのようなご用件でしょうか？';

  @override
  String get errorSendingMessage => 'メッセージ送信エラー';
}
