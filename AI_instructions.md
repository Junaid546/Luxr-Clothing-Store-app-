# AI Instruction File – StyleCart (Clothing Store App)

## 🚨 ROLE

You are a **senior full-stack engineer and system architect**.

You are responsible for building a **production-level Flutter + Firebase clothing eCommerce application**.

This is NOT a demo project.
This must be scalable, secure, and follow industry best practices.

---

## 🧠 CORE OBJECTIVE

Build a **fully functional clothing store app** with:

* Customer shopping experience
* Admin dashboard
* Inventory system
* Order management
* Analytics system

Everything must be connected and working correctly.

---

## 🧱 TECH STACK

* Frontend: Flutter (riverpod)
* Backend: Firebase
* Database: Cloud Firestore
* Auth: Firebase Authentication
* Notifications: Firebase Cloud Messaging
* Storage: Firebase Storage
* Environment config: `.env`
* Module articature 

---

## 🔐 SECURITY RULES (STRICT)

* NEVER expose API keys or secrets in code
* ALWAYS use `.env` for sensitive data
* DO NOT hardcode credentials
* Ensure `.env` is added to `.gitignore`
* Follow least-privilege access for Firestore rules
* Validate all user inputs

---

## 👥 ROLE-BASED SYSTEM

Each user must have a role:

```json
{
  "role": "admin" | "customer"
}
```

Routing logic:

* admin → Admin Dashboard
* customer → Shopping App

NEVER allow manual role selection from UI.

---

## 🧩 CORE SYSTEMS TO BUILD

### 1. Authentication System

* Email/password login
* Secure session handling
* Role stored in Firestore
* Auto routing after login

---

### 2. Product System

Each product must include:

```json
{
  "id": "auto",
  "name": "string",
  "price": "number",
  "discount": "number",
  "category": "string",
  "images": ["url"],
  "sizes": {
    "S": 10,
    "M": 5,
    "L": 0
  },
  "createdAt": "timestamp"
}
```

---

### 3. Inventory Logic (CRITICAL)

* Inventory MUST be updated in backend
* Use atomic transactions when updating stock
* Prevent overselling
* If stock = 0 → disable purchase

---

### 4. Cart System

* Store cart per user
* Support quantity updates
* Real-time total calculation

---

### 5. Order System

```json
{
  "orderId": "auto",
  "userId": "ref",
  "items": [],
  "totalPrice": "number",
  "status": "pending | processing | shipped | delivered",
  "createdAt": "timestamp"
}
```

Rules:

* Reduce inventory AFTER order confirmation
* Prevent duplicate orders
* Track status updates

---

### 6. Admin Panel

Admin must be able to:

* Add/edit/delete products
* Manage inventory
* View orders
* Update order status
* View analytics

---

### 7. Analytics System

Must calculate:

* Total sales
* Daily revenue
* Best-selling products

All calculations must be accurate.

---

### 8. Notifications System

Use FCM for:

* Order updates
* Promotions
* Alerts

---

## 🔄 DATA FLOW PRINCIPLES

* Frontend NEVER directly controls data integrity
* Backend (Firestore + rules) is the source of truth
* Use streams for real-time updates
* Always validate before write operations

---

## 📁 ARCHITECTURE RULES

Follow clean architecture:

lib/
├── main.dart
├── app/
│   ├── app.dart                        # MaterialApp.router root
│   ├── router/
│   │   ├── app_router.dart             # GoRouter config
│   │   └── route_names.dart            # All named routes as constants
│   └── theme/
│       ├── app_theme.dart              # ThemeData dark + light
│       ├── app_colors.dart             # All color tokens
│       ├── app_text_styles.dart        # All text styles
│       └── app_dimensions.dart         # Spacing / radius constants
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # App-wide constants
│   │   ├── firestore_constants.dart    # Collection name strings
│   │   └── storage_constants.dart     # SharedPrefs key strings
│   ├── errors/
│   │   ├── failures.dart              # Failure sealed class
│   │   └── exceptions.dart            # Custom exception types
│   ├── usecases/
│   │   └── usecase.dart               # Abstract UseCase<T, Params>
│   ├── utils/
│   │   ├── validators.dart            # Form validators
│   │   ├── formatters.dart            # Price / date formatters
│   │   └── extensions.dart            # Dart extensions
│   └── providers/
│       └── firebase_providers.dart    # FirebaseAuth, Firestore instances
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── home/
│   │   └── [same data/domain/presentation structure]
│   ├── products/
│   │   └── [same structure]
│   ├── cart/
│   │   └── [same structure]
│   ├── orders/
│   │   └── [same structure]
│   ├── wishlist/
│   │   └── [same structure]
│   ├── profile/
│   │   └── [same structure]
│   ├── checkout/
│   │   └── [same structure]
│   └── admin/
│       ├── dashboard/
│       │   └── [same structure]
│       ├── products/
│       │   └── [same structure]
│       ├── orders/
│       │   └── [same structure]
│       └── analytics/
│           └── [same structure]
│
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── inputs/
│   │   └── loaders/
│   └── models/
│       └── pagination_model.dart

assets/
├── images/
├── icons/
├── fonts/
└── lottie/
---

## ⚙️ CODING STANDARDS

* Write modular, reusable code
* Avoid large monolithic files
* Use proper naming conventions
* Handle errors gracefully
* Add loading and empty states

---

## ❗ EDGE CASES TO HANDLE

* Out of stock during checkout
* Network failure
* Duplicate orders
* Invalid user role
* Deleted product still in cart

---

## 🚀 PERFORMANCE RULES

* Use pagination for product lists
* Optimize Firestore queries
* Cache frequently used data
* Lazy load images

---

## 🧪 TESTING EXPECTATIONS

* Test authentication flow
* Test inventory updates
* Test order placement
* Test admin actions

---

## 🛑 WHAT NOT TO DO

* Do NOT generate fake/mock logic
* Do NOT skip backend validation
* Do NOT expose sensitive data
* Do NOT simplify architecture

---

## ✅ FINAL EXPECTATION

The final app must:

* Work end-to-end
* Be production-ready
* Be secure
* Be scalable
* Follow real-world architecture

---

If any requirement is unclear, make a professional assumption and proceed.
