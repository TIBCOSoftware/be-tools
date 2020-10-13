@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

set GVPROVIDER=%1

set SUPPORTED_GV_PROVIDERS[consul]=consul
set SUPPORTED_GV_PROVIDERS[http]=http
set SUPPORTED_GV_PROVIDERS[custom]=custom

if "!GVPROVIDER!" EQU "" (
   set "GVPROVIDER=na"
)
REM removing spaces
set "GVPROVIDER=%GVPROVIDER: =%"
if !GVPROVIDER! EQU "" (
    set "GVPROVIDER=na"
)

if "!GVPROVIDER!" EQU "na" (
    echo INFO: Skipping gv provider setup
    del /Q /S "c:\tibco\be\gvproviders\*" > NUl
    exit 0
)

if "!SUPPORTED_GV_PROVIDERS[%GVPROVIDER%]!" NEQ "!GVPROVIDER!" (
    echo ERROR: gv provider: [!GVPROVIDER!] is not supported.
    exit 1
) else (
    echo INFO: Setting up [!GVPROVIDER!] gv provider.
    echo.
)

REM cleanup other folders except given GVPROVIDER
for /d %%a IN ("c:\tibco\be\gvproviders\*") do (
    if "%%a" NEQ "c:\tibco\be\gvproviders\%GVPROVIDER%" (
        RD /S /Q "%%a" > NUL
    )
)
del /Q /S "c:\tibco\be\gvproviders\*.sh" > NUl

REM update gvprovider name in run.bat file
powershell -Command "(Get-Content 'c:\tibco\be\gvproviders\run.bat') -replace @(Select-String -Path 'c:\tibco\be\gvproviders\run.bat' -Pattern '^set GVPROVIDER=na').Line.Substring(4), 'GVPROVIDER=%GVPROVIDER%' | Set-Content 'c:\tibco\be\gvproviders\run.bat'"

if NOT EXIST "c:\ProgramData\chocolatey\bin\choco" (
    echo INFO: Installing Chocolatey Package Manager for Windows
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | out-null"
)

REM Upgrade Chocolatey Package Manager, if needed
powershell -Command "c:\ProgramData\chocolatey\bin\choco upgrade chocolatey | out-null"

REM Installing jq
powershell -Command "c:\ProgramData\chocolatey\bin\choco install jq --force -version 1.5 -y"

REM calling gv provider setup.bat file
if EXIST "c:\tibco\be\gvproviders\!GVPROVIDER!\setup.bat" ( 
    c:\tibco\be\gvproviders\!GVPROVIDER!\setup.bat 
)