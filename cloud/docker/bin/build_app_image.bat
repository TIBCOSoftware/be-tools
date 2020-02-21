@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

REM Initializing variables
set "ARG_APP_LOCATION=na"
set "ARG_VERSION=na"
set "ARG_IMAGE_VERSION=na"
set "ARG_DOCKERFILE=na"
set "ARG_GVPROVIDERS=na"
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

REM Identify cdd and ear file names.
set CDD_FILE_NAME=na
for %%f in (!ARG_APP_LOCATION!\*.cdd) do (
  if !CDD_FILE_NAME! NEQ na (
    echo ERROR: Multiple cdd files found at the specified location.
    GOTO END-withError
  )
  set CDD_FILE_NAME=%%~nxf
)
if !CDD_FILE_NAME! EQU na (
  echo ERROR: No cdd file found at the specified location.
  GOTO END-withError
)
set EAR_FILE_NAME=na
for %%f in (!ARG_APP_LOCATION!\*.ear) do (
  if !EAR_FILE_NAME! NEQ na (
    echo ERROR: Multiple ear files found at the specified location.
    GOTO END-withError
  )
  set EAR_FILE_NAME=%%~nxf
)
if !EAR_FILE_NAME! EQU na (
  echo ERROR: No ear file found at the specified location.
  GOTO END-withError
)

REM Default Dockerfile depending on platform
if "!ARG_DOCKERFILE!" EQU "na" if "!ARG_INSTALLERS_PLATFORM!" EQU "linux" set ARG_DOCKERFILE=Dockerfile
if "!ARG_DOCKERFILE!" EQU "na" if "!ARG_INSTALLERS_PLATFORM!" EQU "win" set ARG_DOCKERFILE=Dockerfile.win
if "!ARG_DOCKERFILE!" EQU "na" set ARG_DOCKERFILE=Dockerfile.win

set /A RESULT=0
set ARG_JRE_VERSION=na

REM Identify JRE version
for /F "tokens=1,2 delims==" %%a in ('findstr /i "BE_JRE_!ARG_VERSION!" ..\lib\docker_app_be.properties') do (        
		set ARG_BE_JRE_VERSION=%%a
		set ARG_JRE_VERSION=%%b
		echo ARG_JRE_VERSION is set as !ARG_JRE_VERSION!

)



echo ----------------------------------------------
echo INFO: Image Repo - !ARG_IMAGE_VERSION!
echo INFO: Dockerfile - !ARG_DOCKERFILE!
echo INFO: CDD file name - !CDD_FILE_NAME!
echo INFO: EAR file name - !EAR_FILE_NAME!
echo ----------------------------------------------

mkdir !TEMP_FOLDER!\app

set SHORT_VERSION=!ARG_VERSION:~0,3!

echo INFO: Copying packages...

xcopy /Q /C /R /Y /E !ARG_APP_LOCATION!\* !TEMP_FOLDER!\app
xcopy /Q /C /R /Y /E ..\lib\docker_app_be.properties !TEMP_FOLDER!\app
xcopy /Q /C /R /Y /E ..\lib\exclude_path.bat !TEMP_FOLDER!\app


REM Identify Excluded elements
set CURRENT_DIR=%cd%
echo !CURRENT_DIR!
set "EXCLUDE_STRING=na" 
cd !TEMP_FOLDER!\app
jar xvf !EAR_FILE_NAME!
jar xvf "Shared Archive.sar"
cd Channels
for /F "tokens=1,2,3 delims==" %%a in ('findstr /i "DOCKER_CHK_CHANNEL" !CURRENT_DIR!\..\lib\docker_app_be.properties') do (        
		set ARG_1=%%a
		set ARG_2=%%b
		set ARG_3=%%c
		for /F %%i in ('dir /s/b "%%b*.channel"') do (
		
		if "!EXCLUDE_STRING!" NEQ "na" (set EXCLUDE_STRING=!EXCLUDE_STRING!,!SHORT_VERSION!\%%c)
		if "!EXCLUDE_STRING!" EQU "na" (set EXCLUDE_STRING=!SHORT_VERSION!\%%c)
		
	)  
)

cd !CURRENT_DIR!

echo Path to be excluded for this app ... [!EXCLUDE_STRING!]

echo INFO: Building docker image for TIBCO BusinessEvents Version:!ARG_VERSION! and Image Repository:!ARG_IMAGE_VERSION! and Docker file:!ARG_DOCKERFILE!
copy !ARG_DOCKERFILE! !TEMP_FOLDER!
for %%f in (!ARG_DOCKERFILE!) do set ARG_DOCKERFILE=%%~nxf
docker build -f !TEMP_FOLDER!\!ARG_DOCKERFILE! --progress=tty --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg EXCLUDE_STRING="!EXCLUDE_STRING!" --build-arg BE_PRODUCT_VERSION="!ARG_VERSION!" --build-arg BE_SHORT_VERSION="!SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg DOCKERFILE_NAME=!ARG_DOCKERFILE! --build-arg TEMP_FOLDER=!TEMP_FOLDER! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!

if %ERRORLEVEL% NEQ 0 (
  echo "Docker build failed."
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
  echo Usage: build_app_image.bat
  echo  [-l/--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]
  echo  [-a/--app-location]         :       Location where the application ear, cdd and other files are located [required]
  echo  [-r/--repo]                 :       The app image Repository (example - fdc:latest) [required]
  echo  [-d/--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile.win for windows container, Dockerfile for others) [optional]
  echo  [--gv-providers]            :       Names of GV providers to be included in the image. Supported value - consul [optional]
  echo  [-h/--help]                 :       Print the usage of script [optional]
  echo.
  echo  NOTE: Encapsulate all the arguments between double quotes
EXIT /B 0
