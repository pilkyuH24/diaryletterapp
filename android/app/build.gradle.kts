// android/app/build.gradle.kts

import java.util.Properties
import java.io.FileInputStream

// 1) key.properties 로드 — 이 코드는 파일 최상단(plugins{} 위)에 있어야 합니다.
val keystorePropsFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropsFile.exists()) {
        load(FileInputStream(keystorePropsFile))
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mellowstudio.diaryletter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    // 2) signingConfigs 정의
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    defaultConfig {
        applicationId = "com.mellowstudio.diaryletter"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        // ① debug 빌드도 release 키로 서명
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
        }

        // ② 기존 release 설정
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isShrinkResources = false
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildTypes {
        getByName("release") {
            // 3) 릴리즈 키스토어로 서명
            signingConfig = signingConfigs.getByName("release")
            // 4) 리소스 축소 끄기 (코드 축소 없이 리소스만 제거하려 하면 오류)
            isShrinkResources = false
            // 5) 코드 난독화 & 축소(선택)
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
