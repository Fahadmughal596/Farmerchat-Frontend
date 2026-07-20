@echo off
echo FarmerChat APK Builder
echo ======================
flutter pub get
if %ERRORLEVEL% neq 0 goto error
flutter build apk --release
if %ERRORLEVEL% neq 0 goto error
echo.
echo APK generated at:
echo build\app\outputs\flutter-apk\app-release.apk
pause
exit /b 0
:error
echo.
echo Build failed. Copy the last 40 lines and send them for fixing.
pause
exit /b 1
