@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

SET OPEN_JDK_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_JRE_VERSION=%4

SET "OPEN_JDK_VERSION=na"
SET "OPEN_JDK_FILENAME=na"

if "!ARG_INSTALLERS_PLATFORM!" EQU "linux" (
    SET "OPEN_JDK_REGEX=openjdk-[0-9][0-9].*linux-.*.tar.gz"
) else (
    SET "OPEN_JDK_REGEX=openjdk-[0-9][0-9].*windows-.*.zip"
)

for /f %%i in ('dir /b !OPEN_JDK_INSTALLER_LOCATION! ^| findstr /I "!OPEN_JDK_REGEX!"') do (
    if !MULTIPLE_INSTLRS! EQU true (
        echo ERROR: Multiple openjdk installer found at the specified location:[!OPEN_JDK_INSTALLER_LOCATION!].
        SET "%~7=true"
        EXIT /B 1
    )
    set MULTIPLE_INSTLRS=true
    set OPEN_JDK_FILENAME=%%i
    
    for /f "tokens=2 delims=-" %%a in ("!OPEN_JDK_FILENAME!") do
        for /f "tokens=2 delims=+" %%b in ("%%a") do
            for /f "tokens=2 delims=." %%c in ("%%b") do (
                set "OPEN_JDK_VERSION=%%c"
            )
)

if !OPEN_JDK_VERSION! EQU na (
    echo ERROR: Openjdk installer archive not found at the specified location:[!OPEN_JDK_INSTALLER_LOCATION!].
    SET "%~7=true"
    EXIT /B 1
)

SET "%5=!OPEN_JDK_VERSION!" & SET "%6=!OPEN_JDK_FILENAME!" & SET "%7=false"
EXIT /B 0
