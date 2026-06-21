import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase / Google Services — reads android/app/google-services.json.
    id("com.google.gms.google-services")
}

// Release signing config, loaded from android/key.properties (gitignored). See
// key.properties.example. When the file is absent (e.g. local dev or CI without the keystore),
// the release build falls back to the debug key so `flutter run --release` still works.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.ragro.ragro_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (uses java.time APIs).
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ragro.ragro_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Google Maps native SDK key. Read from local.properties (dev) or the MAPS_API_KEY
        // environment variable (CI / prod build). An empty key renders blank maps, so the prod
        // build must provide it (see scripts/build_apk_prod.sh).
        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { localProperties.load(it) }
        }
        val mapsApiKey =
            localProperties.getProperty("MAPS_API_KEY")
                ?: System.getenv("MAPS_API_KEY")
                ?: ""
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasReleaseKeystore) {
                    signingConfigs.getByName("release")
                } else {
                    // No release keystore present: fall back to debug so `flutter run --release`
                    // works locally. A publishable APK/AAB requires android/key.properties.
                    logger.warn(
                        "WARNING: no android/key.properties found — release build is signed with " +
                            "the DEBUG key. Do not publish this artifact."
                    )
                    signingConfigs.getByName("debug")
                }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Backports java.time etc. for flutter_local_notifications on older Android.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
