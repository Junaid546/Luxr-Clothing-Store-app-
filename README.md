# StyleCart - AI-Powered Clothing eCommerce

A production-level Flutter eCommerce application built with Clean Architecture, Riverpod for state management, and Firebase backend services.

## Project Overview

**App Name:** StyleCart  
**Type:** AI-Powered Clothing eCommerce  
**Architecture:** Clean Architecture (Domain / Data / Presentation)  
**State Management:** Riverpod (flutter_riverpod + riverpod_annotation)  
**Navigation:** GoRouter  
**DI:** Riverpod providers  
**Platform:** Android + iOS

## Features

- User Authentication (Firebase Auth)
- Product Catalog with Categories
- Shopping Cart
- Wishlist
- Order Management
- Checkout Flow
- User Profile
- Admin Dashboard (Dashboard, Products, Orders, Analytics)
- Push Notifications (Firebase Messaging)
- Analytics (Firebase Analytics)

## Setup Instructions

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Firebase Project (Web, Android, iOS)
- Node.js (for Firebase CLI - optional)

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd luxr_clothing
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Environment Variables

1. Copy the `.env` file template
2. Replace placeholder values with your Firebase configuration:

```env
FIREBASE_WEB_API_KEY=your_web_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
LOW_STOCK_THRESHOLD=5
FREE_SHIPPING_THRESHOLD=100
EXPRESS_SHIPPING_COST=25
```

### Step 4: Firebase Configuration

#### Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`

#### iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/`

### Step 5: Run the App

```bash
flutter run
```

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────────┐│
│  │  Screens │ │  Widgets │ │ Providers│ │   GoRouter (Nav)     ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────────┐│
│  │ Entities │ │UseCases  │ │Repos(Ab)│ │   Failure (dartz)    ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────────┐│
│  │  Models  │ │Repos(Impl)│ │DataSources│ │  Firebase Services  ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Folder Structure

```
lib/
├── main.dart                          # App entry point
├── app/                               # App-level configurations
│   ├── app.dart                      # MaterialApp.router root
│   ├── router/                        # GoRouter configuration
│   │   ├── app_router.dart           # Route definitions
│   │   └── route_names.dart           # Named routes constants
│   └── theme/                        # Theme configuration
│       ├── app_theme.dart            # Light/Dark themes
│       ├── app_colors.dart           # Color tokens
│       ├── app_text_styles.dart      # Typography
│       └── app_dimensions.dart       # Spacing/Radius
│
├── core/                              # Shared utilities
│   ├── constants/                    # App constants
│   │   ├── app_constants.dart
│   │   ├── firestore_constants.dart
│   │   └── storage_constants.dart
│   ├── errors/                       # Error handling
│   │   ├── failures.dart             # Failure sealed class
│   │   └── exceptions.dart           # Custom exceptions
│   ├── usecases/                     # UseCase base class
│   ├── utils/                        # Utilities
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart
│   └── providers/                    # Firebase providers
│
├── features/                         # Feature modules
│   ├── auth/                        # Authentication
│   ├── home/                       # Home screen
│   ├── products/                   # Product catalog
│   ├── cart/                      # Shopping cart
│   ├── orders/                    # Order management
│   ├── wishlist/                  # Wishlist
│   ├── profile/                   # User profile
│   ├── checkout/                  # Checkout flow
│   └── admin/                     # Admin features
│       ├── dashboard/
│       ├── products/
│       ├── orders/
│       └── analytics/
│
└── shared/                         # Shared widgets/models
    ├── widgets/
    │   ├── buttons/
    │   ├── cards/
    │   ├── inputs/
    │   └── loaders/
    └── models/
```

## Tech Stack

### Dependencies
- **State Management:** flutter_riverpod, riverpod_annotation
- **Navigation:** go_router
- **Firebase:** firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging, firebase_analytics
- **Utilities:** flutter_dotenv, equatable, dartz, freezed_annotation, json_annotation, uuid, intl
- **Storage:** shared_preferences, flutter_secure_storage
- **UI:** cached_network_image, flutter_svg, shimmer, gap, image_picker

### Dev Dependencies
- build_runner
- riverpod_generator
- freezed
- json_serializable
- flutter_lints
- very_good_analysis

## License

This project is licensed under the MIT License.
