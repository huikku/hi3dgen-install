@echo off
echo Running Hi3DGen installer in debug mode...
echo This will show any error messages that occur during installation.
echo.
powershell -NoExit -ExecutionPolicy Bypass -Command "& {$ErrorActionPreference = 'Continue'; try { . '%~dp0scripts\install_hi3dgen.ps1' } catch { Write-Host $_.Exception.Message -ForegroundColor Red; Write-Host $_.ScriptStackTrace -ForegroundColor Yellow; pause } }"
