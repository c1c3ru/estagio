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

    kotlin {
        jvmToolchain(17)
    }

    configurations.all {
        resolutionStrategy {
            eachDependency {
                if (it.requested.group == "com.android.tools.build" && it.requested.name == "gradle") {
                    useVersion("7.3.0") // Use a compatible Gradle version
                }
            }
        }
    }

    tasks.withType<JavaCompile> {
        // Configure Java compilation to use release 17 for specific modules
        options.release.set(17)
    }
}

// Also explicitly set the source and target compatibility for these modules if needed
subprojects {
    afterEvaluate { project ->
        if (project.path == ":device_info_plus" || project.path == ":package_info_plus" || project.path == ":shared_preferences_android") {
            project.tasks.withType<JavaCompile> {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.0") // Or the Kotlin version you are using
}

flutter {
    source = "../.."
}
