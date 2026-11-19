@echo off
powershell.exe -NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0Launcher.ps1" -UpdateOnly
