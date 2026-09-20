@echo off
set ANDROID_PREFS_ROOT=
set ANDROID_USER_HOME=
cd android
call gradlew --stop
cd ..
flutter build apk --debug
