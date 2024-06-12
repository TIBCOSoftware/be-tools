@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

call %*
GOTO :EOF

:RemoveDuplicatesAndFormatCPs
    set ARG_CONFIGPROVIDER=%~1
    set ARG_CP_RESULT=

    set CPS=!ARG_CONFIGPROVIDER:,= !
    for %%j in (!CPS!) do (

        SET CP=%%j
        set "CP=!CP:custom\=!"
        set "CP=!CP:custom/=!"

        if "!CP!" NEQ "gvhttp" if "!CP!" NEQ "gvconsul" if "!CP!" NEQ "gvcyberark" if "!CP!" NEQ "cmcncf" set "CP=custom\!CP!"

        SET DUPLICATE_FOUND=false
        if "!ARG_CP_RESULT!" EQU "" (
            set ARG_CP_RESULT=!CP!
        ) else (
            set CPS2=!ARG_CP_RESULT:,= !
            for %%k in (!CPS2!) do (
                if "!CP!" EQU "%%k" (
                    SET DUPLICATE_FOUND=true
                )
            )
            if "!DUPLICATE_FOUND!" EQU "false" (
                SET "ARG_CP_RESULT=!ARG_CP_RESULT!,!CP!"
            )
        )
    )
    set ARG_CONFIGPROVIDER=!ARG_CP_RESULT!
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

:CheckInstallerAndHF
    set INSTLR_LOCATION_NEW=%~1
    set INSTLR_REG_NEW=%~2
    set INSTLR_REG_HF=%~3
    set DISPLAY_NAME=%~4
    set BASE_MIN_VALUE=%~5
    set BASE_MAX_VALUE=%~6
    set TEMP_FOLDER=%~7
    set BASE_INST_VERSION=na
    set INSTLR_HF_VERSION=na
    set FILENAME=na
    set ERROR_VAL=false
    set MULTIPLE_INSTLRS=false
    SET BASE_VALIDATION=false

    for /f %%i in ('dir /b !INSTLR_LOCATION_NEW! ^| findstr /I /r "!INSTLR_REG_NEW!"') do (
        if !MULTIPLE_INSTLRS! EQU true (
            echo ERROR: Multiple !DISPLAY_NAME! installer found at the specified location:[!INSTLR_LOCATION_NEW!].
            GOTO END-withError
        )
        set MULTIPLE_INSTLRS=true
        set FILENAME=%%i
        set FILENAME_SPLIT=!FILENAME:_= !
        set /a indx=0
        for %%j in (!FILENAME_SPLIT!) do (
            set /a indx += 1
            if !indx! EQU 3 (
                set BASE_INST_VERSION=%%j
            )
        )
    )
    set MULTIPLE_INSTLRS=false

    if "!BASE_INST_VERSION!" NEQ "na" (
        echo !BASE_INST_VERSION!|findstr /I /r "^[1-9]\.[0-9]\.[0-9]$ ^[1-9]\.[0-9][0-9]\.[0-9]$" > NUL
        if !errorlevel! NEQ 0 (
            echo ERROR: Improper !DISPLAY_NAME! version: [!BASE_INST_VERSION!] It should be in [x.x.x] format Ex: [4.4.0].
            GOTO END-withError
        )
        
        SET /a baseval=!BASE_INST_VERSION:.=!

        if "!BASE_MIN_VALUE!" EQU "" (
                echo ERROR: BE version: [!ARG_BE_VERSION!] not compatible with !DISPLAY_NAME! version: [!BASE_INST_VERSION!].
                GOTO END-withError
            )
        
        if "!BASE_MAX_VALUE!" EQU "" (
                echo ERROR: BE version: [!ARG_BE_VERSION!] not compatible with !DISPLAY_NAME! version: [!BASE_INST_VERSION!].
                GOTO END-withError
            )

        if !BASE_MIN_VALUE! NEQ na if !BASE_MAX_VALUE! NEQ na (
            if !baseval! GEQ !BASE_MIN_VALUE! if !baseval! LEQ !BASE_MAX_VALUE! SET BASE_VALIDATION=true
            if "!BASE_VALIDATION!" NEQ "true" (
                echo ERROR: BE version: [!ARG_BE_VERSION!] not compatible with !DISPLAY_NAME! version: [!BASE_INST_VERSION!].
                GOTO END-withError
            )
        )

        echo !DISPLAY_NAME!#!FILENAME! >> !TEMP_FOLDER!/package_files.txt

        SET HF_INSTLR_VERSION=na
        SET DISPLAY_NAME_NEW=!DISPLAY_NAME! HF

        for /f %%i in ('dir /b !INSTLR_LOCATION_NEW! ^| findstr /I /r "!INSTLR_REG_HF!"') do (
            if !MULTIPLE_INSTLRS! EQU true (
                echo ERROR: Multiple !DISPLAY_NAME! installer found at the specified location:[!INSTLR_LOCATION_NEW!].
                GOTO END-withError
            )
            set MULTIPLE_INSTLRS=true
            set FILENAME=%%i
            set FILENAME_SPLIT=!FILENAME:_= !
            set /a indx=0
            for %%j in (!FILENAME_SPLIT!) do (
                set /a indx += 1
                if !indx! EQU 3 (
                    set HF_INSTLR_VERSION=%%j
                )
            )
        )
        set MULTIPLE_INSTLRS=false

        if "!HF_INSTLR_VERSION!" NEQ "na" (
            if "!HF_INSTLR_VERSION!" EQU "!BASE_INST_VERSION!" (

                for /f %%i in ('dir /b !INSTLR_LOCATION_NEW! ^| findstr /I /r "!INSTLR_REG_HF!"') do (
                    if !MULTIPLE_INSTLRS! EQU true (
                        echo ERROR: Multiple !DISPLAY_NAME! installer found at the specified location:[!INSTLR_LOCATION_NEW!].
                        GOTO END-withError
                    )
                    set MULTIPLE_INSTLRS=true
                    set FILENAME=%%i
                    set FILENAME_SPLIT=!FILENAME:_= !
                    set /a indx=0
                    for %%j in (!FILENAME_SPLIT!) do (
                        set /a indx += 1
                        if !indx! EQU 4 (
                            set INSTLR_HF_VERSION=%%j
                            set INSTLR_HF_VERSION=!INSTLR_HF_VERSION:.zip=!
                            set INSTLR_HF_VERSION=!INSTLR_HF_VERSION:HF-=!
                        )
                    )
                )

                if "!INSTLR_HF_VERSION!" NEQ "na" (
                    echo !INSTLR_HF_VERSION!|findstr /I /r "^[0-9][0-9][0-9]$" > NUL
                    if !errorlevel! NEQ 0 (
                        echo ERROR: !DISPLAY_NAME_NEW! version: [!INSTLR_HF_VERSION!] It should be in [xxx] format Ex: [001].
                        GOTO END-withError
                    )
                    if "!DISPLAY_NAME!" NEQ "TIBCO JRESPLMNT" (
                        echo !DISPLAY_NAME_NEW!#!FILENAME! >> !ARG_TEMP_FOLDER!/package_files.txt
                    )
                )
            ) else (
                echo ERROR: !DISPLAY_NAME! version: [!HF_INSTLR_VERSION!] in HF installer and !DISPLAY_NAME_NEW! Base version: [!BASE_INST_VERSION!] is not matching.
                GOTO END-withError
            )
        )
    )
    SET "%~8=!BASE_INST_VERSION!" & SET "%~9=!INSTLR_HF_VERSION!"
    EXIT /B 0
    
:END-withError
    SET "%9=true"
    EXIT /B 1
