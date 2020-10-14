@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

set GVPROVIDER=na

if "!GVPROVIDER!" EQU "na" (
    echo INFO: Skipping gv provider setup
    exit 0
)

if NOT EXIST "c:\ProgramData\chocolatey\bin\choco" (
    echo INFO: Installing Chocolatey Package Manager for Windows
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | out-null"
)

REM Upgrade Chocolatey Package Manager, if needed
powershell -Command "c:\ProgramData\chocolatey\bin\choco upgrade chocolatey | out-null"

REM Installing jq
powershell -Command "c:\ProgramData\chocolatey\bin\choco install jq --force -version 1.5 -y"

REM calling gv provider setup.bat file
c:\tibco\be\gvproviders\!GVPROVIDER!\setup.bat