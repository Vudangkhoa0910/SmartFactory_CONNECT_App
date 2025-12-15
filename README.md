# SmartFactory CONNECT

Mobile application for DENSO factory management and production monitoring system.

## Project Overview

SmartFactory CONNECT is a comprehensive Flutter-based mobile application designed for factory workers and management to streamline operations, report incidents, submit ideas, and monitor production processes in real-time.

### Key Features

- Multi-language support (Vietnamese/Japanese)
- Incident reporting with media attachments
- Leader report management and approval workflow
- Idea box system (White Box/Pink Box)
- Real-time AI chat assistance
- Biometric authentication
- Push notifications via Firebase Cloud Messaging
- Camera integration for QR scanning and photo capture
- Production monitoring and analytics

## Technology Stack

- Flutter 3.9.2
- Dart 3.9.2
- Firebase (Authentication, Cloud Messaging, Analytics)
- Local Backend API integration
- State Management: Provider pattern
- Internationalization: flutter_localizations, intl

## Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)
- Git

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Vudangkhoa0910/SmartFactory_CONNECT_App.git
cd SmartFactory_CONNECT_App
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

4. Generate localization files:
```bash
flutter gen-l10n
```

5. Run the application:
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android
```

## Project Structure

```
lib/
├── components/          # Reusable UI components
├── config/             # App configuration and constants
├── l10n/               # Localization files (ARB)
├── models/             # Data models
├── pages/              # Screen layouts
├── providers/          # State management providers
├── screens/            # Application screens
│   ├── auth/          # Authentication screens
│   ├── camera/        # Camera and QR scanner
│   ├── home/          # Home and news screens
│   ├── idea_box/      # Idea submission screens
│   ├── profile/       # User profile screens
│   └── report/        # Incident reporting screens
├── services/          # API services and utilities
├── utils/             # Helper functions and utilities
├── widgets/           # Custom widgets
└── main.dart          # Application entry point
```

## Branch Strategy

The project follows a structured branching strategy:

- `main` - Production-ready code
- `develop` - Development integration branch
- `khoadev` - Khoa's development branch
- `namdev` - Nam's development branch
- `tuandev` - Tuan's development branch
- `toandev` - Toan's development branch

### Workflow

1. Create feature branches from `develop`
2. Submit pull requests to `develop` for review
3. Merge `develop` to `main` for releases

## Configuration

### Environment Variables

Configure the following in your local environment:

- Backend API base URL in `lib/config/api_config.dart`
- Firebase project configuration files
- Google Maps API key (if applicable)

### Localization

The app supports Vietnamese and Japanese languages. Translation keys are defined in:

- `lib/l10n/app_vi.arb` - Vietnamese
- `lib/l10n/app_ja.arb` - Japanese

To add new translations:
1. Add keys to both ARB files
2. Run `flutter gen-l10n`
3. Use `AppLocalizations.of(context)!.keyName` in code

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ipa --release
```

Build output:
- Android: `build/app/outputs/`
- iOS: `build/ios/archive/`

## Testing

Run unit and widget tests:

```bash
flutter test
```

Run integration tests:

```bash
flutter test integration_test/
```

## Code Quality

The project enforces code quality through:

- `analysis_options.yaml` - Dart analyzer configuration
- Consistent code formatting
- Component documentation
- Type safety

Format code:
```bash
flutter format .
```

Analyze code:
```bash
flutter analyze
```

## Documentation

Additional documentation can be found in the `docs/` directory:

- `I18N_GUIDE.md` - Internationalization implementation guide
- `LANGUAGE_TOGGLE_INTEGRATION.md` - Language toggle widget usage
- `FLOATING_LANGUAGE_SWITCHER.md` - Floating language switcher guide

## Troubleshooting

### Common Issues

**Issue: Pod install fails on iOS**
```bash
cd ios
pod deintegrate
pod install
```

**Issue: Build fails after updating dependencies**
```bash
flutter clean
flutter pub get
cd ios && pod install
```

**Issue: Localization not working**
```bash
flutter gen-l10n
flutter clean
flutter run
```

## Contributing

1. Create a feature branch from `develop`
2. Make your changes following the project structure
3. Test thoroughly on both iOS and Android
4. Submit a pull request with clear description
5. Ensure all checks pass before merging

## Version History

- v1.0.0 - Initial release with core features
  - User authentication
  - Incident reporting
  - Idea box system
  - Multi-language support

## License

This project is proprietary software developed for DENSO Vietnam.

## Contact

For questions or support, contact the development team:
- Repository: https://github.com/Vudangkhoa0910/SmartFactory_CONNECT_App
- Developer: Vu Dang Khoa

## Acknowledgments

- DENSO Vietnam for project requirements and support
- Flutter team for the amazing framework
- Firebase for backend services
