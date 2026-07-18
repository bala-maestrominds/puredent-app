# ML Kit barcode scanning
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
-keep class com.google.mlkit.common.** { *; }
-dontwarn com.google.mlkit.**

# CameraX (used internally by mobile_scanner)
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# mobile_scanner plugin itself
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn dev.steenbakker.mobile_scanner.**

# Google Play services / Play Core (referenced by ML Kit internals)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**