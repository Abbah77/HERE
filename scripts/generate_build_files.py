- name: Fix missing or misplaced build files
  run: |
    # Ensure gradlew exists at repo root
    if [ ! -f "./gradlew" ]; then
      curl -o gradlew https://raw.githubusercontent.com/gradle/gradle/master/gradlew
      chmod +x gradlew
    fi

    # Ensure gradlew.bat exists
    if [ ! -f "./gradlew.bat" ]; then
      curl -o gradlew.bat https://raw.githubusercontent.com/gradle/gradle/master/gradlew.bat
    fi

    # Ensure gradle/wrapper folder exists
    mkdir -p gradle/wrapper

    # Download wrapper jar & properties if missing
    if [ ! -f "gradle/wrapper/gradle-wrapper.jar" ]; then
      curl -L -o gradle/wrapper/gradle-wrapper.jar https://services.gradle.org/distributions/gradle-wrapper.jar
    fi

    if [ ! -f "gradle/wrapper/gradle-wrapper.properties" ]; then
      cat > gradle/wrapper/gradle-wrapper.properties <<EOL
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOL
    fi

    # Ensure app/build.gradle exists
    if [ ! -f "app/build.gradle" ]; then
      cat > app/build.gradle <<EOL
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    compileSdk 34
    defaultConfig {
        applicationId "com.example.yourapp"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    buildFeatures {
        compose true
    }
    composeOptions {
        kotlinCompilerExtensionVersion "1.5.3"
    }
}

dependencies {
    implementation "androidx.core:core-ktx:1.12.0"
    implementation "androidx.compose.ui:ui:1.6.0"
    implementation "androidx.compose.material3:material3:1.2.0"
    implementation "androidx.compose.ui:ui-tooling-preview:1.6.0"
    implementation "androidx.activity:activity-compose:1.9.2"
}
EOL
    fi

    # Ensure project-level build.gradle exists
    if [ ! -f "build.gradle" ]; then
      cat > build.gradle <<EOL
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:8.3.1"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOL
    fi

    # Ensure settings.gradle exists
    if [ ! -f "settings.gradle" ]; then
      cat > settings.gradle <<EOL
rootProject.name = "YourProjectName"
include(":app")
EOL
    fi
