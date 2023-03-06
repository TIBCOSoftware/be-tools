@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

set CONFIGPROVIDER=%1

REM removing double quotes(")
set CONFIGPROVIDER=!CONFIGPROVIDER:"=!

if "!CONFIGPROVIDER!" EQU "na" (
    echo INFO: Skipping Config Provider setup
    exit 0
)

if NOT EXIST "c:\ProgramData\chocolatey\bin\choco.exe" (
    ping chocolatey.org -n 1 -w 20000
    if errorlevel 1 (
        echo ERROR: Cannot connect to https://chocolatey.org, check your internet/firewall settings.
        EXIT 1
    )

    echo INFO: Installing Chocolatey Package Manager for Windows
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | out-null"

    REM Upgrade Chocolatey Package Manager, if needed
    powershell -Command "c:\ProgramData\chocolatey\bin\choco upgrade chocolatey | out-null"
)

REM Installing jq
powershell -Command "c:\ProgramData\chocolatey\bin\choco install jq --force -version 1.5 -y"

REM update Config Provider name in run.bat file	
powershell -Command "(Get-Content 'c:\tibco\be\configproviders\run.bat') -replace @(Select-String -Path 'c:\tibco\be\configproviders\run.bat' -Pattern '^set CONFIGPROVIDER=na').Line.Substring(4), 'CONFIGPROVIDER=!CONFIGPROVIDER!' | Set-Content 'c:\tibco\be\configproviders\run.bat'"

set CPS=!CONFIGPROVIDER:,= !
for %%v in (!CPS!) do (
    SET CP=%%v
    echo INFO: Setting up '!CP!' Config Provider...

    REM calling Config Provider setup.bat file
    call c:\tibco\be\configproviders\!CP!\setup.bat
)
