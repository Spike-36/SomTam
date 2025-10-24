import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing props from android/key.properties (keystore settings)
val keystoreProperties = Properties()
val propsFile = rootProject.file("key.properties")
if (propsFile.exists()) {
    keystoreProperties.load(FileInputStream(propsFile))
}

android {
    namespace = "com.petermilligan.somtam"

    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        applicationId = "com.petermilligan.somtam"
        minSdk = flutter.minSdkVersion
        targetSdk = 36

        // 👉 Bumped versionCode for Play Console upload
        versionCode = 3
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
                ?: error("storeFile missing in key.properties")
            val storePass = keystoreProperties["storePassword"] as String?
                ?: error("storePassword missing in key.properties")
            val alias = keystoreProperties["keyAlias"] as String?
                ?: error("keyAlias missing in key.properties")
            val keyPass = keystoreProperties["keyPassword"] as String?
                ?: error("keyPassword missing in key.properties")

            storeFile = File(rootDir, storeFilePath)
            storePassword = storePass
            keyAlias = alias
            keyPassword = keyPass
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        // debug uses default debug signing
    }
}

flutter {
    source = "../.."
}
