@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList ' -ExecutionPolicy Bypass','-File %~dp0\InstallHome.ps1' -Verb RunAs"
pause