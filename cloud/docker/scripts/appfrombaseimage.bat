@rem Copyright (c) 2019-2025. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM input variables
set ARG_APP_LOCATION=%1
set ARG_TAG=%2
set ARG_SOURCE=%3
set ARG_DOCKER_FILE=%4
set TEMP_FOLDER=%5
set ARG_INSTALLERS_PLATFORM=linux

REM Check if ARG_APP_LOCATION is a valid directory
if not exist !ARG_APP_LOCATION! (
    echo ERROR: The directory [!ARG_APP_LOCATION!] is not a valid directory. Enter a valid directory and try again.
    EXIT /B 1
)

REM Count CDD and EAR in app location if exist
if !ARG_APP_LOCATION! NEQ na (
    set CDD_FILE_NAME=na
    for %%f in (!ARG_APP_LOCATION!\*.cdd) do (
        if !CDD_FILE_NAME! NEQ na (
            echo ERROR: The directory: [!ARG_APP_LOCATION!] must have single cdd file.
            GOTO END-withError
        )
        set CDD_FILE_NAME=%%~nxf
    )

    set EAR_FILE_NAME=na
    for %%f in (!ARG_APP_LOCATION!\*.ear) do (
        if !EAR_FILE_NAME! NEQ na (
            echo ERROR: The directory: [!ARG_APP_LOCATION!] must have single EAR file.
            GOTO END-withError
        )
        set EAR_FILE_NAME=%%~nxf
    )

    if !CDD_FILE_NAME! EQU na (
        echo ERROR: No cdd file found at the specified location.
        GOTO END-withError
    )
    
    if !EAR_FILE_NAME! EQU na (
        echo ERROR: No ear file found at the specified location.
        GOTO END-withError
    )
) else (
    echo ERROR: Please provide the application CDD/EAR location.
    EXIT /B 1
)

REM Derive ARG_IMAGE_NAME based on ARG_TAG
if !ARG_TAG! EQU na (
    set ARG_IMAGE_NAME=appfrom!ARG_SOURCE!
) else (
    set ARG_IMAGE_NAME=!ARG_TAG!
)

for /f "tokens=*" %%i in ('docker inspect !ARG_SOURCE! ^| findstr /i "\"Os\" "') do (
    set OS_FIELD=%%i
    set OS_FIELD=!OS_FIELD:,=!
    set OS_FIELD=!OS_FIELD: =!
    set OS_FIELD=!OS_FIELD:"=!
    set OS_FIELD=!OS_FIELD:Os:=!
    if "!OS_FIELD!"=="windows" (
        set ARG_INSTALLERS_PLATFORM=win
    )
)

REM Derive ARG_DOCKER_FILE if not supplied
if !ARG_DOCKER_FILE! EQU na (
    if !ARG_INSTALLERS_PLATFORM! EQU win (
        set ARG_DOCKER_FILE=.\dockerfiles\Dockerfile.BaseImage.win
    ) else (
        set ARG_DOCKER_FILE=.\dockerfiles\Dockerfile.BaseImage
    )
)

REM Display information
echo INFO: Supplied/Derived Data:
echo ------------------------------------------------------------------------------
echo INFO: SOURCE IMAGE                 : [!ARG_SOURCE!]
echo INFO: APPLICATION DATA DIRECTORY   : [!ARG_APP_LOCATION!]
echo INFO: CDD FILE NAME                : [!CDD_FILE_NAME!]
echo INFO: EAR FILE NAME                : [!EAR_FILE_NAME!]
echo INFO: DOCKERFILE                   : [!ARG_DOCKER_FILE!]
echo INFO: IMAGE TAG                    : [!ARG_IMAGE_NAME!]
echo ------------------------------------------------------------------------------

REM Prepare TEMP_FOLDER for building
md "!TEMP_FOLDER!\app"
xcopy "!ARG_APP_LOCATION!\*" "!TEMP_FOLDER!\app" /E /Q
copy "!ARG_DOCKER_FILE!" "!TEMP_FOLDER!"

for %%A in ("!ARG_DOCKER_FILE!") do set ARG_DOCKER_FILE=%%~nxA

set BUILD_ARGS= --build-arg BASE_IMAGE=!ARG_SOURCE! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! -t !ARG_IMAGE_NAME! !TEMP_FOLDER!

REM Execute build command based on ARG_BUILD_TOOL
docker build --force-rm -f "!TEMP_FOLDER!\!ARG_DOCKER_FILE!" !BUILD_ARGS!

REM Check build status
if not "!ERRORLEVEL!" == "0" (
    echo ERROR: Container build failed.
) else (
    echo INFO: Container build successful. Image Name: [!ARG_IMAGE_NAME!].
)

REM Cleanup TEMP_FOLDER
echo INFO: Deleting folder: [!TEMP_FOLDER!].
rd /s /q "!TEMP_FOLDER!"
exit /b 0

:END-withError
    if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!" > NUL
    ENDLOCAL
    echo.
    EXIT /B 1