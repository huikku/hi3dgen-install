@echo off
echo ===== Fixed Hi3DGen Installation =====
echo This will download Hi3DGen and set up the basic files.
echo.

set INSTALL_DIR=%~dp0Hi3DGen
echo Installing to: %INSTALL_DIR%

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo Downloading Hi3DGen repository...
powershell -Command "& {$ErrorActionPreference = 'Stop'; try { Invoke-WebRequest -Uri 'https://github.com/Stable-X/Hi3DGen/archive/refs/heads/main.zip' -OutFile '%INSTALL_DIR%\Hi3DGen.zip'; Expand-Archive -Path '%INSTALL_DIR%\Hi3DGen.zip' -DestinationPath '%INSTALL_DIR%' -Force; } catch { Write-Host $_.Exception.Message -ForegroundColor Red; pause; exit 1 } }"

if %ERRORLEVEL% neq 0 (
    echo Failed to download Hi3DGen repository.
    pause
    exit /b 1
)

echo Renaming extracted folder...
if exist "%INSTALL_DIR%\Hi3DGen-main" (
    xcopy /E /I /Y "%INSTALL_DIR%\Hi3DGen-main\*" "%INSTALL_DIR%"
    rmdir /S /Q "%INSTALL_DIR%\Hi3DGen-main"
)

echo Cleaning up...
if exist "%INSTALL_DIR%\Hi3DGen.zip" del "%INSTALL_DIR%\Hi3DGen.zip"

echo Creating run batch file...
(
echo @echo off
echo echo Starting Hi3DGen...
echo cd /d "%%~dp0"
echo python app.py
) > "%INSTALL_DIR%\run_hi3dgen.bat"

echo.
echo Installation completed!
echo.
echo To run Hi3DGen:
echo 1. Make sure you have Python 3.10+ installed
echo 2. Install required packages: pip install -r "%INSTALL_DIR%\requirements.txt"
echo 3. Run: "%INSTALL_DIR%\run_hi3dgen.bat"
echo.
echo Note: You may need to create a .env file with your Hugging Face token:
echo HUGGINGFACE_TOKEN=your_token_here
echo.
pause
