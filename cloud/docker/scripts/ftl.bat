@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_BE_VERSION=%4

set VALID_FTL_MAP_MIN[6.0.0]=6.4.0
set VALID_FTL_MAP_MAX[6.0.0]=6.4.9
set VALID_FTL_MAP_MIN[6.1.0]=6.5.0
set VALID_FTL_MAP_MAX[6.1.0]=6.5.0
set VALID_FTL_MAP_MIN[6.1.1]=6.5.0
set VALID_FTL_MAP_MAX[6.1.1]=6.6.1

REM variables
SET ARG_FTL_VERSION=na
SET ARG_FTL_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET FTL_REG="^.*ftl.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
if "!ARG_INSTALLERS_PLATFORM!" EQU "win" SET FTL_REG="^.*ftl.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.exe$"

call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !FTL_REG! "TIBCO FTL" false ARG_FTL_VERSION FILE_NAME ERROR_VAL
if !ERROR_VAL! EQU true GOTO END-withError

if "!ARG_FTL_VERSION!" NEQ "na" (
    echo !ARG_FTL_VERSION!|findstr /r "^[1-9]\.[0-9]\.[0-9]$" > NUL
    if !errorlevel! NEQ 0 (
        echo ERROR: Improper FTL version: [!ARG_FTL_VERSION!] It should be in [x.x.x] format Ex: [4.4.0].
        GOTO END-withError
    )
    
    SET /a ftlval=!ARG_FTL_VERSION:.=!
    SET /a ftlminval=!VALID_FTL_MAP_MIN[%ARG_BE_VERSION%]:.=!
    SET /a ftlmaxval=!VALID_FTL_MAP_MAX[%ARG_BE_VERSION%]:.=!

    if !ftlval! GEQ !ftlminval! if !ftlval! LEQ !ftlmaxval! SET FTL_VALIDATION=true
    if "!FTL_VALIDATION!" NEQ "true" (
        echo ERROR: BE version: [!ARG_BE_VERSION!] not compatible with FTL version: [!ARG_FTL_VERSION!].
        GOTO END-withError
    )

    echo ASLEGPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt

    SET FTL_HF_REG="^.*ftl.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
    SET FTL_HF_FTL_VERSION=na

    call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !FTL_HF_REG! "TIBCO FTL HF" false FTL_HF_FTL_VERSION FILE_NAME ERROR_VAL
    if !ERROR_VAL! EQU true GOTO END-withError

    if "!FTL_HF_FTL_VERSION!" NEQ "na" (
        if "!FTL_HF_FTL_VERSION!" EQU "!ARG_FTL_VERSION!" (
            call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !FTL_HF_REG! "TIBCO FTL HF" true ARG_FTL_HOTFIX FILE_NAME ERROR_VAL
            if !ERROR_VAL! EQU true GOTO END-withError

            if "!ARG_FTL_HOTFIX!" NEQ "na" (
                echo !ARG_FTL_HOTFIX!|findstr /r "^[0-9][0-9][0-9]$" > NUL
                if !errorlevel! NEQ 0 (
                    echo ERROR: Improper FTL hf version: [!ARG_FTL_HOTFIX!] It should be in [xxx] format Ex: [001].
                    GOTO END-withError
                )
                echo ASLEGHFPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt
            )
        ) else (
            echo ERROR: TIBCO FTL version: [!FTL_HF_FTL_VERSION!] in HF installer and TIBCO FTL Base version: [!ARG_FTL_VERSION!] is not matching.
            GOTO END-withError
        )
    )
)

SET "%5=!ARG_FTL_VERSION!" & SET "%6=!ARG_FTL_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0

:END-withError
    SET "%7=true"
    EXIT /B 1