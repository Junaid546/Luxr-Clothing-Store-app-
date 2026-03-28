# Luxr — AI Powered Clothing Store

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A production-level luxury fashion eCommerce mobile app
built with Flutter and Firebase.

## Features

### Customer App
- 🛍️ Browse luxury clothing with advanced filtering
- 🔍 Real-time search with instant results
- ❤️ Wishlist with category filtering
- 🛒 Smart cart with price re-validation
- 💳 Multi-step checkout (address, shipping, payment)
- 📦 Real-time order tracking with timeline
- 👤 Profile with elite status system
- 🔔 Push notifications (FCM)

### Admin Panel
- 📊 Revenue dashboard with live charts
- 📦 Full product CRUD with image upload
- 🗃️ Inventory management per size
- 📋 Order management with status updates
- 📈 Analytics with export (CSV + PDF)
- 🔔 Broadcast notifications

## Tech Stack

| Layer          | Technology               |
|---------------|--------------------------|
| Frontend       | Flutter 3.x + Riverpod   |
| Authentication | Firebase Auth            |
| Database       | Cloud Firestore          |
| Storage        | Firebase Storage         |
| Notifications  | Firebase Cloud Messaging |
| Analytics      | Firebase Analytics       |
| Crash Reports  | Firebase Crashlytics     |

## Architecture

Clean Architecture with Feature-First organization:
lib/
├── app/          # Router, theme, app.dart
├── core/         # Shared utilities, errors, providers
├── features/     # Feature modules (auth, products, etc.)
└── shared/       # Reusable widgets

## Getting Started

### Prerequisites
- Flutter 3.x
- Dart 3.x
- Firebase account
- Android Studio / Xcode

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/Junaid546/Luxr-Clothing-Store-app-.git
cd Luxr-Clothing-Store-app-
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your Firebase credentials
```

4. **Add Firebase config files**
   - Download `google-services.json` from Firebase Console
   - Place in `android/app/google-services.json`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/GoogleService-Info.plist`

5. **Generate code**
```bash
dart run build_runner build --delete-conflicting-outputs
```

6. **Run the app**
```bash
flutter run
```

### Admin Access
To create an admin account:
1. Register normally in the app
2. Go to Firebase Console → Firestore
3. Find your user document in `/users/{uid}`
4. Change `role` field from `customer` to `admin`

## Building for Release

### Android
```bash
./scripts/build_release.sh
```

### iOS
```bash
flutter build ios --release --no-codesign
```

## Environment Variables

See `.env.example` for all required variables.

## Security

See `SECURITY_CHECKLIST.md` for complete security audit.
Firestore security rules in `firestore.rules`.

## License
MIT License — see LICENSE file.

---
Built by [Junaid Tahir](https://junaidtahirdev.space)
