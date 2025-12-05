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
set VALID_FTL_MAP_MIN[6.1.2]=6.7.1
set VALID_FTL_MAP_MAX[6.1.2]=6.7.1
set VALID_FTL_MAP_MIN[6.2.0]=6.7.1
set VALID_FTL_MAP_MAX[6.2.0]=6.7.1
set VALID_FTL_MAP_MIN[6.2.1]=6.7.1
set VALID_FTL_MAP_MAX[6.2.1]=6.7.1
set VALID_FTL_MAP_MIN[6.2.2]=6.7.1
set VALID_FTL_MAP_MAX[6.2.2]=6.7.3
set VALID_FTL_MAP_MIN[6.3.0]=6.7.1
set VALID_FTL_MAP_MAX[6.3.0]=6.10.0
set VALID_FTL_MAP_MIN[6.3.1]=6.7.1
set VALID_FTL_MAP_MAX[6.3.1]=7.0.0
set VALID_FTL_MAP_MIN[6.3.2]=6.7.1
set VALID_FTL_MAP_MAX[6.3.2]=7.0.1
set VALID_FTL_MAP_MIN[6.4.0]=7.0.0
set VALID_FTL_MAP_MAX[6.4.0]=7.1.1

REM variables
SET ARG_FTL_VERSION=na
SET ARG_FTL_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET FTL_REG="^.*ftl.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$ ^.*ftl.*[0-9]\.[0-9][0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
if "!ARG_INSTALLERS_PLATFORM!" EQU "win" SET FTL_REG="^.*ftl.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.exe$ ^.*ftl.*[0-9]\.[0-9][0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.exe$"
SET FTL_HF_REG="^.*ftl.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$ ^.*ftl.*[0-9]\.[0-9][0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET DISPLAY_NAME="TIBCO FTL"

call .\scripts\util.bat :getNumberFromVersion !VALID_FTL_MAP_MIN[%ARG_BE_VERSION%]!
set /a "ftlminval=!converted_version!"

call .\scripts\util.bat :getNumberFromVersion !VALID_FTL_MAP_MAX[%ARG_BE_VERSION%]!
set /a "ftlmaxval=!converted_version!"

call .\scripts\util.bat :CheckInstallerAndHF !ARG_INSTALLER_LOCATION! !FTL_REG! !FTL_HF_REG! !DISPLAY_NAME! !ftlminval! !ftlmaxval! !ARG_TEMP_FOLDER! ARG_FTL_VERSION ARG_FTL_HOTFIX
if "!ARG_FTL_HOTFIX!" EQU "true" (
    SET ERROR_VAL=true
    SET ARG_FTL_HOTFIX=na
)
SET "%5=!ARG_FTL_VERSION!" & SET "%6=!ARG_FTL_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0
