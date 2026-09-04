  import org.jetbrains.kotlin.gradle.dsl.JvmTarget
plugins {
    id("com.android.application")

    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.15.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")

  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}
android {
    namespace = "com.example.e_commerc_app"

    compileSdk = 36

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.e_commerc_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        
        
    }

    compileOptions {
         isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }


kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
}


flutter {
    source = "../.."
}
