@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

REM setup the prerequisites for gv providers
#set gvproviders=%1
#powershell -Command "if ('%gvproviders%'.Contains(\"consul\")) { c:\tibco\be\gvproviders\consul\setup.bat }"

echo Installing Chocolatey Package Manager for Windows
powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | out-null"
REM Upgrade Chocolatey Package Manager, if needed
powershell -Command "c:\ProgramData\chocolatey\bin\choco upgrade chocolatey | out-null"

powershell -Command "c:\ProgramData\chocolatey\bin\choco install jq --force -version 1.5 -y"
powershell -Command "c:\ProgramData\chocolatey\bin\choco install curl -y"
