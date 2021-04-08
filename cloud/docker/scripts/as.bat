@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_BE_VERSION=%4

set VALID_AS_MAP_MIN[6.0.0]=4.4.0
set VALID_AS_MAP_MAX[6.0.0]=4.4.0
set VALID_AS_MAP_MIN[6.1.0]=4.6.1
set VALID_AS_MAP_MAX[6.1.0]=4.6.1
set VALID_AS_MAP_MIN[6.1.1]=4.6.1
set VALID_AS_MAP_MAX[6.1.1]=4.6.1

REM variables
SET ARG_AS_VERSION=na
SET ARG_AS_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET AS_REG="^.*as.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"

call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !AS_REG! "TIBCO Activespaces" false ARG_AS_VERSION FILE_NAME ERROR_VAL
if !ERROR_VAL! EQU true GOTO END-withError

if "!ARG_AS_VERSION!" NEQ "na" (
    echo !ARG_AS_VERSION!|findstr /r "^[1-9]\.[0-9]\.[0-9]$" > NUL
    if !errorlevel! NEQ 0 (
        echo ERROR: Improper Activespaces version: [!ARG_AS_VERSION!] It should be in [x.x.x] format Ex: [4.4.0].
        GOTO END-withError
    )
    
    SET /a asval=!ARG_AS_VERSION:.=!
    SET /a asminval=!VALID_AS_MAP_MIN[%ARG_BE_VERSION%]:.=!
    SET /a asmaxval=!VALID_AS_MAP_MAX[%ARG_BE_VERSION%]:.=!

    if !asval! GEQ !asminval! if !asval! LEQ !asmaxval! SET AS_VALIDATION=true
    if "!AS_VALIDATION!" NEQ "true" (
        echo ERROR: BE version: [!ARG_BE_VERSION!] not compatible with Activespaces version: [!ARG_AS_VERSION!].
        GOTO END-withError
    )

    echo ASLEGPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt

    SET AS_HF_REG="^.*as.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
    SET AS_HF_AS_VERSION=na

    call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !AS_HF_REG! "TIBCO Activespaces HF" false AS_HF_AS_VERSION FILE_NAME ERROR_VAL
    if !ERROR_VAL! EQU true GOTO END-withError

    if "!AS_HF_AS_VERSION!" NEQ "na" (
        if "!AS_HF_AS_VERSION!" EQU "!ARG_AS_VERSION!" (
            call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !AS_HF_REG! "TIBCO Activespaces HF" true ARG_AS_HOTFIX FILE_NAME ERROR_VAL
            if !ERROR_VAL! EQU true GOTO END-withError

            if "!ARG_AS_HOTFIX!" NEQ "na" (
                echo !ARG_AS_HOTFIX!|findstr /r "^[0-9][0-9][0-9]$" > NUL
                if !errorlevel! NEQ 0 (
                    echo ERROR: Improper Activespaces hf version: [!ARG_AS_HOTFIX!] It should be in [xxx] format Ex: [001].
                    GOTO END-withError
                )
                echo ASLEGHFPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt
            )
        ) else (
            echo ERROR: TIBCO Activespaces version: [!AS_HF_AS_VERSION!] in HF installer and TIBCO Activespaces Base version: [!ARG_AS_VERSION!] is not matching.
            GOTO END-withError
        )
    )
)

SET "%5=!ARG_AS_VERSION!" & SET "%6=!ARG_AS_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0

:END-withError
    SET "%7=true"
    EXIT /B 1