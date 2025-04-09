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
set VALID_TEA_MAP_MIN[6.3.1]=2.4.2
set VALID_TEA_MAP_MAX[6.3.1]=2.4.2
set VALID_TEA_MAP_MIN[6.3.2]=2.4.2
set VALID_TEA_MAP_MAX[6.3.2]=2.4.2

REM variables
SET ARG_TEA_VERSION=na
SET ARG_TEA_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET TEA_REG="^.*tea.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET TEA_HF_REG=".*tea.*[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]\.zip$"
SET DISPLAY_NAME="TIBCO TEA"

call .\scripts\util.bat :getNumberFromVersion !VALID_TEA_MAP_MIN[%ARG_BE_VERSION%]!
set /a "teaminval=!converted_version!"

call .\scripts\util.bat :getNumberFromVersion !VALID_TEA_MAP_MAX[%ARG_BE_VERSION%]!
set /a "teamaxval=!converted_version!"

call .\scripts\util.bat :CheckInstallerAndHF !ARG_INSTALLER_LOCATION! !TEA_REG! !TEA_HF_REG! !DISPLAY_NAME! !teaminval! !teamaxval! !ARG_TEMP_FOLDER! ARG_TEA_VERSION ARG_TEA_HOTFIX
if "!ARG_TEA_HOTFIX!" EQU "true" (
    SET ERROR_VAL=true
    SET ARG_TEA_HOTFIX=na
)
SET "%5=!ARG_TEA_VERSION!" & SET "%6=!ARG_TEA_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0
