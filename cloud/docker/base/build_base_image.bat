@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

REM Initializing variables
set "ARG_INSTALLER_LOCATION=na"
set "TIBCO_BE_BASE_IMAGE_NAME=na"
set "ARG_INSTALLERS_PLATFORM=win"
set /A CUSTOM_COUNTER=0

REM set flag for installation type
set /A INSTALL_TYPE=0

REM Getting argument count
set argCount=0
for %%x in (%*) do set /A argCount+=1
REM Looping over all arguments and assigning variables
set /A counter=0
for /l %%x in (1, 1, %argCount%) do (
  set /A counter=!counter!+1
  call set currentArg=%%!counter!
  
   if !currentArg! EQU -l (
    set /a inCounter=!counter!+1
    call set "ARG_INSTALLER_LOCATION=%%!inCounter!" 
	set "ARG_INSTALLER_LOCATION=!ARG_INSTALLER_LOCATION:"=!"	
  )
  if !currentArg! EQU --installers-location (
    set /a inCounter=!counter!+1
    call set "ARG_INSTALLER_LOCATION=%%!inCounter!"
	set "ARG_INSTALLER_LOCATION=!ARG_INSTALLER_LOCATION:"=!"	
  )
  if !currentArg! EQU -h (
     call :printUsage
     EXIT /B 1
  )
  if !currentArg! EQU --help (
     call :printUsage
     EXIT /B 1
  )

)

REM Identify BE Base tag
for /F "tokens=1,2 delims==" %%a in ('findstr /i "BE_BASE_IAMGE_TAG" ..\lib\docker_app_be.properties') do (        
		set ARG_BE_BASE_VAR=%%a
		set TIBCO_BE_BASE_IMAGE_NAME=%%b
		echo TIBCO_BE_BASE_IMAGE_NAME !TIBCO_BE_BASE_IMAGE_NAME!
)

echo ARG_INSTALLER_LOCATION !ARG_INSTALLER_LOCATION!


REM Setting the BE_version from the installer zip
if NOT EXIST !ARG_INSTALLER_LOCATION!\uninstaller_scripts\post-install.properties (
set /A INSTALL_TYPE=1
for /F "tokens=* USEBACKQ" %%F IN (`dir !ARG_INSTALLER_LOCATION! /b /a-d ^| findstr /R TIB_businessevents-enterprise*`) do (
set BE_INSTALLER_ZIP=%%F
)

REM vaild only if the format of the zip file is TIB_businessevents-enterprise_<version>_*.zip
for /f "tokens=1,2,3 delims=_" %%a in ("!BE_INSTALLER_ZIP!") do (
  set ARG_POS1=%%a
  set ARG_POS2=%%b
  set ARG_VERSION=%%c
)

)

REM Setting the BE_version and installer platform from the installed location
if EXIST !ARG_INSTALLER_LOCATION!\uninstaller_scripts\post-install.properties (
for /F "tokens=2,2 delims==" %%i in ('findstr /i "beVersion=" !ARG_INSTALLER_LOCATION!\uninstaller_scripts\post-install.properties') do (
    set ARG_VERSION=%%i
)
set ARG_INSTALLERS_PLATFORM=win
)

echo Checking base image for BusinessEvents Version !ARG_VERSION! TIBCO BusinessEvents Docker Image Version !TIBCO_BE_BASE_IMAGE_NAME!

REM Checking if base image exists
FOR /F "tokens=* USEBACKQ" %%F IN (`docker images !TIBCO_BE_BASE_IMAGE_NAME!:!ARG_VERSION!`) DO (
echo !CUSTOM_COUNTER! %%F
set /A CUSTOM_COUNTER=!CUSTOM_COUNTER!+1
echo !CUSTOM_COUNTER!
)

REM Building base image
if %CUSTOM_COUNTER%==1 if %INSTALL_TYPE%==0 (
  echo Refer to script build_base_frominstall
  call ../base/build_base_frominstall.bat %*
)
if %CUSTOM_COUNTER%==1 if %INSTALL_TYPE%==1 (
  echo Refer to script build_base_frominstaller
  call ../base/build_base_frominstaller.bat %*
)

REM Identify Installers platform (linux, win)
if %INSTALL_TYPE%==1 (
for %%f in (!ARG_INSTALLER_LOCATION!\*linux*.zip) do (
  set ARG_INSTALLERS_PLATFORM=linux
)
for %%f in (!ARG_INSTALLER_LOCATION!\*win*.zip) do (
  if !ARG_INSTALLERS_PLATFORM! EQU linux (
    echo ERROR: Installers for multiple platforms found at the specified location.
    GOTO END-withError
  )
  set ARG_INSTALLERS_PLATFORM=win
)
)

REM return the parameter values in the format <Parameter1_name>#<Parameter1_value>,<Parameter2_name>#<Parameter2_value>,...
ENDLOCAL& set return_values=ARG_VERSION#%ARG_VERSION%,ARG_INSTALLERS_PLATFORM#%ARG_INSTALLERS_PLATFORM%
