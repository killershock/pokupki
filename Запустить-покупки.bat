@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Покупки — локальный сервер
start "" cmd /c "timeout /t 2 >nul & start http://localhost:8092"
where python >nul 2>nul
if %errorlevel%==0 (
  python -m http.server 8092
) else (
  py -m http.server 8092
)
pause
