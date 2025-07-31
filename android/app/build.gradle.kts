//build.gradle.kts
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
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    lint {
        disable += "InvalidPackage"
        checkReleaseBuilds = false
    }
}


flutter {
    source = "../.."
}
