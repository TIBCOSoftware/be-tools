@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_BE_VERSION=%4

set VALID_HAWK_MAP_MIN[6.2.2]=7.1.0
set VALID_HAWK_MAP_MAX[6.2.2]=7.1.0
set VALID_HAWK_MAP_MIN[6.3.0]=7.1.0
set VALID_HAWK_MAP_MAX[6.3.0]=7.2.1
set VALID_HAWK_MAP_MIN[6.3.1]=7.1.0
set VALID_HAWK_MAP_MAX[6.3.1]=7.2.1

REM variables
SET ARG_HAWK_VERSION=na
SET ARG_HAWK_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET HAWK_REG="^.*oihr.*[0-9]\.[0-9]\.[0-9]_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET HAWK_HF_REG="^.*oihr.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET DISPLAY_NAME="TIBCO HAWK"
SET /a hawkminval=!VALID_HAWK_MAP_MIN[%ARG_BE_VERSION%]:.=!
SET /a hawkmaxval=!VALID_HAWK_MAP_MAX[%ARG_BE_VERSION%]:.=!

call .\scripts\util.bat :CheckInstallerAndHF !ARG_INSTALLER_LOCATION! !HAWK_REG! !HAWK_HF_REG! !DISPLAY_NAME! !hawkminval! !hawkmaxval! !ARG_TEMP_FOLDER! ARG_HAWK_VERSION ARG_HAWK_HOTFIX
if "!ARG_HAWK_HOTFIX!" EQU "true" (
    SET ERROR_VAL=true
    SET ARG_HAWK_HOTFIX=na
)
SET "%5=!ARG_HAWK_VERSION!" & SET "%6=!ARG_HAWK_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0
