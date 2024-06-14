@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
SET ARG_INSTALLER_LOCATION=%1
SET ARG_INSTALLERS_PLATFORM=%2
SET ARG_TEMP_FOLDER=%3
SET ARG_BE_VERSION=%4

set VALID_JRESPLMNT_MAP_MIN[6.2.1]=1.0.0
set VALID_JRESPLMNT_MAP_MAX[6.2.1]=2.0.0

REM variables
SET ARG_JRESPLMNT_VERSION=na
SET ARG_JRESPLMNT_HOTFIX=na
SET FILE_NAME=na
SET ERROR_VAL=false
SET JRESPLMNT_REG="^.*jresplmnt.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET JRESPLMNT_HF_REG="^.*jresplmnt.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_!ARG_INSTALLERS_PLATFORM!.*\.zip$"
SET DISPLAY_NAME="TIBCO JRESPLMNT"

if "!VALID_JRESPLMNT_MAP_MIN[%ARG_BE_VERSION%]!" NEQ "" (
    SET /a jresplmntminval=!VALID_JRESPLMNT_MAP_MIN[%ARG_BE_VERSION%]:.=! > NUL
)
if "!VALID_JRESPLMNT_MAP_MAX[%ARG_BE_VERSION%]!" NEQ "" (
    SET /a jresplmntmaxval=!VALID_JRESPLMNT_MAP_MAX[%ARG_BE_VERSION%]:.=! > NUL
)

call .\scripts\util.bat :CheckInstallerAndHF !ARG_INSTALLER_LOCATION! !JRESPLMNT_REG! !JRESPLMNT_HF_REG! !DISPLAY_NAME! "!jresplmntminval!" "!jresplmntmaxval!" !ARG_TEMP_FOLDER! ARG_JRESPLMNT_VERSION ARG_JRESPLMNT_HOTFIX
if "!ARG_JRESPLMNT_HOTFIX!" EQU "true" (
    SET ERROR_VAL=true
    SET ARG_JRESPLMNT_HOTFIX=na
)
SET "%5=!ARG_JRESPLMNT_VERSION!" & SET "%6=!ARG_JRESPLMNT_HOTFIX!" & SET "%7=!ERROR_VAL!"
EXIT /B 0
