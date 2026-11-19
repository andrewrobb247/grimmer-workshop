@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0Profile\Mods\ZZZ_GrimmerHUD\Configure.ps1"
if errorlevel 1 pause
