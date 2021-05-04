@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3

REM variables
SET ARG_BE_VERSION=na
SET ARG_BE_HOTFIX=na
set ARG_JRE_VERSION=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET BE_REG="^.*businessevents-enterprise.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"

SET GLOBAL_JRE_VERSION_MAP[5.6.0]=1.8.0
SET GLOBAL_JRE_VERSION_MAP[5.6.1]=11
SET GLOBAL_JRE_VERSION_MAP[6.0.0]=11
SET GLOBAL_JRE_VERSION_MAP[6.1.0]=11
SET GLOBAL_JRE_VERSION_MAP[6.1.1]=11

call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !BE_REG! "TIBCO Businessevents" false ARG_BE_VERSION FILE_NAME ERROR_VAL
if !ERROR_VAL! EQU true GOTO END-withError

if "!ARG_BE_VERSION!" NEQ "na" (
    echo !ARG_BE_VERSION!|findstr /r "^[1-9]\.[0-9]\.[0-9]$" > NUL
    if !errorlevel! NEQ 0 (
        echo ERROR: Improper BE version: [!ARG_BE_VERSION!] It should be in [x.x.x] format Ex: [5.6.0].
        GOTO END-withError
    )
    echo BEPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt

    set ARG_JRE_VERSION=!GLOBAL_JRE_VERSION_MAP[%ARG_BE_VERSION%]!

    SET BE_HF_REG="^.*businessevents-hf_.*[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
    SET BE_HF_BE_VERSION=na

    call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !BE_HF_REG! "TIBCO Businessevents HF" false BE_HF_BE_VERSION FILE_NAME ERROR_VAL
    if !ERROR_VAL! EQU true GOTO END-withError

    if "!BE_HF_BE_VERSION!" NEQ "na" (
        if "!BE_HF_BE_VERSION!" EQU "!ARG_BE_VERSION!" (
            call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !BE_HF_REG! "TIBCO Businessevents HF" true ARG_BE_HOTFIX FILE_NAME ERROR_VAL
            if !ERROR_VAL! EQU true GOTO END-withError

            if "!ARG_BE_HOTFIX!" NEQ "na" (
                echo !ARG_BE_HOTFIX!|findstr /r "^[0-9][0-9][0-9]$" > NUL
                if !errorlevel! NEQ 0 (
                    echo ERROR: Improper BE hf version: [!ARG_BE_HOTFIX!] It should be in [xxx] format Ex: [001].
                    GOTO END-withError
                )
                echo BEHFPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt
            )
        ) else (
            echo ERROR: TIBCO BusinessEvents version: [!BE_HF_BE_VERSION!] in HF installer and TIBCO BusinessEvents Base version: [!ARG_BE_VERSION!] is not matching.
            GOTO END-withError
        )
    )
)

SET "%4=!ARG_BE_VERSION!" & SET "%5=!ARG_BE_HOTFIX!" & SET "%6=!ARG_JRE_VERSION!" & SET "%7=!ERROR_VAL!"
EXIT /B 0

:END-withError
    SET "%7=true"
    EXIT /B 1