@echo off

setlocal EnableExtensions EnableDelayedExpansion

REM Initializing variables
set "ARG_JRE_VERSION=na"

set "ARG_BE_HOME=..\..\.."
set "ARG_APP_LOCATION=na"
set "ARG_VERSION=na"
set "ARG_IMAGE_VERSION=na"
set "ARG_DOCKERFILE=Dockerfile_fromtar.win"
set "ARG_GVPROVIDERS=na"

set "TEMP_FOLDER=tmp_%RANDOM%"
set GLOBAL_BE_TAG="com.tibco.be"

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
    call set "ARG_BE_HOME=%%!inCounter!" 
	set "ARG_BE_HOME=!ARG_BE_HOME:"=!"	
  )
  if !currentArg! EQU --be-home (
    set /a inCounter=!counter!+1
    call set "ARG_BE_HOME=%%!inCounter!"
	set "ARG_BE_HOME=!ARG_BE_HOME:"=!"	
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
)

if "!ARG_DOCKERFILE!" EQU "na" set ARG_DOCKERFILE=Dockerfile 

set "MISSING_ARG=-"
REM Validating mandatory arguments
if !ARG_APP_LOCATION! EQU na (
  set "MISSING_ARG=!MISSING_ARG! App Location [-a/--app-location] "
)
if !ARG_IMAGE_VERSION! EQU na (
  set "MISSING_ARG=!MISSING_ARG! Image repo [-r/--repo] "
)

if !MISSING_ARG! NEQ - (
  echo ERROR: Missing mandatory arguments : !MISSING_ARG!
  call :printUsage
  EXIT /B 0
)

REM Checking if the Target directory exists or not
if NOT EXIST !ARG_BE_HOME! (
  echo ERROR: The directory - !ARG_BE_HOME! is not a valid directory. Enter a valid directory and try again.
  EXIT /B 1
)

REM Identify BE version
if NOT EXIST !ARG_BE_HOME!\uninstaller_scripts\post-install.properties (
  echo ERROR: The directory - !ARG_BE_HOME! is not a valid BE_HOME directory.
  EXIT /B 1
)
for /F "tokens=2,2 delims==" %%i in ('findstr /i "beVersion=" !ARG_BE_HOME!\uninstaller_scripts\post-install.properties') do (
    set ARG_VERSION=%%i
)

REM Identify JRE version
for /F "tokens=2,2 delims==" %%i in ('findstr /i "tibco.env.TIB_JAVA_HOME" !ARG_BE_HOME!\bin\be-engine.tra') do (
    for %%f in (%%i) do (
        set ARG_JRE_VERSION=%%~nxf
    )
)

set SHORT_VERSION=!ARG_VERSION:~0,3!

if NOT EXIST !ARG_BE_HOME!/../!SHORT_VERSION! (
  echo ERROR: Specified BE_HOME is not a !SHORT_VERSION! installation.
  EXIT /B 1
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
  echo ERROR: Multiple ear files found at the specified location.
  GOTO END-withError
)

mkdir !TEMP_FOLDER!\lib !TEMP_FOLDER!\gvproviders !TEMP_FOLDER!\app

echo ----------------------------------------------
echo INFO: BE_HOME directory - !ARG_BE_HOME!
echo INFO: BusinessEvents version - !ARG_VERSION!
echo INFO: Ear/Application Location - !ARG_APP_LOCATION!
echo INFO: Image Repo - !ARG_IMAGE_VERSION!
echo INFO: Dockerfile - !ARG_DOCKERFILE!
echo INFO: CDD file name - !CDD_FILE_NAME!
echo INFO: EAR file name - !EAR_FILE_NAME!
echo ----------------------------------------------

echo INFO: Copying packages...

xcopy /Q /C /R /Y ..\lib !TEMP_FOLDER!\lib
xcopy /Q /C /R /Y /E ..\gvproviders !TEMP_FOLDER!\gvproviders
xcopy /Q /C /R /Y !ARG_APP_LOCATION!\* !TEMP_FOLDER!\app

powershell -Command "rm -Recurse -Force '!TEMP_FOLDER!\tibcoHome' -ErrorAction Ignore | out-null"
powershell -Command "rm -Recurse -Force '!TEMP_FOLDER!\tibcoHome.zip' -ErrorAction Ignore | out-null"

:: Copy everything into the temp folder.
powershell -Command "mkdir !TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION! | out-null"
powershell -Command "Copy-Item '!ARG_BE_HOME!\..\..\as' -Destination '!TEMP_FOLDER!\tibcoHome' -Recurse -ErrorAction Ignore | out-null"

powershell -Command "Copy-Item '!ARG_BE_HOME!\..\..\tibcojre64' -Destination '!TEMP_FOLDER!\tibcoHome' -Recurse | out-null"
powershell -Command "Copy-Item '!ARG_BE_HOME!\..\..\be\!SHORT_VERSION!\bin' -Destination '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!' -Recurse | out-null"
  powershell -Command "rm -Recurse -Force '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\logs' -ErrorAction Ignore | out-null"
powershell -Command "Copy-Item '!ARG_BE_HOME!\..\..\be\!SHORT_VERSION!\hotfix' -Destination '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!' -Recurse | out-null"
powershell -Command "Copy-Item '!ARG_BE_HOME!\..\..\be\!SHORT_VERSION!\lib' -Destination '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!' -Recurse | out-null"
powershell -Command "Copy-Item '!ARG_BE_HOME!\..\..\be\!SHORT_VERSION!\mm' -Destination '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!' -Recurse | out-null"

:: Replace user TIBCO_HOME path with container's tra files
powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\be-engine.tra') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\be-engine.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\be-engine.tra'"

echo java.property.be.engine.cluster.as.discover.url=%%AS_DISCOVER_URL%%>>!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\be-engine.tra
echo java.property.be.engine.cluster.as.listen.url=%%AS_LISTEN_URL%%>>!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\be-engine.tra
echo java.property.be.engine.cluster.as.remote.listen.url=%%AS_REMOTE_LISTEN_URL%%>>!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\be-engine.tra
echo java.property.com.sun.management.jmxremote.rmi.port=%%jmx_port%%>>!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\be-engine.tra

mkdir !TEMP_FOLDER!\tibcoHome\be\application
powershell -Command "Copy-Item '..\lib\runbe.bat' -Destination '!TEMP_FOLDER!\tibcoHome\be' | out-null"

echo Generating annotation indexes..
powershell -Command "rm -Recurse -Force '!TEMP_FOLDER!\tibcoHome\be\!SHORT_VERSION!\bin\_annotations.idx' -ErrorAction Ignore | out-null"
cd !TEMP_FOLDER!
set CLASSPATH=tibcoHome\be\!SHORT_VERSION!\lib\*;tibcoHome\be\!SHORT_VERSION!\lib\ext\tpcl\*;tibcoHome\be\!SHORT_VERSION!\lib\ext\tpcl\aws\*;tibcoHome\be\!SHORT_VERSION!\lib\ext\tpcl\gwt\*;tibcoHome\be\!SHORT_VERSION!\lib\ext\tpcl\apache\*;tibcoHome\be\!SHORT_VERSION!\lib\ext\tpcl\emf\*;tibcoHome\be\!SHORT_VERSION!\lib\ext\tpcl\tomsawyer\*;tibcoHome\be\!SHORT_VERSION!\lib\ext\tibco\*;tibcoHome\be\!SHORT_VERSION!\lib\eclipse\plugins\*;tibcoHome\be\!SHORT_VERSION!\rms\lib\*;tibcoHome\be\!SHORT_VERSION!\mm\lib\*;tibcoHome\be\!SHORT_VERSION!\studio\eclipse\plugins\*;tibcoHome\be\!SHORT_VERSION!\lib\eclipse\plugins\*;tibcoHome\be\!SHORT_VERSION!\rms\lib\*;tibcoHome\tibcojre64\!ARG_JRE_VERSION!\lib\*;tibcoHome\tibcojre64\!ARG_JRE_VERSION!\lib\ext\*;tibcoHome\tibcojre64\!ARG_JRE_VERSION!\lib\security\policy\unlimited\*;
tibcoHome\tibcojre64\!ARG_JRE_VERSION!\bin\java -Dtibco.env.BE_HOME=tibcoHome\be\!SHORT_VERSION! -cp %CLASSPATH% com.tibco.be.model.functions.impl.JavaAnnotationLookup
powershell -Command "(Get-Content 'tibcoHome\be\!SHORT_VERSION!\bin\_annotations.idx') -replace @((Resolve-Path tibcoHome).Path -replace '\\', '/'), 'c:/tibco' | Set-Content 'tibcoHome\be\!SHORT_VERSION!\bin\_annotations.idx'"
cd ..

echo INFO: Building docker image for TIBCO BusinessEvents Version: !ARG_VERSION! and Image Repository: !ARG_IMAGE_VERSION! and Docker file: !ARG_DOCKERFILE!
copy !ARG_DOCKERFILE! !TEMP_FOLDER!
docker build -f !TEMP_FOLDER!\!ARG_DOCKERFILE! --build-arg BE_PRODUCT_VERSION="!ARG_VERSION!" --build-arg BE_SHORT_VERSION="!SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg DOCKERFILE_NAME=!ARG_DOCKERFILE! --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! --build-arg GVPROVIDERS="!ARG_GVPROVIDERS!" -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!

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
  echo.
  echo  [-a/--app-location]         :       Location where the application ear, cdd and other files are located [required]
  echo  [-r/--repo]                 :       The app image Repository (example - fdc:latest) [required]
  echo  [-l/--be-home]              :       be-home [optional, default: "../../.." i.e; as run from its default location BE_HOME/cloud/docker/frominstall] [optional]
  echo  [-d/--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile_fromtar.win for windows container, Dockerfile for others) [optional] 
  echo  [--gv-providers]            :       Names of GV providers to be included in the image. Supported value - consul [optional]
  echo  [-h/--help]                 :       Print the usage of script [optional]
  echo  NOTE: Encapsulate all the arguments between double quotes
EXIT /B 0
