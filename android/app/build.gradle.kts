plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Baca local.properties
val localPropertiesFile = rootProject.file("local.properties")
val localProperties = java.util.Properties()
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}

// Konfigurasi Flutter
val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.example.bantoo_fix" // Ubah sesuai dengan package name aplikasi Anda
    compileSdk = 33
    
    ndkVersion = null // PENTING: Hapus ketergantungan pada NDK
    
    defaultConfig {
        applicationId = "com.example.bantoo_fix" // Ubah sesuai dengan package name aplikasi Anda
        minSdk = 21
        targetSdk = 33
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }
}

flutter {
    source = ".."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10")
}