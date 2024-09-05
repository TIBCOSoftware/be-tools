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
set VALID_AS_LEG_MAP_MIN[6.1.2]=2.4.1
set VALID_AS_LEG_MAP_MAX[6.1.2]=2.4.1
set VALID_AS_LEG_MAP_MIN[6.2.0]=2.4.0
set VALID_AS_LEG_MAP_MAX[6.2.0]=2.4.1
set VALID_AS_LEG_MAP_MIN[6.2.1]=2.4.1
set VALID_AS_LEG_MAP_MAX[6.2.1]=2.4.1
set VALID_AS_LEG_MAP_MIN[6.2.2]=2.4.1
set VALID_AS_LEG_MAP_MAX[6.2.2]=2.4.2
set VALID_AS_LEG_MAP_MIN[6.3.0]=2.4.1
set VALID_AS_LEG_MAP_MAX[6.3.0]=2.4.2
set VALID_AS_LEG_MAP_MIN[6.3.1]=2.4.1
set VALID_AS_LEG_MAP_MAX[6.3.1]=2.4.2

REM variables
SET ARG_AS_LEG_VERSION=na
SET ARG_AS_LEG_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET AS_LEG_REG="^.*activespaces.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET AS_LEG_HF_REG="^.*activespaces.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET DISPLAY_NAME="TIBCO Activespaces legacy"
SET /a aslegminval=!VALID_AS_LEG_MAP_MIN[%ARG_BE_VERSION%]:.=!
SET /a aslegmaxval=!VALID_AS_LEG_MAP_MAX[%ARG_BE_VERSION%]:.=!

call .\scripts\util.bat :CheckInstallerAndHF !ARG_INSTALLER_LOCATION! !AS_LEG_REG! !AS_LEG_HF_REG! !DISPLAY_NAME! !aslegminval! !aslegmaxval! !ARG_TEMP_FOLDER! ARG_AS_LEG_VERSION ARG_AS_LEG_HOTFIX
if "!ARG_AS_LEG_HOTFIX!" EQU "true" (
    SET ERROR_VAL=true
    SET ARG_AS_LEG_HOTFIX=na
)
SET "%5=!ARG_AS_LEG_VERSION!" & SET "%6=!ARG_AS_LEG_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0
