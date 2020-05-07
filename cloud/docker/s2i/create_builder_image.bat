@echo off

setlocal EnableExtensions EnableDelayedExpansion

REM Initializing variables
set "ARG_INSTALLER_LOCATION=na"
set BE_TAG="com.tibco.be"
set S2I_DOCKER_FILE_BASE="bin/Dockerfile"
set S2I_DOCKER_FILE_APP="Dockerfile"
set ARG_DOCKERFILE_NAME="Dockerfile"
set ARG_EDITION="enterprise"
set ARG_VERSION="na"
set ARG_ADDONS="na"
set ARG_INSTALLER_LOCATION="na"
set ARG_BE_HOTFIX="na"
set ARG_AS_HOTFIX="na"
set ARG_JRE_VERSION="na"
set IS_S2I="true"
set ARG_APP_LOCATION="na"
set ARG_IMAGE_VERSION="na"
set ARG_DOCKER_FILE="Dockerfile"
set "TEMP_FOLDER=tmp_%RANDOM%"
set AS_VERSION="na"
set ARG_GVPROVIDERS="na"


for %%x in (%*) do (
 if %%x EQU nos2i (
  set IS_S2I="false"
 )
)

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
  if !currentArg! EQU nos2i (
	set IS_S2I="false"
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
  if !currentArg! EQU --gv-providers (
    set /a inCounter=!counter!+1
    call set "ARG_GVPROVIDERS=%%!inCounter!"
	set "ARG_GVPROVIDERS=!ARG_GVPROVIDERS:"=!"
  )
  if !currentArg! EQU -h (
     call :printUsage
     EXIT /B 1
  )
  if !currentArg! EQU --help (
     call :printUsage
     EXIT /B 1
  )

REM shifting param
shift
)

set "MISSING_ARG=-"
REM Validating mandatory arguments
if !ARG_INSTALLER_LOCATION! EQU na (
  set "MISSING_ARG=!MISSING_ARG! Installer Location[-l/--installers-location] "
)
if !IS_S2I! NEQ "true"  (
if !ARG_APP_LOCATION! EQU na (
  set "MISSING_ARG=!MISSING_ARG! App Location [-a/--app-location] "
)
)
if !IS_S2I! NEQ "true"  (
if !ARG_IMAGE_VERSION! EQU na (
  set "MISSING_ARG=!MISSING_ARG! Image repo [-r/--repo] "
)
)

if !MISSING_ARG! NEQ - (
  echo ERROR: Missing mandatory argument^(s^) : !MISSING_ARG!
  call :printUsage
  GOTO END-withError
)

REM Checking if the specified directories exists or not
if NOT EXIST !ARG_INSTALLER_LOCATION! (
  echo ERROR: The directory - !ARG_INSTALLER_LOCATION! is not a valid directory. Enter a valid directory and try again.
  GOTO END-withError
)
if !IS_S2I! NEQ "true"  (
if NOT EXIST !ARG_APP_LOCATION! (
  echo ERROR: The directory - !ARG_APP_LOCATION! is not a valid directory. Enter a valid directory and try again.
  GOTO END-withError
)
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

REM Default Dockerfile depending on platform
if "!ARG_DOCKERFILE!" EQU "na" if "!ARG_INSTALLERS_PLATFORM!" EQU "linux" set ARG_DOCKERFILE=Dockerfile
if "!ARG_DOCKERFILE!" EQU "na" if "!ARG_INSTALLERS_PLATFORM!" EQU "win" set ARG_DOCKERFILE=Dockerfile.win
if "!ARG_DOCKERFILE!" EQU "na" set ARG_DOCKERFILE=Dockerfile


set /A RESULT=0
set ARG_JRE_VERSION=na
set ARG_AS_VERSION=na

mkdir !TEMP_FOLDER!\installers !TEMP_FOLDER!\lib !TEMP_FOLDER!\gvproviders

REM Performing validation
call ..\lib\be_validate_installers.bat ARG_VERSION !ARG_INSTALLER_LOCATION! !TEMP_FOLDER! true true ARG_HF ARG_ADDONS ARG_AS_VERSION ARG_AS_HF ARG_JRE_VERSION
if %ERRORLEVEL% NEQ 0 (
  echo "Docker build failed."
  GOTO END-withError
)

echo ----------------------------------------------
echo INFO: Installers Location - !ARG_INSTALLER_LOCATION!
echo INFO: Installers Platform - !ARG_INSTALLERS_PLATFORM!
echo INGO: BusinessEvents version - !ARG_VERSION!
echo INFO: BusinessEvents HF - !ARG_HF!
echo INFO: Addons - !ARG_ADDONS!
echo INFO: ActiveSpaces version - !ARG_AS_VERSION!
echo INFO: ActiveSpaces Hf - !ARG_AS_HF!
echo INFO: Image Repo - !ARG_IMAGE_VERSION!
echo INFO: Dockerfile - !ARG_DOCKERFILE!
echo ----------------------------------------------

echo INFO: Copying packages...

set CURRENT_DIR=%cd%

for /F "tokens=*" %%f in (!TEMP_FOLDER!/package_files.txt) do (
  set FILE=%%f
  SET FILE_PATH=!FILE:*#=!
  xcopy /Q /C /R /Y !FILE_PATH! !TEMP_FOLDER!\installers
)

set SHORT_VERSION=!ARG_VERSION:~0,3!
set AS_SHORT_VERSION=!ARG_AS_VERSION:~0,3!
xcopy /Q /C /R /Y /E ..\lib !TEMP_FOLDER!\lib
xcopy /Q /C /R /Y /E ..\gvproviders !TEMP_FOLDER!\gvproviders

echo INFO: Building docker image for TIBCO BusinessEvents Version:!ARG_VERSION! and Image Repository:!ARG_IMAGE_VERSION! and Docker file:!ARG_DOCKERFILE!

if !IS_S2I! EQU "true"  (

cd ../bin
copy !ARG_DOCKERFILE! !CURRENT_DIR!\!TEMP_FOLDER!

cd ../s2i
for %%f in (!ARG_DOCKERFILE!) do set ARG_DOCKERFILE=%%~nxf

mkdir !TEMP_FOLDER!\app
cd !TEMP_FOLDER!\app

type NUL > dummy.txt
cd ../..


docker build -f !TEMP_FOLDER!\!ARG_DOCKERFILE! --build-arg BE_PRODUCT_VERSION="!ARG_VERSION!" --build-arg BE_SHORT_VERSION="!SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_HF!" --build-arg AS_PRODUCT_HOTFIX="!ARG_AS_HF!" --build-arg DOCKERFILE_NAME=!ARG_DOCKERFILE! --build-arg AS_VERSION="!ARG_AS_VERSION!" --build-arg AS_SHORT_VERSION="!AS_SHORT_VERSION!" --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! --build-arg CDD_FILE_NAME=dummy.txt --build-arg EAR_FILE_NAME=dummy.txt --build-arg GVPROVIDERS="!ARG_GVPROVIDERS!" -t "!BE_TAG!":"!ARG_VERSION!"-"!ARG_VERSION!" !TEMP_FOLDER!

if %ERRORLEVEL% NEQ 0 (
  echo "Docker build failed."
  GOTO END-withError
)

REM Remove temporary intermediate images if any.
echo Deleting temporary intermediate image..
for /f "tokens=*" %%i IN ('docker images -q -f "label=be-intermediate-image=true"') do (
  docker rmi %%i
)
echo DONE: Docker build successful

docker build -f !S2I_DOCKER_FILE_APP! --build-arg BE_TAG="!BE_TAG!" --build-arg ARG_VERSION="!ARG_VERSION!" -t "!ARG_IMAGE_VERSION!" .

docker rmi -f "!BE_TAG!":"!ARG_VERSION!"-"!ARG_VERSION!"

:END
if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
EXIT /B 0

:END-withError
if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )
EXIT /B 1

) else (
 call ..\bin\build_app_image.bat %*
)


:printUsage
  if !IS_S2I! EQU "false" (
  echo !USAGE!
) else (
  echo Usage: create_builder_image.bat
)
  echo  [-l/--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]
  if !IS_S2I! EQU "false" (
  echo  [-a/--app-location]         :       Location where the application ear, cdd and other files are located [required]
  echo  [-r/--repo]                 :       The app image Repository [example - fdc:latest] [required]
) else (
  echo  [-r/--repo]                 :       The builder image Repository [example - s2ibuilder:latest] [required]
)
  echo  [-d/--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile.win for windows container, Dockerfile for others) [optional]
  echo  [--gv-providers]            :       Names of GV providers to be included in the image. Supported value - consul [optional]
  echo  [-h/--help]                 :       Print the usage of script [optional]
  echo.
  echo  NOTE: Encapsulate all the arguments between double quotes
EXIT /B 0
