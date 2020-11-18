@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

REM Initializing variables
set "ARG_INSTALLER_LOCATION=na"
set "ARG_VERSION=na"
set "ARG_IMAGE_VERSION=na"
set "ARG_HF=na"
set "ARG_AS_HF=na"
set "ARG_DOCKERFILE=na"
set "TEMP_FOLDER=tmp_%RANDOM%"

REM shift count to handle arg count>10
set /A SHIFT_COUNT=7

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
  if !currentArg! EQU -r (
    set /a inCounter=!counter!+1
    call set "ARG_IMAGE_VERSION=%%!inCounter!"
	set "ARG_IMAGE_VERSION=!ARG_IMAGE_VERSION:"=!"	
  )
  if !currentArg! EQU --repo (
    set /a inCounter=!counter!+1
    call set "ARG_IMAGE_VERSION=%%!inCounter!"
	set "ARG_IMAGE_VERSION=!ARG_IMAGE_VERSION:"=!"
  )
  if !currentArg! EQU -d (
    set /a inCounter=!counter!+1
    call set "ARG_DOCKERFILE=%%!inCounter!" 
	set "ARG_DOCKERFILE=!ARG_DOCKERFILE:"=!"
  )
  if !currentArg! EQU --docker-file (
    set /a inCounter=!counter!+1
    call set "ARG_DOCKERFILE=%%!inCounter!" 
	set "ARG_DOCKERFILE=!ARG_DOCKERFILE:"=!"
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

set "MISSING_ARG=-"
REM Validating mandatory arguments
if !ARG_INSTALLER_LOCATION! EQU na (
  set "MISSING_ARG=!MISSING_ARG! Installer Location[-l/--installers-location] "
)

if !MISSING_ARG! NEQ - (
  echo ERROR: Missing mandatory argument^(s^) : !MISSING_ARG!
  call :printUsage
  GOTO END-withError
)

REM Checking if the specified directory exists or not
if NOT EXIST !ARG_INSTALLER_LOCATION! (
  echo ERROR: The directory - !ARG_INSTALLER_LOCATION! is not a valid directory. Enter a valid directory and try again.
  GOTO END-withError
)

REM Identify Installers platform (linux, win)
set ARG_INSTALLERS_PLATFORM=na
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

if !ARG_INSTALLERS_PLATFORM! EQU win (
  echo ERROR: BE TEA agent is not yet supported on Windows containers.
  GOTO END-withError
)
REM Default Dockerfile depending on platform
if "!ARG_DOCKERFILE!" EQU "na" if "!ARG_INSTALLERS_PLATFORM!" EQU "linux" set ARG_DOCKERFILE=Dockerfile-teagent
if "!ARG_DOCKERFILE!" EQU "na" if "!ARG_INSTALLERS_PLATFORM!" EQU "win" set ARG_DOCKERFILE=Dockerfile-teagent.win
if "!ARG_DOCKERFILE!" EQU "na" set ARG_DOCKERFILE=Dockerfile-teagent

set /A RESULT=0
set ARG_JRE_VERSION=na
set ARG_AS_VERSION=na

mkdir !TEMP_FOLDER!\installers !TEMP_FOLDER!\lib !TEMP_FOLDER!\app

REM Performing validation
call ..\lib\be_validate_installers.bat ARG_VERSION !ARG_INSTALLER_LOCATION! !TEMP_FOLDER! false false ARG_HF ARG_ADDONS ARG_AS_VERSION ARG_AS_HF ARG_JRE_VERSION
if %ERRORLEVEL% NEQ 0 (
  echo "Docker build failed."
  GOTO END-withError
)
if "!ARG_IMAGE_VERSION!" EQU "na" (
  set "ARG_IMAGE_VERSION=teagent:!ARG_VERSION!"
)

echo ----------------------------------------------
echo INFO: Installers Location - !ARG_INSTALLER_LOCATION!
echo INFO: Installers Platform - !ARG_INSTALLERS_PLATFORM!
echo INGO: BusinessEvents version - !ARG_VERSION!
echo INFO: BusinessEvents HF - !ARG_HF!
echo INFO: Image Repo - !ARG_IMAGE_VERSION!
echo INFO: Dockerfile - !ARG_DOCKERFILE!
echo ----------------------------------------------

echo INFO:Copying packages...
for /F "tokens=*" %%f in  (!TEMP_FOLDER!/package_files.txt) do (
  set FILE=%%f
  SET FILE_PATH=!FILE:*#=!
  xcopy /Q /C /R /Y !FILE_PATH! !TEMP_FOLDER!\installers
)

set SHORT_VERSION=!ARG_VERSION:~0,3!
xcopy /Q /C /R /Y ..\lib !TEMP_FOLDER!\lib

echo INFO: Building docker image for TIBCO BusinessEvents Version:!ARG_VERSION! and Image Repository:!ARG_IMAGE_VERSION! and Docker file:!ARG_DOCKERFILE!
docker build -f !ARG_DOCKERFILE! --build-arg BE_PRODUCT_VERSION="!ARG_VERSION!" --build-arg BE_SHORT_VERSION="!SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_HF!" --build-arg DOCKERFILE_NAME=!ARG_DOCKERFILE! --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!

if %ERRORLEVEL% NEQ 0 (
  echo "Docker build failed."
  GOTO END-withError
)

REM Remove temporary intermediate images if any.
echo Deleting temporary intermediate image..
for /f "tokens=*" %%i IN ('docker images -q -f "label=be-intermediate-image=true"') do (
  docker rmi %%i
)
echo DONE: Docker build successful.

:END
if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
ENDLOCAL
EXIT /B 0

:END-withError
if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
ENDLOCAL
if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )
EXIT /B 1

:printUsage 
  echo Usage: build_teagent_image.bat
  echo  [-l/--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]
  echo.
  echo  [-r/--repo]                 :       The teagent image Repository (example - teagent:tag) [optional]
  echo.
  echo  [-d/--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile-teagent) [optional] 
  echo.
  echo  [-h/--help]           	    :       Print the usage of script [optional]
  echo.
  echo  NOTE: Encapsulate all the arguments between double quotes
EXIT /B 0
