# Add any project specific ProGuard rules here

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.maps.android.** { *; }

# Compose
-keep class androidx.compose.runtime.** { *; }
