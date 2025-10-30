plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.io.FileInputStream
import java.util.Properties

val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        load(FileInputStream(localPropertiesFile))
    } else {
        println("local.properties not found at ${localPropertiesFile.absolutePath}")
    }
}

android {
    namespace = "com.example.checkupplus_capstone"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.example.checkupplus_capstone"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val mapsApiKey = localProperties.getProperty("MAPS_API_KEY")

        if (mapsApiKey.isNullOrEmpty()) {
            println("!!! WARNING: MAPS_API_KEY is missing or empty. Maps will not load. !!!")
            manifestPlaceholders["MAPS_API_KEY"] = ""
        } else {
            manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
            buildConfigField("String", "MAPS_API_KEY", "\"$mapsApiKey\"")
            println("!!! SUCCESS: MAPS_API_KEY injected into AndroidManifest. !!!")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
  implementation(platform("com.google.firebase:firebase-bom:34.2.0"))
  implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}


dependencies {
    implementation("androidx.appcompat:appcompat:1.4.0")
    implementation("com.google.android.material:material:1.4.0")
}
