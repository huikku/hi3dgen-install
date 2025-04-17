@echo off
echo ===== Hi3DGen Installation =====
echo Starting Hi3DGen fresh installation...
echo This will install Hi3DGen from scratch on your computer.
echo Repository: https://github.com/Stable-X/Hi3DGen
echo.
echo Prerequisites:
echo - Windows 10/11
echo - Python 3.10 or newer
echo - NVIDIA GPU with CUDA support (recommended)
echo - Hugging Face account with token (for model weights)
echo.
echo The installer will download all necessary files and set up Hi3DGen.
echo Please click "Yes" when prompted for administrator privileges.
echo.
powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0scripts\install_hi3dgen.ps1\"' -Verb RunAs"
echo.
echo If the installation window doesn't appear, please check your antivirus settings.
echo You may need to allow PowerShell to run scripts with administrator privileges.
echo.
pause
