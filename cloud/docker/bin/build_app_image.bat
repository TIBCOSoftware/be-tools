@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

if !IS_S2I! NEQ "false" (
set USAGE="Usage: build_app_image.bat"
call ..\s2i\create_builder_image.bat %* nos2i
) else (

REM Identify cdd and ear file names.
set CDD_FILE_NAME=na

echo ARG_VERSION: !ARG_VERSION!
echo ARG_APP_LOCATION: !ARG_APP_LOCATION!

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

mkdir !TEMP_FOLDER!\app
echo INFO: CDD file name - !CDD_FILE_NAME!
echo INFO: EAR file name - !EAR_FILE_NAME!
xcopy /Q /C /R /Y /E !ARG_APP_LOCATION!\* !TEMP_FOLDER!\app

copy !ARG_DOCKERFILE! !TEMP_FOLDER!
for %%f in (!ARG_DOCKERFILE!) do set ARG_DOCKERFILE=%%~nxf
docker build -f !TEMP_FOLDER!\!ARG_DOCKERFILE! --build-arg BE_PRODUCT_VERSION="!ARG_VERSION!" --build-arg BE_SHORT_VERSION="!SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_HF!" --build-arg AS_PRODUCT_HOTFIX="!ARG_AS_HF!" --build-arg DOCKERFILE_NAME=!ARG_DOCKERFILE! --build-arg AS_VERSION="!ARG_AS_VERSION!" --build-arg AS_SHORT_VERSION="!AS_SHORT_VERSION!" --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! --build-arg GVPROVIDERS="!ARG_GVPROVIDERS!"  --build-arg FTL_VERSION="!ARG_FTL_VERSION!" --build-arg FTL_SHORT_VERSION="!FTL_SHORT_VERSION!" --build-arg FTL_PRODUCT_HOTFIX="!ARG_FTL_HF!"  --build-arg ACTIVESPACES_VERSION="!ARG_ACTIVESPACES_VERSION!" --build-arg ACTIVESPACES_SHORT_VERSION="!ACTIVESPACES_SHORT_VERSION!" --build-arg ACTIVESPACES_PRODUCT_HOTFIX="!ARG_ACTIVESPACES_HF!"  -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!

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

:END
if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
ENDLOCAL
EXIT /B 0

:END-withError
if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
if %ERRORLEVEL% NEQ 0 ( EXIT /B %ERRORLEVEL% )
ENDLOCAL
EXIT /B 1
)
