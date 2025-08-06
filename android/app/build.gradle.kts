import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing configuration
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.majore.majore_mvvm_template"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    signingConfigs {
        create("staging") {
            keyAlias = keystoreProperties["staging.keyAlias"] as String?
            keyPassword = keystoreProperties["staging.keyPassword"] as String?
            storeFile = keystoreProperties["staging.storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["staging.storePassword"] as String?
        }
        create("prod") {
            keyAlias = keystoreProperties["prod.keyAlias"] as String?
            keyPassword = keystoreProperties["prod.keyPassword"] as String?
            storeFile = keystoreProperties["prod.storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["prod.storePassword"] as String?
        }
    }
    
    flavorDimensions += "env"
    productFlavors {
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Majore Template App (Staging)")
            signingConfig = signingConfigs.getByName("staging")
        }
        create("prod") {
            dimension = "env"
            applicationIdSuffix = ""
            resValue("string", "app_name", "Majore Template App (Prod)")
            signingConfig = signingConfigs.getByName("prod")
        }
    }
   
    
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.majore.majore_mvvm_template"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = false
    }

    buildTypes {
        debug {
            // Debug builds use debug signing config (default)
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // Release builds use flavor-specific signing configs
            // No explicit signingConfig here - let flavors handle it
            minifyEnabled = false
            proguardFiles = getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
        }
    }
}

flutter {
    source = "../.."
}
