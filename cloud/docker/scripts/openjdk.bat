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
    set FILENAME_SPLIT=!OPEN_JDK_FILENAME:-= !
    for  /f "tokens=2" %%j in ("!FILENAME_SPLIT!") do (
        set TEMP_VAR=%%j
        set TEMP_VAR_SPLIT=!TEMP_VAR:_= !
        set /a index=0
        for %%k in (!TEMP_VAR_SPLIT!) do (
            set /a index += 1
            if !index! EQU 1 (
                set TEMP_VAR2=%%k
                set TEMP_VAR_SPLIT2=!TEMP_VAR2:+= !
                for /f "tokens=1" %%l in ("!TEMP_VAR_SPLIT2!") do (
                    set OPEN_JDK_VERSION=%%l
                )
            )
        )
    )
)

SET "%5=!OPEN_JDK_VERSION!" & SET "%6=!OPEN_JDK_FILENAME!" & SET "%7=false"
EXIT /B 0
