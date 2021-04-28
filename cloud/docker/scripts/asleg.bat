@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_BE_VERSION=%4

set VALID_AS_LEG_MAP_MIN[5.6.0]=2.3.0
set VALID_AS_LEG_MAP_MAX[5.6.0]=2.4.0
set VALID_AS_LEG_MAP_MIN[5.6.1]=2.3.0
set VALID_AS_LEG_MAP_MAX[5.6.1]=2.4.1
set VALID_AS_LEG_MAP_MIN[6.0.0]=2.4.0
set VALID_AS_LEG_MAP_MAX[6.0.0]=2.4.1
set VALID_AS_LEG_MAP_MIN[6.1.0]=2.4.0
set VALID_AS_LEG_MAP_MAX[6.1.0]=2.4.1
set VALID_AS_LEG_MAP_MIN[6.1.1]=2.4.0
set VALID_AS_LEG_MAP_MAX[6.1.1]=2.4.1

REM variables
SET ARG_AS_LEG_VERSION=na
SET ARG_AS_LEG_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET AS_LEG_REG="^.*activespaces.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"

call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !AS_LEG_REG! "TIBCO Activespaces legacy" false ARG_AS_LEG_VERSION FILE_NAME ERROR_VAL
if !ERROR_VAL! EQU true GOTO END-withError

if "!ARG_AS_LEG_VERSION!" NEQ "na" (
    echo !ARG_AS_LEG_VERSION!|findstr /r "^[1-9]\.[0-9]\.[0-9]$" > NUL
    if !errorlevel! NEQ 0 (
        echo ERROR: Improper Activespaces legacy version: [!ARG_AS_LEG_VERSION!] It should be in [x.x.x] format Ex: [2.4.0].
        GOTO END-withError
    )
    
    SET /a aslegval=!ARG_AS_LEG_VERSION:.=!
    SET /a aslegminval=!VALID_AS_LEG_MAP_MIN[%ARG_BE_VERSION%]:.=!
    SET /a aslegmaxval=!VALID_AS_LEG_MAP_MAX[%ARG_BE_VERSION%]:.=!

    if !aslegval! GEQ !aslegminval! if !aslegval! LEQ !aslegmaxval! SET AS_LEG_VALIDATION=true
    if "!AS_LEG_VALIDATION!" NEQ "true" (
        echo ERROR: BE version: [!ARG_BE_VERSION!] not compatible with Activespaces legacy version: [!ARG_AS_LEG_VERSION!].
        GOTO END-withError
    )

    echo ASLEGPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt

    SET AS_LEG_HF_REG="^.*activespaces.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
    SET AS_LEG_HF_AS_LEG_VERSION=na

    call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !AS_LEG_HF_REG! "TIBCO Activespaces legacy HF" false AS_LEG_HF_AS_LEG_VERSION FILE_NAME ERROR_VAL
    if !ERROR_VAL! EQU true GOTO END-withError

    if "!AS_LEG_HF_AS_LEG_VERSION!" NEQ "na" (
        if "!AS_LEG_HF_AS_LEG_VERSION!" EQU "!ARG_AS_LEG_VERSION!" (
            call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !AS_LEG_HF_REG! "TIBCO Activespaces legacy HF" true ARG_AS_LEG_HOTFIX FILE_NAME ERROR_VAL
            if !ERROR_VAL! EQU true GOTO END-withError

            if "!ARG_AS_LEG_HOTFIX!" NEQ "na" (
                echo !ARG_AS_LEG_HOTFIX!|findstr /r "^[0-9][0-9][0-9]$" > NUL
                if !errorlevel! NEQ 0 (
                    echo ERROR: Improper Activespaces legacy hf version: [!ARG_AS_LEG_HOTFIX!] It should be in [xxx] format Ex: [001].
                    GOTO END-withError
                )
                echo ASLEGHFPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt
            )
        ) else (
            echo ERROR: TIBCO Activespaces legacy version: [!AS_LEG_HF_AS_LEG_VERSION!] in HF installer and TIBCO Activespaces legacy Base version: [!ARG_AS_LEG_VERSION!] is not matching.
            GOTO END-withError
        )
    )
)

SET "%5=!ARG_AS_LEG_VERSION!" & SET "%6=!ARG_AS_LEG_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0

:END-withError
    SET "%7=true"
    EXIT /B 1