@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

set GVPROVIDER=%1

REM removing double quotes(")
set GVPROVIDER=!GVPROVIDER:"=!

if "!GVPROVIDER!" EQU "na" (
    echo INFO: Skipping gv provider setup
    exit 0
)

if NOT EXIST "c:\ProgramData\chocolatey\bin\choco.exe" (
    ping chocolatey.org -n 1 -w 20000
    if errorlevel 1 (
        echo WARN: Cannot connect to https://chocolatey.org, check your internet/firewall settings.
        EXIT 0
    )

    echo INFO: Installing Chocolatey Package Manager for Windows
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | out-null"

    REM Upgrade Chocolatey Package Manager, if needed
    powershell -Command "c:\ProgramData\chocolatey\bin\choco upgrade chocolatey | out-null"
)

REM Installing jq
powershell -Command "c:\ProgramData\chocolatey\bin\choco install jq --force -version 1.5 -y"

REM update gvprovider name in run.bat file	
powershell -Command "(Get-Content 'c:\tibco\be\gvproviders\run.bat') -replace @(Select-String -Path 'c:\tibco\be\gvproviders\run.bat' -Pattern '^set GVPROVIDER=na').Line.Substring(4), 'GVPROVIDER=!GVPROVIDER!' | Set-Content 'c:\tibco\be\gvproviders\run.bat'"

set GVS=!GVPROVIDER:,= !
for %%v in (!GVS!) do (
    SET GV=%%v
    echo INFO: Setting up '!GV!' gv provider...

    REM calling gv provider setup.bat file
    call c:\tibco\be\gvproviders\!GV!\setup.bat
)
