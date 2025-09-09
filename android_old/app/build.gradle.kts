plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.braw3"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.braw3"   // ⚡ change to your own package before Play upload
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // 🔑 You must bump these for each Play release
        versionCode = 2
        versionName = "1.0.1"
    }

    signingConfigs {
        release {
            if (project.hasProperty("keyProperties")) {
                storeFile file(keyProperties["storeFile"])
                storePassword keyProperties["storePassword"]
                keyAlias keyProperties["keyAlias"]
                keyPassword keyProperties["keyPassword"]
            }
        }
    }

    buildTypes {
        release {
            // Use the release signing config we just defined
            signingConfig = signingConfigs.release
            // Optional: enable shrinker/proguard later
            // minifyEnabled true
            // shrinkResources true
        }
    }
}

flutter {
    source = "../.."
}
