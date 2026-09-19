# Keep JSON model classes from being stripped during obfuscation
-keep class com.yourapp.models.** { *; }

# Keep freeRASP internals
-keep class com.aheaditec.** { *; }

# Flutter default rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
