@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

REM Initializing variables
set "ARG_APP_LOCATION=na"
set "ARG_VERSION=na"
set "ARG_IMAGE_VERSION=na"
set "ARG_HF=na"
set "ARG_DOCKERFILE=na"
set "ARG_GVPROVIDERS=na"
set "TEMP_FOLDER=tmp_%RANDOM%"
set ARG_INSTALLERS_PLATFORM=win

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
 
 if !currentArg! EQU -a (
    set /a inCounter=!counter!+1
    call set "ARG_APP_LOCATION=%%!inCounter!"
	set "ARG_APP_LOCATION=!ARG_APP_LOCATION:"=!"	
  )
  if !currentArg! EQU --app-location (
    set /a inCounter=!counter!+1
    call set "ARG_APP_LOCATION=%%!inCounter!"
	set "ARG_APP_LOCATION=!ARG_APP_LOCATION:"=!"
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


REM Calling base image script 
call ../base/build_base_image.bat %*


set base_returned_params=%return_values%

REM Setting the result paramaters to its values
for %%a in (%base_returned_params%) do (        
		for /F "tokens=1,2 delims=#" %%b in ("%%a") do (
			set %%b=%%c
			echo Setting %%b to !%%b!
		)

)


REM Default Dockerfile depending on platform
if "!ARG_DOCKERFILE!" EQU "na" if "!ARG_INSTALLERS_PLATFORM!" EQU "linux" set ARG_DOCKERFILE=Dockerfile-rms
if "!ARG_DOCKERFILE!" EQU "na" if "!ARG_INSTALLERS_PLATFORM!" EQU "win" set ARG_DOCKERFILE=Dockerfile-rms.win
if "!ARG_DOCKERFILE!" EQU "na" set ARG_DOCKERFILE=Dockerfile-rms.win

set /A RESULT=0
set ARG_JRE_VERSION=na

mkdir  !TEMP_FOLDER!\app
break>"!TEMP_FOLDER!\app\rms_files"

if "!ARG_IMAGE_VERSION!" EQU "na" (
  set "ARG_IMAGE_VERSION=rms:!ARG_VERSION!"
)

echo ----------------------------------------------
echo INFO: Image Repo - !ARG_IMAGE_VERSION!
echo INFO: Dockerfile - !ARG_DOCKERFILE!
echo INFO: RMS Ear/Cdd Location - !ARG_APP_LOCATION!
echo ----------------------------------------------

echo INFO: Copying packages...

set SHORT_VERSION=!ARG_VERSION:~0,3!

if !ARG_APP_LOCATION! NEQ na (
  xcopy /Q /C /R /Y !ARG_APP_LOCATION!\* !TEMP_FOLDER!\app
)

echo INFO: Building Application docker image for TIBCO BusinessEvents Version:!ARG_VERSION! and Image Repository:!ARG_IMAGE_VERSION! and Docker file:!ARG_DOCKERFILE!
copy !ARG_DOCKERFILE! !TEMP_FOLDER!
for %%f in (!ARG_DOCKERFILE!) do set ARG_DOCKERFILE=%%~nxf
docker build -f !TEMP_FOLDER!\!ARG_DOCKERFILE! --build-arg BE_PRODUCT_VERSION="!ARG_VERSION!" --build-arg BE_SHORT_VERSION="!SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_HF!" --build-arg DOCKERFILE_NAME=!ARG_DOCKERFILE! --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!

if %ERRORLEVEL% NEQ 0 (
  echo Docker build failed.
  GOTO END-withError
)

REM Remove temporary intermediate images if any.
echo Deleting temporary intermediate image..
for /f "tokens=*" %%i IN ('docker images -q -f "label=be-intermediate-image=true"') do (
  docker rmi %%i
)
echo DONE: Docker build successful - '!ARG_IMAGE_VERSION!'

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
  echo Usage: build_rms_image.bat
  echo  [-l/--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]
  echo.
  echo  [-a/--app-location]         :       Location where the RMS ear and cdd files are located [optional]
  echo.
  echo  [-r/--repo]                 :       The RMS image Repository (example - rms:tag) [optional]
  echo.
  echo  [-d/--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile-rms.win for windows container, Dockerfile-rms for others) [optional] 
  echo.
  echo  [-h/--help]                 :       Print the usage of script [optional]
  echo.
  echo  NOTE: Encapsulate all the arguments between double quotes
EXIT /B 0
