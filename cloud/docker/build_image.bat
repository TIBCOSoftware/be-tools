@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

REM image type variables
set "IMAGE_NAME="
set "APP_IMAGE=app"
set "RMS_IMAGE=rms"
set "TEA_IMAGE=teagent"
set "BUILDER_IMAGE=s2ibuilder"

set "TEMP_FOLDER=tmp_%RANDOM%"

REM input variables
set "ARG_SOURCE=na"
set "ARG_TYPE=na"
set "ARG_APP_LOCATION=na"
set "ARG_TAG=na"
set "ARG_DOCKER_FILE=na"
set "ARG_GVPROVIDERS=na"

REM be related args
set "BE_HOME=na"
set "ARG_INSTALLER_LOCATION=na"
set "ARG_EDITION=enterprise"
set "ARG_BE_VERSION=na"
set "ARG_BE_SHORT_VERSION=na"
set "ARG_BE_HOTFIX=na"
set "ARG_JRE_VERSION=na"

set "BE_REGX=^.*businessevents-enterprise.*[0-9]\.[0-9]\.[0-9]_.*\.zip$"
set "ARG_INSTALLERS_PLATFORM=win"

REM as legacy related args
set "AS_LEG_HOME=na"
set "ARG_AS_LEG_VERSION=na"
set "ARG_AS_LEG_SHORT_VERSION=na"
set "ARG_AS_LEG_HOTFIX=na"

REM ftl related args
set "FTL_HOME=na"
set "ARG_FTL_VERSION=na"
set "ARG_FTL_SHORT_VERSION=na"
set "ARG_FTL_HOTFIX=na"

REM as related args
set "AS_HOME=na"
set "ARG_AS_VERSION=na"
set "ARG_AS_SHORT_VERSION=na"
set "ARG_AS_HOTFIX=na"

REM s2i builder related args
set "BE_TAG=com.tibco.be"
set "S2I_DOCKER_FILE_APP=.\dockerfiles\Dockerfile-s2i"

REM default installation type fromlocal
set "INSTALLATION_TYPE=fromlocal"

REM Getting argument count
set argCount=0
for %%x in (%*) do set /A argCount+=1

REM Looping over all arguments and assigning variables
set /A counter=0
for /l %%x in (1, 1, %argCount%) do (
    set /A counter=!counter!+1
    call set currentArg=%%!counter!

    if !currentArg! EQU -i (
        set /a inCounter=!counter!+1
        call set "ARG_TYPE=%%!inCounter!"
        set "ARG_TYPE=!ARG_TYPE:"=!"
    )

    if !currentArg! EQU --image-type (
        set /a inCounter=!counter!+1
        call set "ARG_TYPE=%%!inCounter!"
        set "ARG_TYPE=!ARG_TYPE:"=!"
    )

    if !currentArg! EQU -s (
        set /a inCounter=!counter!+1
        call set "ARG_SOURCE=%%!inCounter!"
        set "ARG_SOURCE=!ARG_SOURCE:"=!"
    )

    if !currentArg! EQU --source (
        set /a inCounter=!counter!+1
        call set "ARG_SOURCE=%%!inCounter!"
        set "ARG_SOURCE=!ARG_SOURCE:"=!"
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

    if !currentArg! EQU -t (
        set /a inCounter=!counter!+1
        call set "ARG_TAG=%%!inCounter!"
        set "ARG_TAG=!ARG_TAG:"=!"
    )

    if !currentArg! EQU --tag (
        set /a inCounter=!counter!+1
        call set "ARG_TAG=%%!inCounter!"
        set "ARG_TAG=!ARG_TAG:"=!"
    )

    if !currentArg! EQU -d (
        set /a inCounter=!counter!+1
        call set "ARG_DOCKER_FILE=%%!inCounter!"
        set "ARG_DOCKER_FILE=!ARG_DOCKER_FILE:"=!"
    )

    if !currentArg! EQU --docker-file (
        set /a inCounter=!counter!+1
        call set "ARG_DOCKER_FILE=%%!inCounter!"
        set "ARG_DOCKER_FILE=!ARG_DOCKER_FILE:"=!"
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

REM missing arguments check
set "MISSING_ARGS=-"

if !ARG_TYPE! EQU na (
    set "MISSING_ARGS=Image Type[-i/--image-type]"
)

if !ARG_TYPE! EQU !APP_IMAGE! (
    if !ARG_APP_LOCATION! EQU na (
        set " MISSING_ARGS= App location[-a/--app-location]"
    )
)

echo.
if !MISSING_ARGS! NEQ - (
    echo ERROR: Missing mandatory argument : !MISSING_ARGS!
    call :printUsage
    GOTO END-withError
)

if !ARG_SOURCE! NEQ na (
    REM Checking if the specified directory exists or not
    if NOT EXIST !ARG_SOURCE! (
        echo ERROR: The directory: [!ARG_SOURCE!] is not a valid directory. Provide proper path to be-home or installers location.
        GOTO END-withError
    )
    for /f %%i in ('dir /b !ARG_SOURCE! ^| findstr /I "!BE_REGX!"') do (
        set "INSTALLATION_TYPE=frominstallers"
        set "ARG_INSTALLER_LOCATION=!ARG_SOURCE!"
    )
    if !INSTALLATION_TYPE! NEQ frominstallers (
        set "BE_HOME=!ARG_SOURCE!"
    )
) else (
    set "CURRENT_DIR=!CD!"
    cd ..\..
    set "BE_HOME=!CD!"
    cd !CURRENT_DIR!
)

REM assign image name and check dockerfile specific to it
set "IMAGE_NAME=!ARG_TYPE!"
set "DOCKER_FILE="
if !ARG_TYPE! EQU !APP_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile"
) else if !ARG_TYPE! EQU !RMS_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile-rms"
) else if !ARG_TYPE! EQU !TEA_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile-teagent"
) else if !ARG_TYPE! EQU !BUILDER_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile"
) else (
    echo ERROR: Invalid image type provided. Image type must be either of !APP_IMAGE!,!RMS_IMAGE!,!TEA_IMAGE! or !BUILDER_IMAGE!.
    GOTO END-withError
)

if !ARG_INSTALLER_LOCATION! NEQ na (
    REM Identify Installers platform (linux, win)
    for %%f in (!ARG_INSTALLER_LOCATION!\*linux*.zip) do (
        set "ARG_INSTALLERS_PLATFORM=linux"
    )
    for %%f in (!ARG_INSTALLER_LOCATION!\*win*.zip) do (
        if !ARG_INSTALLERS_PLATFORM! EQU linux (
            echo ERROR: Installers for multiple platforms found at the specified location: [!ARG_INSTALLER_LOCATION!].
            GOTO END-withError
        )
        set "ARG_INSTALLERS_PLATFORM=win"
    )
)

if !ARG_DOCKER_FILE! EQU na (
    if !INSTALLATION_TYPE! EQU fromlocal (
        set "ARG_DOCKER_FILE=!DOCKER_FILE!_fromtar.win"
    ) else (
        set "ARG_DOCKER_FILE=!DOCKER_FILE!"
        if !ARG_INSTALLERS_PLATFORM! EQU win (
            set "ARG_DOCKER_FILE=!DOCKER_FILE!.win"
        )
    )
)

if !INSTALLATION_TYPE! EQU fromlocal (
    REM Identify BE version
    if NOT EXIST !BE_HOME!\uninstaller_scripts\post-install.properties (
        echo "ERROR: Provide proper be home [be/<be-version>] (ex: <path to>/be/5.6). OR Path to installers location."
        GOTO END-withError
    )

    REM image validation
    if !ARG_TYPE! EQU !TEA_IMAGE! (
        echo ERROR: BE TEA agent is not yet supported on Windows containers.
        GOTO END-withError
    )

    if !ARG_TYPE! EQU !BUILDER_IMAGE! (
        echo ERROR:  !BUILDER_IMAGE! is not yet supported on Windows containers.
        GOTO END-withError
    )
)

REM image validation
if !INSTALLATION_TYPE! EQU frominstallers (
    if !ARG_INSTALLERS_PLATFORM! EQU win (
        if !ARG_TYPE! EQU !TEA_IMAGE! (
            echo ERROR: BE TEA agent is not yet supported on Windows containers.
            GOTO END-withError
        )

        if !ARG_TYPE! EQU !BUILDER_IMAGE! (
            echo ERROR:  !BUILDER_IMAGE! is not yet supported on Windows containers.
            GOTO END-withError
        )
    )
)

if NOT EXIST !ARG_DOCKER_FILE! (
    echo ERROR: Dockerfile: [!ARG_DOCKER_FILE!] not exist. Provide proper Dockerfile.
    GOTO END-withError
)

REM check app location
if !IMAGE_NAME! EQU !BUILDER_IMAGE! (
    set "ARG_APP_LOCATION=na"
) else if !IMAGE_NAME! EQU !APP_IMAGE! (
    if NOT EXIST !ARG_APP_LOCATION! (
        echo ERROR: The directory: [!ARG_APP_LOCATION!] is not a valid directory. Enter a valid directory and try again.
        GOTO END-withError
    )
) else if !ARG_APP_LOCATION! NEQ na (
    if NOT EXIST !ARG_APP_LOCATION! (
        echo ERROR: The directory: [!ARG_APP_LOCATION!] is not a valid directory. Ignoring app location.
        set "ARG_APP_LOCATION=na"
    )
)

REM count cdd and ear
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

    if !IMAGE_NAME! EQU !APP_IMAGE! (
        if !CDD_FILE_NAME! EQU na (
            echo ERROR: No cdd file found at the specified location.
            GOTO END-withError
        )
        
        if !EAR_FILE_NAME! EQU na (
            echo ERROR: No ear file found at the specified location.
            GOTO END-withError
        )
    )
)

REM assign image tag to ARG_IMAGE_VERSION variable
set "ARG_IMAGE_VERSION=!ARG_TAG!"

if !INSTALLATION_TYPE! EQU fromlocal (
    REM Identify BE version
    for /F "tokens=2,2 delims==" %%i in ('findstr /i "beVersion=" !BE_HOME!\uninstaller_scripts\post-install.properties') do (
        set ARG_BE_VERSION=%%i
    )
    set "ARG_BE_SHORT_VERSION=!ARG_BE_VERSION:~0,3!"
    if NOT EXIST !BE_HOME!/../!ARG_BE_SHORT_VERSION! (
        echo ERROR: Specified BE_HOME is not a [!ARG_BE_SHORT_VERSION!] installation.
        EXIT /B 1
    )

    REM Identify JRE version
    for /F "tokens=2,2 delims==" %%i in ('findstr /i "tibco.env.TIB_JAVA_HOME" !BE_HOME!\bin\be-engine.tra') do (
        for %%f in (%%i) do (
            set "ARG_JRE_VERSION=%%~nxf"
        )
    )

    REM Check AS_HOME from tra file it is as legacy home
    for /F "tokens=2,2 delims==" %%i in ('findstr /B "tibco.env.AS_HOME=" !BE_HOME!\bin\be-engine.tra') do (
        for %%f in (%%i) do (
            set AS_LEG_HOME=%%~f
            set ARG_AS_LEG_SHORT_VERSION=%%~nxf
        )
    )

    REM Check AS_HOME exist or not if it present
    if !AS_LEG_HOME! NEQ na (
        if NOT EXIST !AS_LEG_HOME! (
            echo "ERROR: The directory: [!AS_LEG_HOME!] is not a valid directory. Skipping activespaces(legacy) installation."
            set "AS_LEG_HOME=na"
        )
    )

    REM Check ACTIVESPACES_HOME from tra file it is as home
    for /F "tokens=2,2 delims==" %%i in ('findstr /B "tibco.env.ACTIVESPACES_HOME=" !BE_HOME!\bin\be-engine.tra') do (
        for %%f in (%%i) do (
            set AS_HOME=%%~f
            set ARG_AS_SHORT_VERSION=%%~nxf
        )
    )

    REM Check AS_HOME exist or not if it present
    if !AS_HOME! NEQ na (
        if NOT EXIST !AS_HOME! (
            echo ERROR: The directory: [!AS_HOME!] is not a valid directory. Skipping as installation.
            set "AS_HOME=na"
        )
    )

    REM Check FTL_HOME from tra file it is ftl home
    for /F "tokens=2,2 delims==" %%i in ('findstr /B "tibco.env.FTL_HOME=" !BE_HOME!\bin\be-engine.tra') do (
        for %%f in (%%i) do (
            set FTL_HOME=%%~f
            set ARG_FTL_SHORT_VERSION=%%~nxf
        )
    )

    REM Check FTL_HOME exist or not if it present
    if !FTL_HOME! NEQ na (
        if NOT EXIST !FTL_HOME! (
            echo ERROR: The directory: [!FTL_HOME!] is not a valid directory. Skipping ftl installation.
            set "FTL_HOME=na"
        )
    )

) else (
    set /A RESULT=0
    set "ARG_ADDONS="
    set "ERROR=0"
    
    mkdir !TEMP_FOLDER!

    REM send image information with ARG_BE_VERSION var
    set "ARG_BE_VERSION=!IMAGE_NAME!"

    REM Performing validation
    call .\scripts\be_validate_installers.bat !ARG_BE_VERSION! !ARG_INSTALLER_LOCATION! !TEMP_FOLDER! true true ARG_BE_HOTFIX ARG_ADDONS ARG_AS_LEG_VERSION ARG_AS_LEG_HOTFIX ARG_JRE_VERSION ARG_FTL_VERSION ARG_FTL_HOTFIX ARG_AS_VERSION ARG_AS_HOTFIX ERROR
    if !ERROR! NEQ 0 (
        echo "Docker build failed."
        GOTO END-withError
    )

    if !ARG_BE_VERSION! NEQ na set ARG_BE_SHORT_VERSION=!ARG_BE_VERSION:~0,3!
    if !ARG_AS_LEG_VERSION! NEQ na set ARG_AS_LEG_SHORT_VERSION=!ARG_AS_LEG_VERSION:~0,3!
    if !ARG_FTL_VERSION! NEQ na set ARG_FTL_SHORT_VERSION=!ARG_FTL_VERSION:~0,3!
    if !ARG_AS_VERSION! NEQ na set ARG_AS_SHORT_VERSION=!ARG_AS_VERSION:~0,3!
)

REM assign image name if not provided
if !ARG_IMAGE_VERSION! EQU na (
    set "ARG_IMAGE_VERSION=!IMAGE_NAME!:!ARG_BE_VERSION!"
)

REM information display
echo INFO: Supplied/Derived Data:
echo ------------------------------------------------------------------------------

if !ARG_INSTALLER_LOCATION! NEQ na (
    echo INFO: INSTALLER DIRECTORY          : [!ARG_INSTALLER_LOCATION!]
)

if !ARG_APP_LOCATION! NEQ na (
    echo INFO: APPLICATION DATA DIRECTORY   : [!ARG_APP_LOCATION!]
)

if !BE_HOME! NEQ na (
    echo INFO: BE HOME                      : [!BE_HOME!]
)

echo INFO: BE VERSION                   : [!ARG_BE_VERSION!]

if !ARG_BE_HOTFIX! NEQ na (
    echo INFO: BE HF                        : [!ARG_BE_HOTFIX!]
)

if "!ARG_ADDONS!" NEQ "" (
    echo INFO: BE ADDONS                    : [!ARG_ADDONS!]
)

if !AS_LEG_HOME! NEQ na (
    echo INFO: AS LEGACY HOME               : [!AS_LEG_HOME!]
)

if !ARG_AS_LEG_VERSION! NEQ na (
    echo INFO: AS LEGACY VERSION            : [!ARG_AS_LEG_VERSION!]
    if !ARG_AS_LEG_HOTFIX! NEQ na (
        echo INFO: AS LEGACY HF                 : [!ARG_AS_LEG_HOTFIX!]
    )
)

if !FTL_HOME! NEQ na (
    echo INFO: FTL HOME                     : [!FTL_HOME!]
)

if !ARG_FTL_VERSION! NEQ na (
    echo INFO: FTL VERSION                  : [!ARG_FTL_VERSION!]
    if !ARG_FTL_HOTFIX! NEQ na (
        echo INFO: FTL HF                       : [!ARG_FTL_HOTFIX!]
    )
)

if !AS_HOME! NEQ na (
    echo INFO: AS HOME                      : [!AS_HOME!]
)

if !ARG_AS_VERSION! NEQ na (
    echo INFO: AS VERSION                   : [!ARG_AS_VERSION!]
    if !ARG_AS_HOTFIX! NEQ na (
        echo INFO: AS HF                        : [!ARG_AS_HOTFIX!]
    )
)

if "!CDD_FILE_NAME!" NEQ "" (
    echo INFO: CDD FILE NAME                : [!CDD_FILE_NAME!]
)

if "!EAR_FILE_NAME!" NEQ "" (
    echo INFO: EAR FILE NAME                : [!EAR_FILE_NAME!]
)

echo INFO: DOCKERFILE                   : [!ARG_DOCKER_FILE!]
echo INFO: IMAGE VERSION                : [!ARG_IMAGE_VERSION!]

if !ARG_JRE_VERSION! NEQ na (
    echo INFO: JRE VERSION                  : [!ARG_JRE_VERSION!]
)
echo ------------------------------------------------------------------------------
echo.

if !IMAGE_NAME! EQU !RMS_IMAGE! if !ARG_AS_LEG_SHORT_VERSION! EQU na (
    echo "ERROR:  TIBCO Activespaces(legacy) Required for RMS."
    GOTO END-withError
)

if !INSTALLATION_TYPE! EQU fromlocal if !FTL_HOME! NEQ na if !AS_LEG_HOME! NEQ na echo "WARN: Local machine contains both FTL and Activespaces(legacy) installations. Removing unused installation improves the docker image size."

if !INSTALLATION_TYPE! EQU fromlocal if !IMAGE_NAME! NEQ !TEA_IMAGE! if !ARG_AS_LEG_SHORT_VERSION! EQU na echo "WARN: TIBCO Activespaces(legacy) will not be installed as AS_HOME not defined in be-engine.tra"

if !INSTALLATION_TYPE! EQU frominstallers if !IMAGE_NAME! NEQ !TEA_IMAGE! if !ARG_AS_LEG_SHORT_VERSION! EQU na echo "WARN: TIBCO Activespaces(legacy) will not be installed as no package found in the installer location."

if !INSTALLATION_TYPE! EQU frominstallers if !ARG_FTL_VERSION! NEQ na if !ARG_AS_LEG_VERSION! NEQ na echo "WARN: The directory: [!ARG_INSTALLER_LOCATION!] contains both FTL and Activespaces(legacy) installers. Removing unused installer improves the docker image size."

if !INSTALLATION_TYPE! EQU fromlocal mkdir !TEMP_FOLDER!

mkdir !TEMP_FOLDER!\installers !TEMP_FOLDER!\app !TEMP_FOLDER!\lib
xcopy /Q /C /R /Y /E .\lib !TEMP_FOLDER!\lib > NUL

set "APP_OR_BUILDER_IMAGE=na"
if !IMAGE_NAME! EQU !APP_IMAGE! set "APP_OR_BUILDER_IMAGE=true"
if !IMAGE_NAME! EQU !BUILDER_IMAGE! set "APP_OR_BUILDER_IMAGE=true"

if !APP_OR_BUILDER_IMAGE! EQU true (
    mkdir !TEMP_FOLDER!\gvproviders
    xcopy /Q /C /R /Y /E .\gvproviders !TEMP_FOLDER!\gvproviders > NUL
)

if !ARG_APP_LOCATION! NEQ na xcopy /Q /C /R /Y /E !ARG_APP_LOCATION!\* !TEMP_FOLDER!\app > NUL

if !IMAGE_NAME! EQU !RMS_IMAGE! if !ARG_APP_LOCATION! EQU na (
    cd !TEMP_FOLDER!\app
    type NUL > dummyrms.txt
    cd ../..
)

if !INSTALLATION_TYPE! EQU frominstallers (
    echo.
    for /F "tokens=*" %%f in (!TEMP_FOLDER!\package_files.txt) do (
        set FILE=%%f
        SET FILE_PATH=!FILE:*#=!
        xcopy /Q /C /R /Y !FILE_PATH! !TEMP_FOLDER!\installers > NUL
        echo INFO: Copying package: [!FILE_PATH!]
    )
    echo.
)

REM Building dockerimage
echo INFO: Building docker image for TIBCO BusinessEvents Version: [!ARG_BE_VERSION!], Image Version: [!ARG_IMAGE_VERSION!] and Dockerfile: [!ARG_DOCKER_FILE!].

REM configurations for s2i image
if !IMAGE_NAME! EQU !BUILDER_IMAGE! (
    type NUL > !TEMP_FOLDER!\app\dummy.txt
    set "EAR_FILE_NAME=dummy.txt"
	set "CDD_FILE_NAME=dummy.txt"
    set "FINAL_BUILDER_IMAGE_TAG=!ARG_IMAGE_VERSION!"
    set "ARG_IMAGE_VERSION=!BE_TAG!:!ARG_BE_VERSION!-!ARG_BE_VERSION!"
    REM copy s2i artifacts
    mkdir !TEMP_FOLDER!\s2i
    xcopy /Q /C /R /Y /E .\s2i  !TEMP_FOLDER!\s2i > NUL
)

copy !ARG_DOCKER_FILE! !TEMP_FOLDER! > NUL
for %%f in (!ARG_DOCKER_FILE!) do set ARG_DOCKER_FILE=%%~nxf

if !INSTALLATION_TYPE! EQU frominstallers (
    if !IMAGE_NAME! EQU !RMS_IMAGE! (
        docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_BE_HOTFIX!" --build-arg AS_PRODUCT_HOTFIX="!ARG_AS_LEG_HOTFIX!" --build-arg DOCKERFILE_NAME=!ARG_DOCKER_FILE! --build-arg AS_VERSION="!ARG_AS_LEG_VERSION!" --build-arg AS_SHORT_VERSION="!ARG_AS_LEG_SHORT_VERSION!" --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
    ) else if !IMAGE_NAME! EQU !TEA_IMAGE! (
        docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_BE_HOTFIX!" --build-arg DOCKERFILE_NAME=!ARG_DOCKER_FILE! --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
    ) else (
        docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_BE_HOTFIX!" --build-arg AS_PRODUCT_HOTFIX="!ARG_AS_LEG_HOTFIX!" --build-arg DOCKERFILE_NAME=!ARG_DOCKER_FILE! --build-arg AS_VERSION="!ARG_AS_LEG_VERSION!" --build-arg AS_SHORT_VERSION="!ARG_AS_LEG_SHORT_VERSION!" --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! --build-arg GVPROVIDERS="!ARG_GVPROVIDERS!"  --build-arg FTL_VERSION="!ARG_FTL_VERSION!" --build-arg FTL_SHORT_VERSION="!ARG_FTL_SHORT_VERSION!" --build-arg FTL_PRODUCT_HOTFIX="!ARG_FTL_HOTFIX!"  --build-arg ACTIVESPACES_VERSION="!ARG_AS_VERSION!" --build-arg ACTIVESPACES_SHORT_VERSION="!ARG_AS_SHORT_VERSION!" --build-arg ACTIVESPACES_PRODUCT_HOTFIX="!ARG_AS_HOTFIX!"  -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
    )
)

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker build failed.
    GOTO END-withError
)

REM Remove temporary intermediate images if any.
if !INSTALLATION_TYPE! EQU frominstallers (
    echo INFO: Deleting temporary intermediate image.
    for /f "tokens=*" %%i IN ('docker images -q -f "label=be-intermediate-image=true"') do (
        docker rmi %%i
    )
)

if !IMAGE_NAME! EQU !BUILDER_IMAGE! (
    docker build -f !S2I_DOCKER_FILE_APP! --build-arg ARG_IMAGE_VERSION="!ARG_IMAGE_VERSION!" -t "!FINAL_BUILDER_IMAGE_TAG!" !TEMP_FOLDER!\s2i
	docker rmi -f "!ARG_IMAGE_VERSION!"
    set "ARG_IMAGE_VERSION=!FINAL_BUILDER_IMAGE_TAG!"
)

echo INFO: Deleting folder: [!TEMP_FOLDER!].
rmdir /S /Q "!TEMP_FOLDER!"

echo INFO: Docker build successful. Image Name: [!ARG_IMAGE_VERSION!].

:END
    if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
    ENDLOCAL

EXIT /B 0

:printUsage
    echo.
    echo Usage: build_image.bat
    echo.
    echo  [-i/--image-type]    :    Type of image. Values must be(!APP_IMAGE!/!RMS_IMAGE!/!TEA_IMAGE!/!BUILDER_IMAGE!). (example: !APP_IMAGE!) [required]
    echo                            Note: !BUILDER_IMAGE! image has prerequisite. Check the documentation in be-tools wiki.
    echo.
    echo  [-a/--app-location]  :    Location where the ear, cdd are located. [required only if -i/--image-type is !APP_IMAGE!]
    echo.
    echo  [-s/--source]        :    Path to be-home or location where installers(TIBCO BusinessEvents, Activespaces, FTL) located. [required for installers]
    echo                            Note: No need to specify be-home if script is executed from BE_HOME\cloud\docker folder.
    echo.
    echo  [-t/--tag]           :    Tag or name of the image. (example: beimage:v1) [optional]
    echo.
    echo  [-d/--docker-file]   :    Dockerfile to be used for generating image. [optional]
    echo.
    echo  [--gv-providers]     :    Names of GV providers to be included in the image. Values must be (consul/http/custom). (example: consul) [optional]
    echo                            Note: Use this flag only if -i/--image-type is !APP_IMAGE!/!BUILDER_IMAGE!.
    echo.
    echo  [-h/--help]          :    Print the usage of script. [optional]
    echo.
    echo  NOTE: Encapsulate all the arguments between double quotes.
    echo.

:END-withError
    if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
    ENDLOCAL
    echo.
    EXIT /B 1