@echo off
echo Starting Hi3DGen fresh installation...
echo This will install Hi3DGen from scratch on your computer.
echo Please click "Yes" when prompted for administrator privileges.
powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0fresh_install_hi3dgen.ps1\"' -Verb RunAs"
