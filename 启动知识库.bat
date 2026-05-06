@echo off
chcp 65001 >nul
echo 正在启动知识库...
cd /d "%~dp0"

:: 杀掉之前可能残留的 mkdocs 进程（占用 8000 端口）
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8000 " ^| findstr "LISTENING"') do (
    echo 发现旧进程 PID: %%a，正在关闭...
    taskkill /PID %%a /F >nul 2>&1
)
timeout /t 1 /nobreak >nul

start http://127.0.0.1:8000/embedded-kb/
.venv\Scripts\mkdocs.exe serve
pause
