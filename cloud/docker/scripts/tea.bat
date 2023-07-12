@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_BE_VERSION=%4

set VALID_TEA_MAP_MIN[6.3.0]=2.4.1
set VALID_TEA_MAP_MAX[6.3.0]=2.4.1

REM variables
SET ARG_TEA_VERSION=na
SET ARG_TEA_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET TEA_REG="^.*tea.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
if "!ARG_INSTALLERS_PLATFORM!" EQU "win" SET TEA_REG="^.*tea.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"

call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !TEA_REG! "TIBCO TEA" false ARG_TEA_VERSION FILE_NAME ERROR_VAL
if !ERROR_VAL! EQU true GOTO END-withError

if "!ARG_TEA_VERSION!" NEQ "na" (
    echo !ARG_TEA_VERSION!|findstr /r "^[1-9]\.[0-9]\.[0-9]$" > NUL
    if !errorlevel! NEQ 0 (
        echo ERROR: Improper TEA version: [!ARG_TEA_VERSION!] It should be in [x.x.x] format Ex: [2.4.1].
        GOTO END-withError
    )
    
    SET /a teaval=!ARG_TEA_VERSION:.=!
    SET /a teaminval=!VALID_TEA_MAP_MIN[%ARG_BE_VERSION%]:.=!
    SET /a teamaxval=!VALID_TEA_MAP_MAX[%ARG_BE_VERSION%]:.=!

    if !teaval! GEQ !teaminval! if !teaval! LEQ !teamaxval! SET TEA_VALIDATION=true
    if "!TEA_VALIDATION!" NEQ "true" (
        echo ERROR: BE version: [!ARG_BE_VERSION!] not compatible with TEA version: [!ARG_TEA_VERSION!].
        GOTO END-withError
    )

    echo TEAPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt

    SET TEA_HF_REG=".*tea.*[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]\.zip$"
    SET TEA_HF_TEA_VERSION=na

    call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !TEA_HF_REG! "TIBCO TEA HF" false TEA_HF_TEA_VERSION FILE_NAME ERROR_VAL
    if !ERROR_VAL! EQU true GOTO END-withError
    
    if "!TEA_HF_TEA_VERSION!" NEQ "na" (
        if "!TEA_HF_TEA_VERSION!" EQU "!ARG_TEA_VERSION!" (
            call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !TEA_HF_REG! "TIBCO TEA HF" true ARG_TEA_HOTFIX FILE_NAME ERROR_VAL
            if !ERROR_VAL! EQU true GOTO END-withError

            if "!ARG_TEA_HOTFIX!" NEQ "na" (
                echo !ARG_TEA_HOTFIX!|findstr /r "^[0-9][0-9][0-9]$" > NUL
                if !errorlevel! NEQ 0 (
                    echo ERROR: Improper TEA hf version: [!ARG_TEA_HOTFIX!] It should be in [xxx] format Ex: [001].
                    GOTO END-withError
                )
                echo TEAHFPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt
            )
        ) else (
            echo ERROR: TIBCO TEA version: [!TEA_HF_TEA_VERSION!] in HF installer and TIBCO TEA Base version: [!ARG_TEA_VERSION!] is not matching.
            GOTO END-withError
        )
    )
)

SET "%5=!ARG_TEA_VERSION!" & SET "%6=!ARG_TEA_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0

:END-withError
    SET "%7=true"
    EXIT /B 1
