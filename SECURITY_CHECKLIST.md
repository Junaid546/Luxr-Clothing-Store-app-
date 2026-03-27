# StyleCart Security Checklist

## ✅ Firestore Security Rules
- [ ] All collections have explicit read/write rules
- [ ] Catch-all DENY rule at bottom of rules file
- [ ] Role check reads from Firestore (not custom claims)
- [ ] Customer CANNOT change their role field
- [ ] Customer CANNOT read other users' data
- [ ] Customer CANNOT read /analytics collection
- [ ] Customer CANNOT delete orders
- [ ] Order status update validated (only cancel allowed)
- [ ] Cart quantity bounded (1-10 enforced in rules)
- [ ] Review: 1 per user per product (reviewId = userId)
- [ ] Products: only admins can write
- [ ] viewCount: only increment allowed by customers
- [ ] Rules deployed and tested with emulator

## ✅ Firebase Storage Rules
- [ ] Product images: admin write only
- [ ] User photos: owner write, size limit enforced
- [ ] Catch-all DENY at bottom
- [ ] Max file size enforced (5MB for images)
- [ ] File extension validation in rules

## ✅ Secret Management
- [ ] .env file is in .gitignore
- [ ] google-services.json in .gitignore
- [ ] GoogleService-Info.plist in .gitignore
- [ ] *.jks and *.keystore in .gitignore
- [ ] No API keys in any Dart file
- [ ] No API keys in any Kotlin/Swift file
- [ ] AppConfig.validateEnvironment() in main()
- [ ] Git history scanned for accidental commits
      (use: git log --all --full-history -- "*.env")

## ✅ Input Validation
- [ ] All form fields validated before Firestore write
- [ ] Email: format + disposable domain check
- [ ] Password: length + complexity enforced
- [ ] Product name: length + char validation
- [ ] Price: positive, 2 decimal, max value check
- [ ] All user text sanitized before storage
- [ ] Search query sanitized
- [ ] Tags array sanitized and limited to 20

## ✅ Rate Limiting
- [ ] Login: max 5 attempts per minute
- [ ] Registration: max 3 per 10 minutes
- [ ] Password reset: max 3 per hour
- [ ] Add to cart: max 10 per minute
- [ ] Order placement: max 3 per 10 minutes
- [ ] Search: debounced 300ms + max 20/minute

## ✅ Error Handling
- [ ] FlutterError.onError configured
- [ ] PlatformDispatcher.onError configured
- [ ] No stack traces shown to users in production
- [ ] No Firestore paths in user-facing errors
- [ ] No email addresses in crash logs
- [ ] FirebaseCrashlytics enabled in release
- [ ] safeFirestoreCall wraps ALL Firestore operations
- [ ] All streams have .handleError() callbacks

## ✅ Data Protection
- [ ] Sensitive fields in SharedPreferences encrypted
- [ ] FCM token cleared on logout
- [ ] User Crashlytics ID cleared on logout
- [ ] PII (email) hashed before logging
- [ ] debugPrint no-op in release builds
- [ ] Address data snapshot in orders (not linked)
- [ ] Payment info never stored in Firestore
- [ ] Cart prices re-validated at checkout

## ✅ Android Production
- [ ] ProGuard/R8 enabled in release build
- [ ] proguard-rules.pro configured correctly
- [ ] Release APK tested (ProGuard can break Firebase)
- [ ] FLAG_SECURE on checkout screen (optional)
- [ ] minSdkVersion >= 21 (API 21 = Android 5.0)
- [ ] Network security config (no cleartext HTTP)
- [ ] google-services.json NOT in version control

## ✅ iOS Production
- [ ] App Transport Security enabled
- [ ] GoogleService-Info.plist NOT in version control
- [ ] Keychain used for sensitive storage
- [ ] Background refresh disabled for sensitive screens

## ✅ Firestore Indexes
- [ ] firestore.indexes.json deployed
- [ ] All composite indexes created in Firebase Console
- [ ] No "requires index" runtime errors
- [ ] Index for: products/category+isActive+createdAt
- [ ] Index for: orders/userId+placedAt
- [ ] Index for: orders/status+placedAt
- [ ] Index for: notifications/userId+isRead+createdAt

## ✅ Firebase Security Settings
- [ ] Firebase Authentication:
      Email/password enabled, phone disabled (if not used)
- [ ] Email enumeration protection ENABLED
      (prevents user existence detection)
- [ ] Authorized domains configured (remove localhost)
- [ ] Google Sign-In: authorized redirect URIs set
- [ ] Firebase App Check enabled (prevents API abuse)
- [ ] Budget alerts configured in Google Cloud

## ✅ Network Security
- [ ] android/app/src/main/res/xml/network_security_config.xml
      (blocks cleartext HTTP traffic)
- [ ] All API calls use HTTPS only
- [ ] Certificate pinning (optional, for high-security)

## ✅ GDPR/Privacy Compliance
- [ ] Privacy policy URL configured
- [ ] Terms of service URL configured
- [ ] User data deletion flow implemented
      (/users/{uid} deletion + Cloud Function cleanup)
- [ ] Cookie/tracking consent handled
- [ ] Data export available for users
