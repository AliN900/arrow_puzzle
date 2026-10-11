# ============================================================
# Huawei HMS Core / AGConnect Keep Rules (Official)
# ============================================================

-ignorewarnings

-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

-keep class com.huawei.hms.**{*;}
-keep class com.huawei.hianalytics.**{*;}
-keep class com.huawei.updatesdk.**{*;}
-keep class com.huawei.agconnect.**{*;}

-keep class com.huawei.android.hms.**{*;}
-keep class com.hianalytics.android.**{*;}
-keep class com.huawei.libcore.**{*;}

-keep class org.bouncycastle.**{*;}
-dontwarn org.bouncycastle.**

-keep class com.huawei.hms.iapfull.**{*;}
-keep interface com.huawei.hms.iapfull.**{*;}
-keep enum com.huawei.hms.iapfull.**{*;}

-dontwarn com.huawei.**
-dontwarn com.hianalytics.**