# Luxr App Launch Checklist

## 🔥 Firebase Setup
- [ ] Firebase project created (production)
- [ ] Authentication enabled (Email + Google)
- [ ] Email enumeration protection: ON
- [ ] Firestore database created (production mode)
- [ ] Firestore rules deployed: firebase deploy --only firestore:rules
- [ ] Firestore indexes deployed: firebase deploy --only firestore:indexes
- [ ] Firebase Storage enabled
- [ ] Storage rules deployed: firebase deploy --only storage
- [ ] FCM enabled (Cloud Messaging)
- [ ] Firebase App Check enabled
- [ ] Firebase Analytics enabled
- [ ] Firebase Crashlytics enabled
- [ ] Budget alert configured in Google Cloud Console

## 📱 Android Checklist
- [ ] Package name set: com.yourcompany.luxr
- [ ] App version: 1.0.0+1
- [ ] minSdkVersion: 21 (Android 5.0)
- [ ] targetSdkVersion: 34
- [ ] Release keystore generated
- [ ] Keystore backed up (2 secure locations)
- [ ] key.properties configured
- [ ] google-services.json added (production Firebase)
- [ ] ProGuard rules verified (app works after minify)
- [ ] Release APK tested on physical device
- [ ] Network security config: cleartext disabled
- [ ] All permissions declared in AndroidManifest.xml
- [ ] App icon set (all densities: mdpi to xxxhdpi)
- [ ] Notification icon set (@drawable/ic_notification)
- [ ] FCM default channel configured
- [ ] Deep links configured and tested
- [ ] Push notifications tested (foreground + background)
- [ ] App Bundle (.aab) generated and signed

## 🍎 iOS Checklist
- [ ] Bundle ID set: com.yourcompany.luxr
- [ ] Minimum iOS: 13.0
- [ ] Signing certificate: Distribution
- [ ] Provisioning profile: App Store
- [ ] GoogleService-Info.plist added (production)
- [ ] App icon set (all required sizes)
- [ ] Launch screen configured
- [ ] Push notification capability enabled
- [ ] Info.plist permissions: camera, photos, notifications
- [ ] TestFlight build uploaded and tested
- [ ] App Store Connect record created

## 🔐 Security Checklist
- [ ] .env NOT in git history
- [ ] google-services.json NOT in git
- [ ] key.properties NOT in git
- [ ] Git log scanned: git log --all --full-history -- "*.env"
- [ ] Firestore rules tested in Firebase Emulator
- [ ] All validators implemented
- [ ] Rate limiting active on auth operations
- [ ] Error messages don't leak internals
- [ ] Crashlytics collecting in release mode
- [ ] Admin role cannot be self-assigned

## 📊 Data & Content
- [ ] Admin account created in Firebase Auth
- [ ] Admin role set in Firestore: /users/{uid}.role = "admin"
- [ ] At least 10 products seeded with real images
- [ ] Product categories created: /categories
- [ ] Home banners created: /banners (at least 2)
- [ ] All product images uploaded to Firebase Storage
- [ ] Pricing correct (not test prices like $0.01)
- [ ] Inventory set correctly per product size

## 🧪 Testing
- [ ] flutter analyze = 0 errors
- [ ] All unit tests passing
- [ ] All widget tests passing
- [ ] Manual testing: signup → browse → cart → checkout
- [ ] Manual testing: order tracking (all 5 statuses)
- [ ] Manual testing: admin panel all sections
- [ ] Manual testing: notifications (all 3 app states)
- [ ] Manual testing: offline mode (no crash)
- [ ] Manual testing: Google Sign-In flow
- [ ] Manual testing: password reset email received
- [ ] Tested on Android: old (API 21) + new (API 33)
- [ ] Tested on iOS: iPhone SE + iPhone 14 Pro

## 🚀 Play Store
- [ ] Google Play Developer account ($25 one-time fee)
- [ ] App created in Play Console
- [ ] Content rating questionnaire completed
- [ ] Privacy policy URL added
- [ ] Store listing complete (description, screenshots)
- [ ] Feature graphic uploaded (1024x500)
- [ ] App icon uploaded (512x512)
- [ ] Internal testing track: APK uploaded and tested
- [ ] Production release: App Bundle (.aab) uploaded
- [ ] Countries selected for distribution
- [ ] Pricing: Free
- [ ] Review submitted

## 🍎 App Store
- [ ] Apple Developer Program ($99/year)
- [ ] App Store Connect record created
- [ ] App ID registered with bundle ID
- [ ] Distribution certificate active
- [ ] App Store provisioning profile created
- [ ] TestFlight: internal testers approved
- [ ] Store listing complete
- [ ] Screenshots for all required device sizes
- [ ] App Review information filled (demo account)
- [ ] Age rating: 4+
- [ ] Privacy policy URL added
- [ ] Submitted for App Review

## 🔗 GitHub Repository
- [ ] https://github.com/Junaid546/Luxr-Clothing-Store-app-
- [ ] main branch: production code
- [ ] develop branch: created
- [ ] v1.0.0 tag: created
- [ ] README.md: complete with setup instructions
- [ ] .env.example: committed (no real values)
- [ ] SECURITY_CHECKLIST.md: committed
- [ ] LAUNCH_CHECKLIST.md: committed (this file)
- [ ] CI workflow: passing on main
- [ ] Release workflow: tested with v1.0.0-rc1 tag
- [ ] Branch protection: enabled on main
- [ ] GitHub Secrets: all configured

## 📈 Post-Launch
- [ ] Firebase Analytics: verify events flowing
- [ ] Crashlytics: verify no crashes in first 24h
- [ ] Performance: verify < 3s cold start
- [ ] Test a real order end-to-end
- [ ] Monitor Firestore read/write counts
- [ ] Set up Firebase alerts (error rate, crashes)
- [ ] Portfolio updated: junaidtahirdev.space
- [ ] LinkedIn post about launch
- [ ] GitHub repo star-ready for clients
