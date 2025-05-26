buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // PENTING: Tambahkan konfigurasi ini untuk mengatasi masalah NDK
    afterEvaluate {
        if (project.hasProperty("android")) {
            project.extensions.findByName("android")?.apply {
                // Sesuaikan dengan versi NDK yang tersedia di sistem Anda
                // ATAU hapus baris ini jika tidak butuh NDK
                (this as com.android.build.gradle.BaseExtension).ndkVersion = null
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}