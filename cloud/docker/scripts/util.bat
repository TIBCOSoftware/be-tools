@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

call %*
GOTO :EOF

:IdentifyInstaller
    set INSTLR_LOCATION=%~1
    set INSTLR_REG=%~2
    set INSTLR_FULL_NAME=%~3
    set INSTLR_HF=%4
    set INSTLR_VERSION=na
    set FILENAME=na
    set MULTIPLE_INSTLRS=false

    for /f %%i in ('dir /b !INSTLR_LOCATION! ^| findstr /I "!INSTLR_REG!"') do (
        if !MULTIPLE_INSTLRS! EQU true (
            echo ERROR: Multiple !INSTLR_FULL_NAME! installer found at the specified location:[!INSTLR_LOCATION!].
            SET "%~5=!INSTLR_VERSION!" & SET "%~7=!MULTIPLE_INSTLRS!"
            EXIT /B 1
        )
        set MULTIPLE_INSTLRS=true
        set FILENAME=%%i
        set FILENAME_SPLIT=!FILENAME:_= !
        set /a indx=0
        for %%j in (!FILENAME_SPLIT!) do (
            set /a indx += 1
            if !indx! EQU 3 (
                set INSTLR_VERSION=%%j
            )
            if !INSTLR_HF! EQU true (
                if !indx! EQU 4 (
                    set INSTLR_VERSION=%%j
                    set INSTLR_VERSION=!INSTLR_VERSION:HF-=!
                )
            )
        )
    )
    SET "%~5=!INSTLR_VERSION!" & SET "%~6=!FILENAME!" & SET "%~7=false"
    EXIT /B 0