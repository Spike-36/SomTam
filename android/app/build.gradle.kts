plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle plugin must come last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.brawapp2"   // 👈 match your old package
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
        applicationId = "com.brawapp2"   // 👈 match old app id
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Use gradle.properties for secrets
            storeFile = file(project.findProperty("MYAPP_UPLOAD_STORE_FILE") as String)
            storePassword = project.findProperty("MYAPP_UPLOAD_STORE_PASSWORD") as String
            keyAlias = project.findProperty("MYAPP_UPLOAD_KEY_ALIAS") as String
            keyPassword = project.findProperty("MYAPP_UPLOAD_KEY_PASSWORD") as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
