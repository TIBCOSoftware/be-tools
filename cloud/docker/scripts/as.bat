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
set VALID_AS_MAP_MAX[6.1.1]=4.7.0
set VALID_AS_MAP_MIN[6.1.2]=4.7.0
set VALID_AS_MAP_MAX[6.1.2]=4.7.0
set VALID_AS_MAP_MIN[6.2.0]=4.7.0
set VALID_AS_MAP_MAX[6.2.0]=4.7.0
set VALID_AS_MAP_MIN[6.2.1]=4.7.0
set VALID_AS_MAP_MAX[6.2.1]=4.7.0
set VALID_AS_MAP_MIN[6.2.2]=4.7.0
set VALID_AS_MAP_MAX[6.2.2]=4.7.1
set VALID_AS_MAP_MIN[6.3.0]=4.7.0
set VALID_AS_MAP_MAX[6.3.0]=4.8.1
set VALID_AS_MAP_MIN[6.3.1]=4.7.0
set VALID_AS_MAP_MAX[6.3.1]=4.10.1

REM variables
SET ARG_AS_VERSION=na
SET ARG_AS_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET AS_REG="^.*as.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET AS_HF_REG="^.*as.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET DISPLAY_NAME="TIBCO Activespaces"

call .\scripts\util.bat :getNumberFromVersion !VALID_AS_MAP_MIN[%ARG_BE_VERSION%]!
set /a "asminval=!converted_version!"

call .\scripts\util.bat :getNumberFromVersion !VALID_AS_MAP_MAX[%ARG_BE_VERSION%]!
set /a "asmaxval=!converted_version!"

call .\scripts\util.bat :CheckInstallerAndHF !ARG_INSTALLER_LOCATION! !AS_REG! !AS_HF_REG! !DISPLAY_NAME! !asminval! !asmaxval! !ARG_TEMP_FOLDER! ARG_AS_VERSION ARG_AS_HOTFIX
if "!ARG_AS_HOTFIX!" EQU "true" (
    SET ERROR_VAL=true
    SET ARG_AS_HOTFIX=na
)
SET "%5=!ARG_AS_VERSION!" & SET "%6=!ARG_AS_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0
