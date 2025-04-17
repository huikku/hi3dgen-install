@echo off
echo Running Hi3DGen installer with administrator privileges...
powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0scripts\install_hi3dgen.ps1\"' -Verb RunAs -Wait"
echo.
echo If the installation completed successfully, you should find:
echo 1. A desktop shortcut to Hi3DGen
echo 2. The Hi3DGen folder in the scripts directory
echo.
pause
