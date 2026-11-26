@echo off
set "PATH=C:\Users\marco\flutter\bin;%PATH%"
cd /d "%~dp0"
flutter run -d chrome %*
