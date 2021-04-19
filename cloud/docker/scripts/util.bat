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

:RemoveDuplicatesAndFormatGVs
    set ARG_GVPROVIDER=%~1
    set ARG_GV_RESULT=

    set GVS=!ARG_GVPROVIDER:,= !
    for %%j in (!GVS!) do (

        SET GV=%%j
        set "GV=!GV:custom\=!"
        set "GV=!GV:custom/=!"

        if "!GV!" NEQ "http" if "!GV!" NEQ "consul" set "GV=custom\!GV!"

        SET DUPLICATE_FOUND=false
        if "!ARG_GV_RESULT!" EQU "" (
            set ARG_GV_RESULT=!GV!
        ) else (
            set GVS2=!ARG_GV_RESULT:,= !
            for %%k in (!GVS2!) do (
                if "!GV!" EQU "%%k" (
                    SET DUPLICATE_FOUND=true
                )
            )
            if "!DUPLICATE_FOUND!" EQU "false" (
                SET "ARG_GV_RESULT=!ARG_GV_RESULT!,!GV!"
            )
        )
    )
    set ARG_GVPROVIDER=!ARG_GV_RESULT!
    EXIT /B 0

:ValidateFTLAndAS
    SET ARG_BE_VERSION=%~1
    SET IMAGE_NAME=%~2
    SET RMS_IMAGE=%~3
    SET VALIDATE_FTL_AS=%~4
    SET /a BE6VAL=!ARG_BE_VERSION:.=!

    REM check for FTL and AS4 only when BE version is > 6.0.0
    if !BE6VAL! GEQ 600 SET "VALIDATE_FTL_AS=true"

    REM check for FTL and AS4 only when BE version is > 6.1.1 if app is rms
    if "!IMAGE_NAME!" EQU "!RMS_IMAGE!" (
        if !BE6VAL! GEQ 611 (
            SET "VALIDATE_FTL_AS=true"
        ) else (
            SET "VALIDATE_FTL_AS=false"
        )
    )
    EXIT /B 0