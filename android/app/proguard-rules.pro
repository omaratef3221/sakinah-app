# Firebase / Google Sign-In: keep classes referenced via reflection.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Drift / SQLite (sqlite3_flutter_libs uses native lookups).
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
