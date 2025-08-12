# MajorE's Flutter MVVM Template

## 1. Template Overview

This is a comprehensive Flutter template that implements the Model-View-ViewModel (MVVM) architecture pattern with a **feature-first folder structure**. The template provides a solid foundation for building scalable Flutter applications with clean architecture principles, dependency injection, comprehensive error handling, and a robust UI component library.

Key features of this template include:
- **Clean Architecture**: Clear separation between data, domain, and presentation layers
- **Dependency Injection**: Uses GetIt for service locator pattern
- **Error Handling**: Comprehensive error handling with custom failure types
- **UI Components**: Reusable, themed UI components with analytics integration
- **Environment Support**: Multi-environment configuration (staging/production)
- **Analytics Integration**: Built-in analytics and error logging services
- **Internationalization**: Complete i18n setup with ARB files

## 2. Template Characteristics

| Aspect | Implementation | Details |
|--------|---------------|---------|
| **Architecture** | MVVM (Model-View-ViewModel) | Clean separation with AppViewModel base class |
| **Folder Structure** | Feature-First | Each feature has data/domain/ui subdirectories |
| **Service Locator** | GetIt | Dependency injection with lazy singletons |
| **State Management** | Provider + ChangeNotifier | AppView wrapper for MVVM pattern |
| **Network Layer** | Dio | REST API service with interceptors |
| **Error Handling** | Custom Failure Classes | ServerFailure, NetworkFailure, InputFailure, etc. |
| **Analytics** | Firebase Analytics | Built-in event tracking |
| **Local Storage** | Flutter Secure Storage | Encrypted local storage |
| **Theming** | Custom Theme System | AppColors, AppStyles with dark/light support |
| **Navigation** | Named Routes | Declarative navigation with GoRouter |
| **Environment** | Dart Define | Staging/Production configuration |
| **Internationalization** | ARB Files | Multi-language support |
| **Testing** | Not Implemented | No test files found in codebase |
| **Documentation** | Minimal | Limited inline documentation |

## 3. Development Guide

### Getting Started

1. **Project Structure Understanding**:
   - `lib/core/`: Contains shared infrastructure (data, domain, presentation, service_locator)
   - `lib/features/`: Feature-specific code organized by feature name
   - `lib/services/`: Cross-cutting concerns (network, analytics, storage)
   - `lib/utilities/`: Helper classes, extensions, and constants
   - `lib/main/`: Application entry point and configuration
   - `lib/l10n/`: Internationalization files and generated translations

2. **Key Concepts**:
   - **AppViewModel**: Base class for all view models with state management
   - **AppView**: Widget wrapper for MVVM pattern with Provider
   - **AppRepository**: Base class for data layer with error handling
   - **ServiceLocator**: Dependency injection using GetIt

3. **Adding New Features**:
   ```dart
   // 1. Create feature directory: lib/features/your_feature/
   // 2. Add data layer: data/your_feature_repo.dart
   // 3. Add domain layer: domain/your_feature_vm.dart
   // 4. Add UI layer: ui/your_feature_view.dart
   // 5. Register in service_locator/feature_dependencies.dart
   ```

4. **Environment Configuration**:
   - This template is configured for two environments - prod and staging. 
   - Use `EnvironmentConfig` for environment-specific values and secrets. 
   - Environment variable files: `lib/main/prod.env`, `lib/main/staging.env`

5. **UI Components**:
   - All components are in `lib/core/presentation/ui_components/`
   - Use `AppColors.of(context)` and `AppStyles.of(context)` for theming, or the equivalent from the context extension `context.colors` and `context.styles`. 
   - Components include buttons, inputs, loaders, overlays, and others

6. **Navigation**:
   - Uses flutter's declarative navigation (2.0) system. 
   - Define routes in `lib/core/presentation/navigation/app_routes.dart`
   - Then declare them in `lib/core/presentation/navigation/app_router.dart`, which holds the `GoRouter` configuration. 
   - Use `AppNavigator` for programmatic navigation
   - Routes support parameters and deep linking

7. **Internationalization**:
   - ARB files in `lib/l10n/arbs/` for each supported language
   - Use `context.translations.keyName` to access translated strings
   - Run `flutter gen-l10n` to generate translation files

### Development Workflow

1. **Service Registration**: Add new services to `service_dependencies.dart`
2. **Feature Development**: Follow the data → domain → UI pattern
3. **Error Handling**: Use the provided failure classes and error handling methods
4. **Analytics**: Use `AnalyticsService.instance.logEvent()` for tracking
5. **Testing**: Add tests in the `test/` directory (not yet implemented)

### Automation Tools

1. **Code Formatting**:
   - `format-project`: Script for formatting Dart code and organizing dependencies
   - Automatically sorts `pubspec.yaml` dependencies alphabetically
   - Runs `flutter format` with configurable line length from VS Code settings
   - Handles multi-line dependencies properly during sorting
   - Cleans up backup files after successful operations

2. **Firebase Configuration**:
   - `tools/flutterfire-config`: Script for setting up Firebase with CLI
   - Generates Firebase configuration files for different environments
   - Supports staging and production environments with debug/release build configs
   - Creates platform-specific configuration files (google-services.json, GoogleService-Info.plist)
   - Usage: `./tools/flutterfire-config <environment> <build_config>` (e.g., `./tools/flutterfire-config staging debug`)

3. **Internationalization Setup**:
   - Supports multiple languages (English, Swahili, French, Arabic)
   - ARB file format with automatic key generation
   - Build the project or run `flutter gen-l10n`

### Template Customization

1. **Application Name**: Update `pubspec.yaml` and `lib/main/application.dart`
2. **Branding**: Modify `lib/core/presentation/theming/app_colors.dart` and `app_styles.dart`
3. **Features**: Add new features following the established pattern
4. **Languages**: Add new ARB files in `lib/l10n/arbs/` for additional languages
5. **Analytics**: Configure Firebase Analytics in `lib/services/analytics_service/`
6. **Environment**: Update environment configurations in `lib/main/`

### Required Files for New Project

To successfully use this template for a new project, you need to create the following files:

**Environment Configuration:**
- `lib/main/staging.env` - Staging environment variables (JSON format)
- `lib/main/prod.env` - Production environment variables (JSON format)

**Firebase Configuration (generated by flutterfire-config):**
- `lib/main/firebase_options_staging.dart` - Firebase config for staging
- `lib/main/firebase_options_prod.dart` - Firebase config for production
- `android/app/src/staging/google-services.json` - Android Firebase config for staging
- `android/app/src/prod/google-services.json` - Android Firebase config for production
- `ios/flavors/staging/GoogleService-Info.plist` - iOS Firebase config for staging
- `ios/flavors/prod/GoogleService-Info.plist` - iOS Firebase config for production

**Android Signing (for CI/CD):**
- `android/key.properties` - Keystore configuration for app signing
- `android/app/src/staging/app_staging_sign.jks` - Staging keystore file
- `android/app/src/prod/app_prod_sign.jks` - Production keystore file

**iOS Signing (for CI/CD):**
- iOS certificates and provisioning profiles (managed by CI/CD)

**GitHub Secrets (for CI/CD workflows):**

| Secret Name | Description | Used In |
|-------------|-------------|---------|
| `PROD_FIREBASE_APP_ID` \| `STAGING_FIREBASE_APP_ID` | Firebase app ID for uploading builds | Firebase builds |
| `PROD_FIREBASE_PROJECT_ID` \| `STAGING_FIREBASE_PROJECT_ID` | Firebase project identifier for configuration | Firebase builds |
| `PROD_CLOUD_ACCOUNT_JSON` \| `STAGING_CLOUD_ACCOUNT_JSON` | Google cloud service account JSON key for authentication | Firebase and PlayStore uploads |
| `PROD_GOOGLE_SERVICES_JSON` \| `STAGING_GOOGLE_SERVICES_JSON` | Firebase google-services.json | Android builds |
| `PROD_GOOGLE_SERVICES_PLIST` \| `STAGING_GOOGLE_SERVICES_PLIST` | Firebase GoogleService-info.plist | iOS builds |
| `PROD_ENV` \| `STAGING_ENV` | Dart-define environment variables in JSON format (API URLs, app names, etc.) | All builds |
| `PROD_KEYSTORE_BASE64` \| `STAGING_KEYSTORE_BASE64` | Base64 encoded Android keystore file for app signing | Android builds |
| `PROD_KEY_PROPERTIES` \| `STAGING_KEY_PROPERTIES` | Android keystore configuration properties for signing | Android builds |
| `PROD_ANDROID_PACKAGE_NAME` \| `STAGING_ANDROID_PACKAGE_NAME` | Android package name for the respective environment | Store uploads |
| `PROD_APP_STORE_CONNECT_ISSUER_ID` \| `STAGING_APP_STORE_CONNECT_ISSUER_ID` | App Store Connect API issuer ID for iOS releases | iOS store uploads |
| `PROD_APP_STORE_CONNECT_KEY_IDENTIFIER` \| `STAGING_APP_STORE_CONNECT_KEY_IDENTIFIER` | App Store Connect API key identifier for iOS releases | iOS store uploads |
| `PROD_APP_STORE_CONNECT_PRIVATE_KEY` \| `STAGING_APP_STORE_CONNECT_PRIVATE_KEY` | App Store Connect API private key for iOS releases | iOS store uploads |
| `PROD_CERTIFICATE_PRIVATE_KEY` \| `STAGING_CERTIFICATE_PRIVATE_KEY` | iOS certificate private key for code signing | iOS builds |
| `PROD_APP_STORE_APP_ID` \| `STAGING_APP_STORE_APP_ID` | App Store Connect app ID for iOS releases | iOS store uploads |

This template provides a production-ready foundation for building scalable Flutter applications with clean architecture, comprehensive tooling, and automated workflows for code quality.

### Customization Todo List

When cloning this template for a new project, you need to update the following files and references:

**Core Application Files:**
- [ ] `pubspec.yaml` - Update `name` and `description` fields
- [ ] `app.yaml` - Update all properties (app_name, launcher_name, package_name, description, bundle_ids, firebase_project_ids)
- [ ] `lib/main/application.dart` - Update app name and branding
- [ ] `lib/main/staging.env` - Update `APP_NAME` and `API_URL`
- [ ] `lib/main/prod.env` - Update `APP_NAME` and `API_URL`

**Android Configuration:**
- [ ] `android/app/build.gradle.kts` - Update `namespace`, `applicationId`, and `resValue` for app names

**iOS Configuration:**
- [ ] `ios/Runner/Info.plist` - Update `CFBundleDisplayName` and `CFBundleName`
- [ ] `ios/Runner.xcodeproj/project.pbxproj` - Update bundle identifiers and display names

**Firebase Configuration:**
- [ ] `tools/flutterfire-config` - Update Firebase project ID and bundle IDs
- [ ] Regenerate Firebase config files using `./tools/flutterfire-config staging debug` and `./tools/flutterfire-config prod release`

**Generated Files (regenerate after changes):**
- [ ] `lib/main/firebase_options_staging.dart` - Regenerate with new project ID
- [ ] `lib/main/firebase_options_prod.dart` - Regenerate with new project ID
- [ ] `android/app/src/staging/google-services.json` - Regenerate with new project ID
- [ ] `android/app/src/prod/google-services.json` - Regenerate with new project ID
- [ ] `ios/flavors/staging/GoogleService-Info.plist` - Regenerate with new project ID
- [ ] `ios/flavors/prod/GoogleService-Info.plist` - Regenerate with new project ID

**Localization Files:**
- [ ] `lib/l10n/arbs/app_en.arb` - Update `appName` and other app-specific strings
- [ ] `lib/l10n/arbs/app_sw.arb` - Update `appName` and other app-specific strings
- [ ] `lib/l10n/arbs/app_fr.arb` - Update `appName` and other app-specific strings
- [ ] `lib/l10n/arbs/app_ar.arb` - Update `appName` and other app-specific strings
- [ ] Regenerate translations with `flutter gen-l10n`

**GitHub Workflows:**
- [ ] Configure GitHub secrets for CI/CD workflows (see complete list in GitHub Secrets section above)



**Assets:**
- [ ] `assets/images/launcher_icon.png` - Replace with your app icon
- [ ] `assets/images/splash.png` - Replace with your splash screen
- [ ] Update `app.yaml` flutter_launcher_icons and flutter_native_splash configurations

**Documentation:**
- [ ] `README.md` - Update all references to template name and branding

**Environment Setup:**
- [ ] Create new Firebase project
- [ ] Set up Firebase App Distribution for staging and production
- [ ] Create dev-testers group
- [ ] Configure Google Play Console for production releases
- [ ] Set up App Store Connect for iOS releases
- [ ] Generate new keystore files for app signing
- [ ] Configure all GitHub secrets for CI/CD workflows

### GitHub Workflows

This template includes three main CI/CD workflows for automated builds, code quality, and deployments:

#### 1. PR Analysis and Auto-fix (`pr-checks.yaml`)

**Purpose:** Automatically analyzes code quality, applies fixes, and enforces coding standards on pull requests.

**Triggers:**
- Pull requests to `develop` or `main` branches (opened, ready for review, or synchronized)
- Automatically cancels previous runs when new commits are pushed

**Features:**
- Runs `dart fix` to apply automatic code corrections
- Runs code formatting using the `format-project` script
- Performs comprehensive `dart analyze` with issue counting
- Auto-commits fixes and formatting changes back to the PR branch
- Posts detailed analysis results as PR comments
- Blocks PR merging if analysis issues are found
- Excludes TODO comments from analysis failures

**Workflow Permissions:**
- `contents: write` - For committing auto-fixes and formatting changes
- `pull-requests: write` - For posting analysis result comments

#### 2. Android to Firebase App Distribution (`android-to-firebase.yaml`)

**Purpose:** Builds Android APK files and uploads them to Firebase App Distribution for testing.

**Triggers:**
- Pull requests marked as "ready for review" (defaults to staging build)
- Issue comments containing "Build for testing: staging" or "Build for testing: prod"

**Features:**
- Automatic environment detection (staging/production)
- Dynamic version numbering based on PR number and build count
- Firebase App Distribution upload with release notes
- Automatic PR commenting with download links
- Comprehensive caching for faster builds

**Required GitHub Secrets:**
- `STAGING_FIREBASE_APP_ID` / `PROD_FIREBASE_APP_ID` - Firebase app IDs
- `STAGING_CLOUD_ACCOUNT_JSON` / `PROD_CLOUD_ACCOUNT_JSON` - Firebase cloud account JSON for authentication and Firebase App Distribution
- `STAGING_GOOGLE_SERVICES_JSON` / `PROD_GOOGLE_SERVICES_JSON` - Google services configuration for Android
- `STAGING_ENV` / `PROD_ENV` - Environment variables from dart define (JSON format)
- `STAGING_KEYSTORE_BASE64` / `PROD_KEYSTORE_BASE64` - Base64 encoded keystore files
- `STAGING_KEY_PROPERTIES` / `PROD_KEY_PROPERTIES` - Keystore configuration

#### 3. Production App Release (`upload-to-stores.yaml`)

**Purpose:** Builds production-ready AAB (Android) and IPA (iOS) files and uploads them to app stores.

**Triggers:**
- Pull requests to `main` or `prod` branches
- Supports both Android and iOS builds in parallel

**Features:**
- Android: Builds AAB and uploads to Google Play Console (draft status)
- iOS: Builds IPA and uploads to App Store Connect
- Automatic version incrementing
- Comprehensive signing and provisioning profile management
- Parallel builds for both platforms

**Required GitHub Secrets:**
- **Android:** All secrets from Firebase workflow plus `PROD_ANDROID_PACKAGE_NAME`
- **iOS:** App Store Connect credentials and certificates
  - `PROD_APP_STORE_CONNECT_ISSUER_ID`
  - `PROD_APP_STORE_CONNECT_KEY_IDENTIFIER`
  - `PROD_APP_STORE_CONNECT_PRIVATE_KEY`
  - `PROD_CERTIFICATE_PRIVATE_KEY`
  - `PROD_APP_STORE_APP_ID`
  - `PROD_GOOGLE_SERVICES_PLIST`

#### Repository Setup Requirements

**Branch Protection:**
- Enable branch protection on `main` and `prod` branches
- Require pull request reviews before merging
- Require status checks to pass before merging

**Required Apps and Services:**
- Firebase project with App Distribution enabled
- Google Play Console account with API access
- App Store Connect account with API access
- GitHub repository with Actions enabled

**Workflow Permissions:**
- Repository contents: Write (for auto-fixes and commits)
- Pull requests: Write (for PR comments and analysis results)
- ID token: Write (for Firebase authentication)

**Usage Instructions:**
1. Set up all required GitHub secrets in repository settings
2. Create pull requests to `develop` or `main` branches to trigger code analysis and auto-fixes
3. Create pull requests marked as "ready for review" to trigger staging builds
4. Comment "Build for testing: staging" or "Build for testing: prod" for specific builds
5. Merge to main/prod branches to trigger production releases
