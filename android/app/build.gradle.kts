plugins {
    // ============================================================
    // ANDROID APPLICATION
    // ============================================================

    id("com.android.application")

    // ============================================================
    // FIREBASE / GOOGLE SERVICES
    // ============================================================

    id("com.google.gms.google-services")

    // ============================================================
    // FLUTTER
    // ============================================================

    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.greenmind_ai"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion

    // ============================================================
    // JAVA / DESUGARING
    // ============================================================

    compileOptions {
        sourceCompatibility =
            JavaVersion.VERSION_17

        targetCompatibility =
            JavaVersion.VERSION_17

        isCoreLibraryDesugaringEnabled = true
    }

    // ============================================================
    // DEFAULT CONFIG
    // ============================================================

    defaultConfig {
        applicationId =
            "com.example.greenmind_ai"

        minSdk =
            flutter.minSdkVersion

        targetSdk =
            flutter.targetSdkVersion

        versionCode =
            flutter.versionCode

        versionName =
            flutter.versionName
    }

    // ============================================================
    // BUILD TYPES
    // ============================================================

    buildTypes {
        release {
            // Debug signing for now.
            // Replace with a proper release keystore later.
            signingConfig =
                signingConfigs.getByName(
                    "debug"
                )
        }
    }

    // ============================================================
    // PACKAGING
    // ============================================================

    packaging {
        resources {
            excludes +=
                "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    // ============================================================
    // LINT
    // ============================================================

    lint {
        checkReleaseBuilds = false
    }
}

// ================================================================
// KOTLIN
// ================================================================

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// ================================================================
// DEPENDENCIES
// ================================================================

dependencies {
    // Required for flutter_local_notifications
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.5"
    )
}

// ================================================================
// FLUTTER
// ================================================================

flutter {
    source = "../.."
}