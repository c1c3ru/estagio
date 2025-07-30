plugins {
    id("com.android.application")
    id("kotlin-android")
    // O plugin do Flutter deve ser aplicado por último
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.estagio"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Garante suporte total ao Java 17
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Corrige incompatibilidade de versões JVM
        jvmTarget = "17"
        // Usa versão de linguagem Kotlin compatível
        languageVersion = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.estagio"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Substituir por chave de assinatura própria
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Configurações para evitar erros de lint em plugins
    lint {
        disable += "InvalidPackage"
        checkReleaseBuilds = false
    }
}

kotlin {
    // Força uso do JDK 17 em todos os módulos Kotlin
    jvmToolchain(17)
}

flutter {
    source = "../.."
}
