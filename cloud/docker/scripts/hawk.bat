@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_BE_VERSION=%4

set VALID_HAWK_MAP_MIN[6.2.2]=6.2.1
set VALID_HAWK_MAP_MAX[6.2.2]=7.1.0


REM variables
SET ARG_HAWK_VERSION=na
SET ARG_HAWK_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET HAWK_REG="^.*oihr.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
if "!ARG_INSTALLERS_PLATFORM!" EQU "win" SET HAWK_REG="^.*oihr.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"

call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !HAWK_REG! "TIBCO HAWK" false ARG_HAWK_VERSION FILE_NAME ERROR_VAL
if !ERROR_VAL! EQU true GOTO END-withError

if "!ARG_HAWK_VERSION!" NEQ "na" (
    echo !ARG_HAWK_VERSION!|findstr /r "^[1-9]\.[0-9]\.[0-9]$" > NUL
    if !errorlevel! NEQ 0 (
        echo ERROR: Improper HAWK version: [!ARG_HAWK_VERSION!] It should be in [x.x.x] format Ex: [4.4.0].
        GOTO END-withError
    )
    
    SET /a hawkval=!ARG_HAWK_VERSION:.=!
    SET /a hawkminval=!VALID_HAWK_MAP_MIN[%ARG_BE_VERSION%]:.=!
    SET /a hawkmaxval=!VALID_HAWK_MAP_MAX[%ARG_BE_VERSION%]:.=!

    if !hawkval! GEQ !hawkminval! if !hawkval! LEQ !hawkmaxval! SET HAWK_VALIDATION=true
    if "!HAWK_VALIDATION!" NEQ "true" (
        echo ERROR: BE version: [!ARG_BE_VERSION!] not compatible with HAWK version: [!ARG_HAWK_VERSION!].
        GOTO END-withError
    )

    echo ASLEGPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt

    SET HAWK_HF_REG="^.*oihr.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
    SET HAWK_HF_HAWK_VERSION=na

    call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !HAWK_HF_REG! "TIBCO HAWK HF" false HAWK_HF_HAWK_VERSION FILE_NAME ERROR_VAL
    if !ERROR_VAL! EQU true GOTO END-withError

    if "!HAWK_HF_HAWK_VERSION!" NEQ "na" (
        if "!HAWK_HF_HAWK_VERSION!" EQU "!ARG_HAWK_VERSION!" (
            call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !HAWK_HF_REG! "TIBCO HAWK HF" true ARG_HAWK_HOTFIX FILE_NAME ERROR_VAL
            if !ERROR_VAL! EQU true GOTO END-withError

            if "!ARG_HAWK_HOTFIX!" NEQ "na" (
                echo !ARG_HAWK_HOTFIX!|findstr /r "^[0-9][0-9][0-9]$" > NUL
                if !errorlevel! NEQ 0 (
                    echo ERROR: Improper HAWK hf version: [!ARG_HAWK_HOTFIX!] It should be in [xxx] format Ex: [001].
                    GOTO END-withError
                )
                echo ASLEGHFPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt
            )
        ) else (
            echo ERROR: TIBCO HAWK version: [!HAWK_HF_HAWK_VERSION!] in HF installer and TIBCO HAWK Base version: [!ARG_HAWK_VERSION!] is not matching.
            GOTO END-withError
        )
    )
)

SET "%5=!ARG_HAWK_VERSION!" & SET "%6=!ARG_HAWK_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0

:END-withError
    SET "%7=true"
    EXIT /B 1
