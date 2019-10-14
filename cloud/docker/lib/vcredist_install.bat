@echo off

echo Installing Chocolatey Package Manager for Windows
powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | out-null"

REM Upgrade Chocolatey Package Manager, if needed
powershell -Command "c:\ProgramData\chocolatey\bin\choco upgrade chocolatey | out-null"

REM Install Missing MSVC Redistributable Libraries (MSVC{p|i|r}*.*)
powershell -Command "c:\ProgramData\chocolatey\bin\choco install -y vcredist2005 vcredist2008 vcredist2010 vcredist2012 vcredist2013 vcredist140 | out-null"
