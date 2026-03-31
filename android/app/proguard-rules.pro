# ── Firebase ──────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

# ── Firebase Messaging ────────────────────────────────
-keep class com.google.firebase.messaging.** { *; }

# ── Kotlin ────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# ── Flutter ───────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# ── Local Notifications ───────────────────────────────
-keep class com.dexterous.** { *; }

# ── Remove debug logging in release ───────────────────
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# ── Prevent reverse engineering of sensitive strings ──
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ── Play Core (Ignore missing classes from Flutter Core) ──
-dontwarn com.google.android.play.core.**
