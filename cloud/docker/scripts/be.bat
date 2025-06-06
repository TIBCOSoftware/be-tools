@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3

SET GLOBAL_JRE_VERSION_MAP[5.6.0]=1.8.0
SET GLOBAL_JRE_VERSION_MAP[5.6.1]=11
SET GLOBAL_JRE_VERSION_MAP[6.0.0]=11
SET GLOBAL_JRE_VERSION_MAP[6.1.0]=11
SET GLOBAL_JRE_VERSION_MAP[6.1.1]=11
SET GLOBAL_JRE_VERSION_MAP[6.1.2]=11
SET GLOBAL_JRE_VERSION_MAP[6.2.0]=11
SET GLOBAL_JRE_VERSION_MAP[6.2.1]=11
SET GLOBAL_JRE_VERSION_MAP[6.2.2]=11
SET GLOBAL_JRE_VERSION_MAP[6.3.0]=11
SET GLOBAL_JRE_VERSION_MAP[6.3.1]=17
SET GLOBAL_JRE_VERSION_MAP[6.3.2]=17
SET GLOBAL_JRE_VERSION_MAP[6.4.0]=17

REM variables
SET ARG_BE_VERSION=na
SET ARG_BE_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET BE_REG="^.*businessevents-enterprise.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET BE_HF_REG="^.*businessevents-hf_.*[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET DISPLAY_NAME="TIBCO Businessevents"

call .\scripts\util.bat :CheckInstallerAndHF !ARG_INSTALLER_LOCATION! !BE_REG! !BE_HF_REG! !DISPLAY_NAME! "na" "na" !ARG_TEMP_FOLDER! ARG_BE_VERSION ARG_BE_HOTFIX
if "!ARG_BE_HOTFIX!" EQU "true" (
    SET ERROR_VAL=true
    SET ARG_BE_HOTFIX=na
)

set ARG_JRE_VERSION=!GLOBAL_JRE_VERSION_MAP[%ARG_BE_VERSION%]!

SET "%4=!ARG_BE_VERSION!" & SET "%5=!ARG_BE_HOTFIX!" & SET "%6=!ARG_JRE_VERSION!" & SET "%7=!ERROR_VAL!"
EXIT /B 0
