@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_BE_VERSION=%4

REM variables
SET ARG_ADDON=na
SET ARG_ADDONS=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET BE_ADDON_PROCESS_REG="^TIB_businessevents-process_!ARG_BE_VERSION!_!ARG_INSTALLERS_PLATFORM!.*\.zip$"

call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !BE_ADDON_PROCESS_REG! "TIBCO Businessevents process addon" false ARG_ADDON FILE_NAME ERROR_VAL
if !ERROR_VAL! EQU true GOTO END-withError

if "!ARG_ADDON!" NEQ "na" (
    SET ARG_ADDONS=process
    echo BEADDONPROCESSPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt
)

SET BE_ADDON_VIEWS_REG="^TIB_businessevents-views_!ARG_BE_VERSION!_!ARG_INSTALLERS_PLATFORM!.*\.zip$"

call .\scripts\util.bat :IdentifyInstaller !ARG_INSTALLER_LOCATION! !BE_ADDON_VIEWS_REG! "TIBCO Businessevents views addon" false ARG_ADDON FILE_NAME ERROR_VAL
if !ERROR_VAL! EQU true GOTO END-withError

if "!ARG_ADDON!" NEQ "na" (
    if "!ARG_ADDONS!" NEQ "na" (
        SET ARG_ADDONS=process,views
    ) else (
        SET ARG_ADDONS=views
    )
    echo BEADDONVIEWSPKG#!FILE_NAME! >> !ARG_TEMP_FOLDER!/package_files.txt
)

SET "%5=!ARG_ADDONS!" & SET "%6=!ERROR_VAL!"
EXIT /B 0

:END-withError
    SET "%6=true"
    EXIT /B 1