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
set "BASE_IMAGE=base"

set "TEMP_FOLDER=tmp_%RANDOM%"

REM input variables
set "ARG_SOURCE=na"
set "ARG_TYPE=na"
set "ARG_APP_LOCATION=na"
set "ARG_TAG=na"
set "ARG_DOCKER_FILE=na"
set "ARG_CONFIGPROVIDER=na"
set "ARG_USE_OPEN_JDK=false"
set "ARG_OPTIMIZE=na"

REM openjdk related vars
set "OPEN_JDK_VERSION=na"
set "OPEN_JDK_FILENAME=na"

REM be related args
set "BE_HOME=na"
set "ARG_INSTALLER_LOCATION=na"
set "ARG_BE_VERSION=na"
set "ARG_BE_SHORT_VERSION=na"
set "ARG_BE_HOTFIX=na"
set "ARG_JRE_VERSION=na"
set "ARG_ADDONS=na"
set "BE6=false"

set "BE_REGX=^.*businessevents-enterprise.*[0-9]\.[0-9]\.[0-9]_.*\.zip$"
set "ARG_INSTALLERS_PLATFORM=win"
set "VALIDATE_FTL_AS=false"

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

REM hawk related args
set "HAWK_HOME=na"
set "ARG_HAWK_VERSION=na"
set "ARG_HAWK_SHORT_VERSION=na"
set "ARG_HAWK_HOTFIX=na"

REM tea related args
set "ARG_TEA_VERSION=na"
set "ARG_TEA_HOTFIX=na"
set "ARG_PYTHON_VERSION=python3"

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

REM JRE SUPPLEMENT  related args
set "ARG_JRESPLMNT_VERSION=na"
set "ARG_JRESPLMNT_SHORT_VERSION=na"
set "ARG_JRESPLMNT_HOTFIX=na"

set "IS_PERL_INSTALLED=false"

REM container image size optimize related vars
perl -e1 2>NUL
if "!errorlevel!" NEQ "0" (
    for /f "delims=" %%i in ('docker info --format {{.OSType}}') do (
        if "%%i" EQU "linux" (
            set "PERL_UTILITY_IMAGE_NAME=be-perl-utility-!TEMP_FOLDER!:v1"
            docker run --name=mytempcontainer-!TEMP_FOLDER! -it docker.io/library/ubuntu:20.04 /bin/bash -c "apt-get update > /dev/null 2>&1 && apt-get install -y unzip > /dev/null 2>&1 && exit" > NUL
            docker commit mytempcontainer-!TEMP_FOLDER! !PERL_UTILITY_IMAGE_NAME! > NUL
            docker rm mytempcontainer-!TEMP_FOLDER! > NUL
            for /f "tokens=*" %%i in ('docker run --rm -v .:/app -w /app !PERL_UTILITY_IMAGE_NAME! perl -e "require \"./lib/be_container_optimize.pl\"; print be_container_optimize::get_all_modules_print_friendly()"') do (
                set "OPTIMIZATION_SUPPORTED_MODULES=%%i"
            )
        )
    )
) else (
    set "IS_PERL_INSTALLED=true"
    for /f "delims=" %%i in ('perl .\lib\be_container_optimize.pl win printfriendly ') do (
        set "OPTIMIZATION_SUPPORTED_MODULES=%%i"
    )
)
set "INCLUDE_MODULES=na"

REM parsing arguments
set /A counter=0
for %%x in (%*) do (
    set "FLAG_CLIKEY=false"
    set /A counter=!counter!+1
    call set currentArg=%%!counter!

    if !currentArg! EQU -i (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_TYPE=%%!counter!"
            set "ARG_TYPE=!ARG_TYPE:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU --image-type (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_TYPE=%%!counter!"
            set "ARG_TYPE=!ARG_TYPE:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU -s (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_SOURCE=%%!counter!"
            set "ARG_SOURCE=!ARG_SOURCE:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU --source (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_SOURCE=%%!counter!"
            set "ARG_SOURCE=!ARG_SOURCE:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU -a (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_APP_LOCATION=%%!counter!"
            set "ARG_APP_LOCATION=!ARG_APP_LOCATION:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU --app-location (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_APP_LOCATION=%%!counter!"
            set "ARG_APP_LOCATION=!ARG_APP_LOCATION:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU -t (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_TAG=%%!counter!"
            set "ARG_TAG=!ARG_TAG:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU --tag (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_TAG=%%!counter!"
            set "ARG_TAG=!ARG_TAG:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU -d (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_DOCKER_FILE=%%!counter!"
            set "ARG_DOCKER_FILE=!ARG_DOCKER_FILE:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU --docker-file (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_DOCKER_FILE=%%!counter!"
            set "ARG_DOCKER_FILE=!ARG_DOCKER_FILE:"=!"
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU -o (
        set "ARG_USE_OPEN_JDK=true"
    ) else if !currentArg! EQU --openjdk (
        set "ARG_USE_OPEN_JDK=true"
    ) else if !currentArg! EQU --optimize (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_OPTIMIZE=%%!counter!"
            if "!ARG_OPTIMIZE!" NEQ "" (
                set "ARG_OPTIMIZE=!ARG_OPTIMIZE:"=!"
                set "ARG_OPTIMIZE=!ARG_OPTIMIZE: =!"
            )
        ) else (
            set /A counter=!counter!-1
            set "ARG_OPTIMIZE="
        )
    ) else if !currentArg! EQU --config-provider (
        shift
        call :isCLIKey  %%!counter!  !FLAG_CLIKEY!
        if !FLAG_CLIKEY! EQU false (
            call set "ARG_CONFIGPROVIDER=%%!counter!"
            if "!ARG_CONFIGPROVIDER!" NEQ "" (
                set "ARG_CONFIGPROVIDER=!ARG_CONFIGPROVIDER:"=!"
                set "ARG_CONFIGPROVIDER=!ARG_CONFIGPROVIDER: =!"
            ) else (
                set "ARG_CONFIGPROVIDER=na"
            )
        ) else (
            set /A counter=!counter!-1
        )
    ) else if !currentArg! EQU -h (
        call :printUsage
        call :DEL-dockerimage
        EXIT /B 1
    ) else if !currentArg! EQU --help (
        call :printUsage
        call :DEL-dockerimage
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

set "IMAGE_NAME=!ARG_TYPE!"
if !ARG_SOURCE! NEQ na (
    REM Checking if the specified directory exists or not
    if /i "!IMAGE_NAME!"=="!APP_IMAGE!" (
        REM Check if the Docker image exists locally or try pulling it
        docker image inspect "!ARG_SOURCE!" >nul 2>&1 || docker pull "!ARG_SOURCE!" >nul 2>&1        
        if "!ERRORLEVEL!"=="0" (
            call :DEL-dockerimage
            call scripts\appfrombaseimage.bat !ARG_APP_LOCATION! !ARG_TAG! !ARG_SOURCE! !ARG_DOCKER_FILE! !TEMP_FOLDER!
            EXIT /B "!ERRORLEVEL!"
        )
    )
    if NOT EXIST !ARG_SOURCE! (
        echo ERROR: The directory: [!ARG_SOURCE!] is not a valid directory. Provide proper path to be-home, installers location or valid base image.
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
set "DOCKER_FILE="
if !ARG_TYPE! EQU !APP_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile"
) else if !ARG_TYPE! EQU !RMS_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile-rms"
) else if !ARG_TYPE! EQU !TEA_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile-teagent"
) else if !ARG_TYPE! EQU !BUILDER_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile"
) else if !ARG_TYPE! EQU !BASE_IMAGE! (
    set "DOCKER_FILE=.\dockerfiles\Dockerfile"
) else (
    echo ERROR: Invalid image type provided. Image type must be either of !APP_IMAGE!,!RMS_IMAGE!,!TEA_IMAGE!,!BUILDER_IMAGE! or !BASE_IMAGE!.
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
        echo ERROR: Provide proper be home [be/^<be-version^>] ^(ex: ^<path to^>/be/6.0^). OR Path to installers location.
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
) else if !IMAGE_NAME! EQU !BASE_IMAGE! (
    set "ARG_APP_LOCATION=na"
) else if !IMAGE_NAME! EQU !TEA_IMAGE! (
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

REM check container type
for /f "delims=" %%i in ('docker version --format {{.Server.Os}}') do (
    if "!ARG_INSTALLERS_PLATFORM!" EQU "linux" (
        if "%%i" EQU "windows" (
            echo ERROR: Trying to install linux variant in windows container. Switch docker to linux container and try again.
            GOTO END-withError
        )
    ) else if "!ARG_INSTALLERS_PLATFORM!" EQU "win" (
        if "%%i" EQU "linux" (
            echo ERROR: Trying to install windows variant in linux container. Switch docker to windows container and try again.
            GOTO END-withError
        )
    )
)

mkdir !TEMP_FOLDER!
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

    call .\scripts\util.bat :ValidateFTLAndAS !ARG_BE_VERSION! !IMAGE_NAME! !RMS_IMAGE! !VALIDATE_FTL_AS!
    if !IMAGE_NAME! EQU !RMS_IMAGE! (
        SET "TRA_FILE=rms\bin\be-rms.tra"
    ) else if !IMAGE_NAME! EQU !TEA_IMAGE! (
        SET "TRA_FILE=teagent\bin\be-teagent.tra"
    ) else (
        SET "TRA_FILE=bin\be-engine.tra"
    )

    REM Identify JRE version
    for /F "tokens=2,2 delims==" %%i in ('findstr /i "tibco.env.TIB_JAVA_HOME" !BE_HOME!\!TRA_FILE!') do (
        set TRA_JAVA_HOME=%%i
        for %%f in (%%i) do (
            set "ARG_JRE_VERSION=%%~nxf"
        )
    )
    
    REM Check AS_HOME from tra file it is as legacy home
    for /F "tokens=2,2 delims==" %%i in ('findstr /B "tibco.env.AS_HOME=" !BE_HOME!\!TRA_FILE!') do (
        for %%f in (%%i) do (
            set AS_LEG_HOME=%%~f
            set ARG_AS_LEG_SHORT_VERSION=%%~nxf
        )
    )

    REM Check AS_HOME exist or not if it present
    if !AS_LEG_HOME! NEQ na (
        if NOT EXIST !AS_LEG_HOME! (
            echo ERROR: The directory: [!AS_LEG_HOME!] is not a valid directory. Skipping activespaces^(legacy^) installation.
            set "AS_LEG_HOME=na"
        )
    )

    if !VALIDATE_FTL_AS! EQU true (
        REM Check ACTIVESPACES_HOME from tra file it is as home
        for /F "tokens=2,2 delims==" %%i in ('findstr /B "tibco.env.ACTIVESPACES_HOME=" !BE_HOME!\!TRA_FILE!') do (
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
        for /F "tokens=2,2 delims==" %%i in ('findstr /B "tibco.env.FTL_HOME=" !BE_HOME!\!TRA_FILE!') do (
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
    )

    set /a BE6VAL=!ARG_BE_VERSION:.=!
    if !BE6VAL! GEQ 622 if "!IMAGE_NAME!" EQU "!APP_IMAGE!"   (
        REM Check HAWK_HOME from tra file it is hawk home
        for /F "tokens=2,2 delims==" %%i in ('findstr /B "tibco.env.HAWK_HOME=" !BE_HOME!\!TRA_FILE!') do (
            for %%f in (%%i) do (
                set HAWK_HOME=%%~f
                set ARG_HAWK_SHORT_VERSION=%%~nxf
            )
        )

        REM Check HAWK_HOME exist or not if it present
        if !HAWK_HOME! NEQ na (
            if NOT EXIST !HAWK_HOME! (
                echo ERROR: The directory: [!HAWK_HOME!] is not a valid directory. Skipping hawk installation.
                set "HAWK_HOME=na"
            )
        )
    )

    set "ARG_USE_OPEN_JDK=false"
) else (
    REM Creating an empty file
    break>"!TEMP_FOLDER!/package_files.txt"

    set "ERROR_VAL=false"

    call .\scripts\be.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! ARG_BE_VERSION ARG_BE_HOTFIX ARG_JRE_VERSION ERROR_VAL
    if !ERROR_VAL! EQU true GOTO END-withError

    if "!ARG_BE_VERSION!" EQU "na" (
        echo ERROR: Unable to identify TIBCO BusinessEvents.
        GOTO END-withError
    )
    
    SET ARG_BE_SHORT_VERSION=!ARG_BE_VERSION:~0,3!

    if "!IMAGE_NAME!" NEQ "!TEA_IMAGE!" (
        call .\scripts\asleg.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! !ARG_BE_VERSION! ARG_AS_LEG_VERSION ARG_AS_LEG_HOTFIX ERROR_VAL
        if !ERROR_VAL! EQU true GOTO END-withError

        if !ARG_AS_LEG_VERSION! NEQ na set ARG_AS_LEG_SHORT_VERSION=!ARG_AS_LEG_VERSION:~0,3!

        call .\scripts\util.bat :ValidateFTLAndAS !ARG_BE_VERSION! !IMAGE_NAME! !RMS_IMAGE! !VALIDATE_FTL_AS!
    )

    if "!VALIDATE_FTL_AS!" EQU "true" (
        call .\scripts\beaddons.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! !ARG_BE_VERSION! ARG_ADDONS ERROR_VAL
        if !ERROR_VAL! EQU true GOTO END-withError
        
        call .\scripts\as.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! !ARG_BE_VERSION! ARG_AS_VERSION ARG_AS_HOTFIX ERROR_VAL
        if !ERROR_VAL! EQU true GOTO END-withError

        if !ARG_AS_VERSION! NEQ na set ARG_AS_SHORT_VERSION=!ARG_AS_VERSION:~0,3!

        call .\scripts\ftl.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! !ARG_BE_VERSION! ARG_FTL_VERSION ARG_FTL_HOTFIX ERROR_VAL
        if !ERROR_VAL! EQU true GOTO END-withError

        if !ARG_FTL_VERSION! NEQ na (
            echo !ARG_FTL_VERSION! | findstr /I /r "^[1-9]\.[0-9]\." > NUL && set ARG_FTL_SHORT_VERSION=!ARG_FTL_VERSION:~0,3!
            echo !ARG_FTL_VERSION! | findstr /I /r "^[1-9]\.[0-9][0-9]\." > NUL && set ARG_FTL_SHORT_VERSION=!ARG_FTL_VERSION:~0,4!
        )
    )

    set /a BE6VAL=!ARG_BE_VERSION:.=!
    if !BE6VAL! GEQ 622 if "!IMAGE_NAME!" EQU "!APP_IMAGE!" (
        call .\scripts\hawk.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! !ARG_BE_VERSION! ARG_HAWK_VERSION ARG_HAWK_HOTFIX ERROR_VAL
        if !ERROR_VAL! EQU true GOTO END-withError

        if !ARG_HAWK_VERSION! NEQ na set ARG_HAWK_SHORT_VERSION=!ARG_HAWK_VERSION:~0,3!
    )

    if !BE6VAL! GEQ 630 if "!IMAGE_NAME!" EQU "!TEA_IMAGE!" (
        call .\scripts\tea.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! !ARG_BE_VERSION! ARG_TEA_VERSION ARG_TEA_HOTFIX ERROR_VAL
        if !ERROR_VAL! EQU true GOTO END-withError
        if "!ARG_TEA_VERSION!" EQU "na" (
            echo ERROR: TEA server installer not found in installer location[!ARG_INSTALLER_LOCATION!]
            GOTO END-withError
        )
        set "ARG_PYTHON_VERSION=python2"
    )

    REM check openjdk details
    if "!ARG_USE_OPEN_JDK!" EQU "true" (
        call .\scripts\openjdk.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! !ARG_JRE_VERSION! OPEN_JDK_VERSION OPEN_JDK_FILENAME ERROR_VAL
        if !ERROR_VAL! EQU true GOTO END-withError
        echo OPENJDK#!OPEN_JDK_FILENAME! >> !TEMP_FOLDER!/package_files.txt
    )

    REM check for jre suppliment
    call .\scripts\jresplmnt.bat !ARG_INSTALLER_LOCATION! !ARG_INSTALLERS_PLATFORM! !TEMP_FOLDER! !ARG_BE_VERSION! ARG_JRESPLMNT_VERSION ARG_JRESPLMNT_HOTFIX ERROR_VAL
    if !ERROR_VAL! EQU true GOTO END-withError
)

if "!ARG_USE_OPEN_JDK!" EQU "true" (
    if "!ARG_JRE_VERSION!" NEQ "!OPEN_JDK_VERSION!" (
        echo ERROR: OpenJDK Version [!OPEN_JDK_VERSION!] and BE supported JRE Runtime Version [!ARG_JRE_VERSION!] mismatch
        GOTO END-withError
    )
)

REM assign image name if not provided
if !ARG_IMAGE_VERSION! EQU na (
    set "ARG_IMAGE_VERSION=!IMAGE_NAME!:!ARG_BE_VERSION!"
)

REM check be6 or not
set "BE620P=false"
set /a BE6VAL=!ARG_BE_VERSION:.=!
if !BE6VAL! GEQ 600 set "BE6=true"
if !BE6VAL! LSS 611 set "LESSTHANBE611=true"
if !BE6VAL! GEQ 620 set "BE620P=true"

if "!BE620P!" EQU "true"  if "!IMAGE_NAME!" EQU "!RMS_IMAGE!" (
    set "DEFAULT_RMS_MODULES=as2,as4,ftl,store,ignite,http"
    if "!ARG_OPTIMIZE!" NEQ "na" (
        if "!ARG_OPTIMIZE!" NEQ "" (
            set "ARG_OPTIMIZE=!ARG_OPTIMIZE!,!DEFAULT_RMS_MODULES!"
        ) else (
            set "ARG_OPTIMIZE=!DEFAULT_RMS_MODULES!"
        )
    ) else (
        set "ARG_OPTIMIZE=!DEFAULT_RMS_MODULES!"
    ) 
)

REM checking optimize flag and its validation
if "!ARG_OPTIMIZE!" NEQ "na" (
    if "!ARG_INSTALLERS_PLATFORM!" EQU "win" (
        perl -e1 2>NUL
        if "!errorlevel!" NEQ "0" (
            echo ERROR: Please install perl.
            GOTO END-withError
        )
        if not exist "C:\\Program Files\\7-Zip\\7z.exe" (
            echo ERROR: Please install 7-Zip in path C:\\Program Files\\7-Zip\\7z.exe
            GOTO END-withError
        )
    )
    
    if "!BE620P!" EQU "true" (
        if exist "!ARG_APP_LOCATION!\!CDD_FILE_NAME!" (
            if exist "!ARG_APP_LOCATION!\!EAR_FILE_NAME!" (
                set "CDD_FILE_PATH=!ARG_APP_LOCATION!\!CDD_FILE_NAME!"
                set "EAR_FILE_PATH=!ARG_APP_LOCATION!\!EAR_FILE_NAME!"
            ) else (
                set "CDD_FILE_PATH=na"
                set "EAR_FILE_PATH=na"
            )
        ) else (
            set "CDD_FILE_PATH=na"
            set "EAR_FILE_PATH=na"
        )

        if "!IS_PERL_INSTALLED!" EQU "true" (
            for /f "delims=" %%i in ('perl .\lib\be_container_optimize.pl win readcdd "!ARG_OPTIMIZE!" "!CDD_FILE_PATH!" "!EAR_FILE_PATH!" ') do (
                set "INCLUDE_MODULES=%%i"
            )
        ) else (
            if "!CDD_FILE_PATH!" NEQ "na" (
                mkdir !TEMP_FOLDER!  > NUL 2>&1
                xcopy /Q /C /R /Y /E !CDD_FILE_PATH! !TEMP_FOLDER! > NUL 2>&1
                xcopy /Q /C /R /Y /E !EAR_FILE_PATH! !TEMP_FOLDER! > NUL 2>&1
                for /f "delims=" %%i in ('docker run --rm -v .:/app -w /app !PERL_UTILITY_IMAGE_NAME! perl -e "require \"./lib/be_container_optimize.pl\"; print be_container_optimize::parse_optimize_modules(\"!ARG_OPTIMIZE!\",\"!TEMP_FOLDER!/!CDD_FILE_NAME!\",\"!TEMP_FOLDER!/!EAR_FILE_NAME!\")"') do (
                    set "INCLUDE_MODULES=%%i"
                )
            ) else (
                for /f "delims=" %%i in ('docker run --rm -v .:/app -w /app !PERL_UTILITY_IMAGE_NAME! perl -e "require \"./lib/be_container_optimize.pl\"; print be_container_optimize::parse_optimize_modules(\"!ARG_OPTIMIZE!\",\"na\",\"na\")"') do (
                    set "INCLUDE_MODULES=%%i"
                )
            )
        )
        if "!INCLUDE_MODULES!" EQU "na" (
            set "INCLUDE_MODULES="
        )
    ) else (
        echo WARN: Container optimization is supported only for BE versions 6.2.0 and above. Continuing build without optimization...
    )
)

if "!ARG_JRE_VERSION!" EQU "" (
    echo ERROR: Unsupported be version[!ARG_BE_VERSION!]
    GOTO END-withError
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

if "!ARG_ADDONS!" NEQ "na" (
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

if !HAWK_HOME! NEQ na (
    echo INFO: HAWK HOME                    : [!HAWK_HOME!]
)

if !ARG_HAWK_VERSION! NEQ na (
    echo INFO: HAWK VERSION                 : [!ARG_HAWK_VERSION!]
    if !ARG_HAWK_HOTFIX! NEQ na (
        echo INFO: HAWK HF                      : [!ARG_HAWK_HOTFIX!]
    )
)

if !ARG_TEA_VERSION! NEQ na (
    echo INFO: TEA VERSION                  : [!ARG_TEA_VERSION!]
    if !ARG_TEA_HOTFIX! NEQ na (
        echo INFO: TEA HF                       : [!ARG_TEA_HOTFIX!]
    )
)

if !ARG_JRESPLMNT_VERSION! NEQ na (
    echo INFO: JRESPLMNT VERSION            : [!ARG_JRESPLMNT_VERSION!]
    if !ARG_JRESPLMNT_HOTFIX! NEQ na (
        echo INFO: JRESPLMNT HF                 : [!ARG_JRESPLMNT_HOTFIX!]
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
echo INFO: IMAGE TAG                    : [!ARG_IMAGE_VERSION!]

if !ARG_CONFIGPROVIDER! NEQ na (
    call .\scripts\util.bat :RemoveDuplicatesAndFormatCPs "!ARG_CONFIGPROVIDER!"
    echo INFO: CONFIG PROVIDER              : [!ARG_CONFIGPROVIDER!]
)

if "!OPEN_JDK_VERSION!" NEQ "na" (
    echo INFO: OPEN JDK VERSION             : [!OPEN_JDK_VERSION!]
    if "!OPEN_JDK_FILENAME!" NEQ "na" (
        echo INFO: OPEN JDK FILE NAME           : [!OPEN_JDK_FILENAME!]
    )
) else (
    echo INFO: JRE VERSION                  : [!ARG_JRE_VERSION!]
)

if "!INCLUDE_MODULES!" NEQ "na" (
    echo INFO: CONTAINER OPTIMIZATION       : [Enabled]
    if "!INCLUDE_MODULES!" NEQ "" (
        echo INFO: CONTAINER OPTIMIZING FOR     : [!INCLUDE_MODULES!]
    )
)

echo ------------------------------------------------------------------------------
echo.

if !IMAGE_NAME! EQU !RMS_IMAGE! if !ARG_AS_LEG_SHORT_VERSION! EQU na (
    if "!LESSTHANBE611!" EQU "true" (
        echo ERROR:  TIBCO Activespaces^(legacy^) Required for RMS.
        GOTO END-withError
    )
)

if !INSTALLATION_TYPE! EQU fromlocal if !FTL_HOME! NEQ na if !AS_LEG_HOME! NEQ na echo WARN: Local machine contains both FTL and Activespaces^(legacy^) installations. Removing unused installation improves the docker image size.

if !INSTALLATION_TYPE! EQU fromlocal if "!BE6!" EQU "false" if !ARG_AS_LEG_SHORT_VERSION! EQU na echo WARN: TIBCO Activespaces^(legacy^) will not be installed as AS_HOME not defined in be-engine.tra.

if !INSTALLATION_TYPE! EQU frominstallers if "!BE6!" EQU "false" if !IMAGE_NAME! NEQ !TEA_IMAGE! if !ARG_AS_LEG_SHORT_VERSION! EQU na echo WARN: TIBCO Activespaces^(legacy^) will not be installed as no package found in the installer location.

if !INSTALLATION_TYPE! EQU frominstallers if !ARG_FTL_VERSION! NEQ na if !ARG_AS_LEG_VERSION! NEQ na echo WARN: The directory: [!ARG_INSTALLER_LOCATION!] contains both FTL and Activespaces^(legacy^) installers. Removing unused installer improves the docker image size.

mkdir !TEMP_FOLDER!\installers !TEMP_FOLDER!\app !TEMP_FOLDER!\lib
xcopy /Q /C /R /Y /E .\lib !TEMP_FOLDER!\lib > NUL

if "!IMAGE_NAME!" NEQ "!TEA_IMAGE!" (
    if !ARG_INSTALLERS_PLATFORM! EQU win (
        set "SCRIPT_EXTN=.bat"
    ) else (
        set "SCRIPT_EXTN=.sh"
    )
    mkdir !TEMP_FOLDER!\configproviders
    xcopy /Q /C /Y .\configproviders\*!SCRIPT_EXTN! !TEMP_FOLDER!\configproviders > NUL
    if "!ARG_CONFIGPROVIDER!" EQU "na" (
        set "ARG_CONFIGPROVIDER=na"
    ) else (
        set CPS=!ARG_CONFIGPROVIDER:,= !
        for %%v in (!CPS!) do (
            SET CP=%%v
            if "!CP!" EQU "gvhttp" (
                mkdir !TEMP_FOLDER!\configproviders\!CP!
                xcopy /Q /C /Y .\configproviders\!CP!\*!SCRIPT_EXTN! !TEMP_FOLDER!\configproviders\!CP! > NUL
            ) else if "!CP!" EQU "gvconsul" (
                mkdir !TEMP_FOLDER!\configproviders\!CP!
                xcopy /Q /C /Y .\configproviders\!CP!\*!SCRIPT_EXTN! !TEMP_FOLDER!\configproviders\!CP! > NUL
            ) else if "!CP!" EQU "gvcyberark" (
                mkdir !TEMP_FOLDER!\configproviders\!CP!
                xcopy /Q /C /Y .\configproviders\!CP!\*!SCRIPT_EXTN! !TEMP_FOLDER!\configproviders\!CP! > NUL
            ) else if "!CP!" EQU "cmcncf" (
                mkdir !TEMP_FOLDER!\configproviders\!CP!
                xcopy /Q /C /Y .\configproviders\!CP!\*!SCRIPT_EXTN! !TEMP_FOLDER!\configproviders\!CP! > NUL    
            ) else (
                if EXIST ".\configproviders\!CP!" (
                    if NOT EXIST ".\configproviders\!CP!\setup!SCRIPT_EXTN!" (
                        echo ERROR: setup!SCRIPT_EXTN! is required for custom Config Provider[!CP!] under the directory - [.\configproviders\!CP!\]
                        GOTO END-withError
                    ) else if NOT EXIST ".\configproviders\!CP!\run!SCRIPT_EXTN!" (
                        echo ERROR: run!SCRIPT_EXTN! is required for custom Config Provider[!CP!] under the directory - [.\configproviders\!CP!\]
                        GOTO END-withError
                    ) else (
                        mkdir !TEMP_FOLDER!\configproviders\!CP!
                        xcopy /Q /C /R /Y /E .\configproviders\!CP!\* !TEMP_FOLDER!\configproviders\!CP! > NUL
                    )
                ) else (
                    echo ERROR: Config Provider[!CP!] is not supported.
                    GOTO END-withError
                )
            )
        )
        if "!SCRIPT_EXTN!" EQU ".sh" (
            set "ARG_CONFIGPROVIDER=!ARG_CONFIGPROVIDER:custom\=custom/!"
        )
    )
)

if !ARG_APP_LOCATION! NEQ na xcopy /Q /C /R /Y /E !ARG_APP_LOCATION!\* !TEMP_FOLDER!\app > NUL

if !IMAGE_NAME! EQU !RMS_IMAGE! if !ARG_APP_LOCATION! EQU na (
    set "EAR_FILE_NAME=RMS.ear"
	set "CDD_FILE_NAME=RMS.cdd"
    cd !TEMP_FOLDER!\app
    type NUL > dummyrms.txt
    cd ../..
)

if !IMAGE_NAME! EQU !BASE_IMAGE! (
    echo. > "%TEMP_FOLDER%\app\base.txt"
    set EAR_FILE_NAME=base.txt
    set CDD_FILE_NAME=base.txt
)

set DEL_LIST_FILE_NAME=deletelist.txt
if !IMAGE_NAME! EQU !RMS_IMAGE! (
    set DEL_LIST_FILE_NAME=deletelistrms.txt
)

if "!INCLUDE_MODULES!" NEQ "na" (
    if "!ARG_INSTALLERS_PLATFORM!" EQU "win" (
        if "!INCLUDE_MODULES!" EQU "" (
            set "INCLUDE_MODULES=java"
        ) else (
            set "INCLUDE_MODULES=!INCLUDE_MODULES!,java"
        )
    )
    if "!IS_PERL_INSTALLED!" EQU "true" (
        perl .\lib\be_container_optimize.pl win createfile "!TEMP_FOLDER!\\lib\\!DEL_LIST_FILE_NAME!" "!INCLUDE_MODULES!"
    ) else (
        docker run --rm -v .:/app -w /app !PERL_UTILITY_IMAGE_NAME! perl -e "require \"./lib/be_container_optimize.pl\"; be_container_optimize::prepare_delete_list(\"!INCLUDE_MODULES!\",\"!TEMP_FOLDER!/lib/!DEL_LIST_FILE_NAME!\")"
    )
)

if !INSTALLATION_TYPE! EQU frominstallers (
    if "!ARG_INSTALLERS_PLATFORM!" EQU "win" (
        powershell -Command "(Get-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!') -replace '/', '\' | Set-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!'" > NUL
        powershell -Command "(Get-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!') -replace 'BE_HOME', 'c:\tibco\be\!ARG_BE_SHORT_VERSION!' | Set-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!'" > NUL
        powershell -Command "(Get-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!') -replace 'JAVA_HOME', 'c:\tibco\tibcojre64\!ARG_JRE_VERSION!' | Set-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!'" > NUL
    ) else (
        powershell -Command "(Get-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!') -replace 'BE_HOME', '/opt/tibco/be/!ARG_BE_SHORT_VERSION!' | Set-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!'" > NUL
        powershell -Command "(Get-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!') -replace 'JAVA_HOME', '/opt/tibco/tibcojre64/!ARG_JRE_VERSION!' | Set-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!'" > NUL
    )
    echo.
    for /F "tokens=*" %%f in (!TEMP_FOLDER!\package_files.txt) do (
        set FILE=%%f
        SET FILE_PATH=!FILE:*#=!
        xcopy /Q /C /R /Y !ARG_INSTALLER_LOCATION!\!FILE_PATH! !TEMP_FOLDER!\installers > NUL
        if !ErrorLevel! NEQ 0 (
            echo ERROR: There might be issue with installer file names, Unable to copy installers, Please check the installers location.
            GOTO END-withError
        )
        echo INFO: Copying package: [!FILE_PATH!]
    )
    echo.
) else (
    echo.
    mkdir !TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin

    echo INFO: Adding [be\!ARG_BE_SHORT_VERSION!] to tibcohome.
    powershell -Command "Copy-Item '!BE_HOME!\lib' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' -Recurse | out-null"
    powershell -Command "Copy-Item '!BE_HOME!\bin\be-engine.tra','!BE_HOME!\bin\be-engine.exe','!BE_HOME!\bin\dbkeywordmap.xml' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin' -Recurse | out-null"

    if "!JAVA_HOME_DIR_NAME!" EQU "" set JAVA_HOME_DIR_NAME=java
    
    mkdir !TEMP_FOLDER!\tibcoHome\!JAVA_HOME_DIR_NAME!
    powershell -Command "Copy-Item '!TRA_JAVA_HOME!' -Destination '!TEMP_FOLDER!\tibcoHome\!JAVA_HOME_DIR_NAME!' -Recurse | out-null"
    
    if !IMAGE_NAME! EQU !RMS_IMAGE! (
        if exist "!BE_HOME!\eclipse-platform" powershell -Command "Copy-Item '!BE_HOME!\eclipse-platform' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' -Recurse | out-null" > NUL
        powershell -Command "Copy-Item '!BE_HOME!\rms','!BE_HOME!\studio','!BE_HOME!\mm' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' -Recurse | out-null" > NUL
    )

    powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!') -replace '!TRA_JAVA_HOME!', 'c:/tibco/!JAVA_HOME_DIR_NAME!/!ARG_JRE_VERSION!' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!'"

    if exist "!BE_HOME!\bin\cassandrakeywordmap.xml" powershell -Command "Copy-Item '!BE_HOME!\bin\cassandrakeywordmap.xml' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin' -Recurse | out-null"

    REM replace tibco home path
    powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\be-engine.tra') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\be-engine.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\be-engine.tra'"

    if !IMAGE_NAME! EQU !RMS_IMAGE! (
        powershell -Command "Copy-Item '!BE_HOME!\examples\standard\WebStudio' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\examples\standard\WebStudio' -Recurse | out-null"
        powershell -Command "Copy-Item '!BE_HOME!\pom.xml' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\pom.xml' -Recurse | out-null"
        powershell -Command "Copy-Item '!BE_HOME!\examples\pom.xml' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\examples\pom.xml' -Recurse | out-null"

        if EXIST "!BE_HOME!\decisionmanager" (
            powershell -Command "Copy-Item '!BE_HOME!\decisionmanager' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' -Recurse | out-null"
        )

        powershell -Command "rm -Recurse -Force '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\shared\*' -ErrorAction Ignore | out-null"

        :: Replace user TIBCO_HOME path with container's tra files
        if exist "!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\eclipse-platform" powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\eclipse-platform\eclipse\dropins\TIBCOBusinessEvents-Studio-plugins.link') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\eclipse-platform\eclipse\dropins\TIBCOBusinessEvents-Studio-plugins.link'"
        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\studio\bin\studio-tools.tra') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\studio\bin\studio-tools.tra'"
        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra'"
        
        powershell -Command "Get-ChildItem -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\aws' -exclude guava*.jar | Remove-Item -force"
        if !ARG_APP_LOCATION! NEQ na (
            mkdir !TEMP_FOLDER!\tibcoHome\be\ext
            powershell -Command "Copy-Item '!TEMP_FOLDER!\app\*' -Destination '!TEMP_FOLDER!\tibcoHome\be\ext' -Recurse | out-null"
            powershell -Command "Copy-Item '!TEMP_FOLDER!\app\!CDD_FILE_NAME!','!TEMP_FOLDER!\app\!EAR_FILE_NAME!' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin' -Recurse | out-null"
            del !TEMP_FOLDER!\tibcoHome\be\ext\!CDD_FILE_NAME! !TEMP_FOLDER!\tibcoHome\be\ext\!EAR_FILE_NAME!
        )
    ) else (
        powershell -Command "Get-ChildItem -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\tomsawyer' -exclude xml-*.jar | Remove-Item -force"
        mkdir !TEMP_FOLDER!\tibcoHome\be\application\ear !TEMP_FOLDER!\tibcoHome\be\ext
        powershell -Command "Copy-Item '!TEMP_FOLDER!\app\*' -Destination '!TEMP_FOLDER!\tibcoHome\be\ext' -Recurse | out-null"
        powershell -Command "Copy-Item '!TEMP_FOLDER!\app\!CDD_FILE_NAME!' -Destination '!TEMP_FOLDER!\tibcoHome\be\application' -Recurse | out-null"
        powershell -Command "Copy-Item '!TEMP_FOLDER!\app\!EAR_FILE_NAME!' -Destination '!TEMP_FOLDER!\tibcoHome\be\application\ear' -Recurse | out-null"
        del !TEMP_FOLDER!\tibcoHome\be\ext\!CDD_FILE_NAME! !TEMP_FOLDER!\tibcoHome\be\ext\!EAR_FILE_NAME!
    )
    
    if exist "!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\eclipse" (
        powershell -Command "Get-ChildItem -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\eclipse\plugins\' -exclude *.bpmn*.jar | Remove-Item -force"
    )

    if EXIST !BE_HOME!\hotfix (
        powershell -Command "Copy-Item '!BE_HOME!\hotfix' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' -Recurse | out-null"
    )

    if !AS_LEG_HOME! NEQ na (
        echo INFO: Adding [as\!ARG_AS_LEG_SHORT_VERSION!] to tibcohome.

        mkdir !TEMP_FOLDER!\tibcoHome\as\!ARG_AS_LEG_SHORT_VERSION!\lib
        powershell -Command "Copy-Item '!AS_LEG_HOME!\lib\*.dll','!AS_LEG_HOME!\lib\*.lib','!AS_LEG_HOME!\lib\*.jar' -Destination '!TEMP_FOLDER!\tibcoHome\as\!ARG_AS_LEG_SHORT_VERSION!\lib' -Recurse | out-null"

        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!' -Pattern '^tibco.env.AS_HOME').Line.Substring(18), 'c:/tibco/as/!ARG_AS_LEG_SHORT_VERSION!' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!'"

        echo java.property.be.engine.cluster.as.discover.url=%%AS_DISCOVER_URL%%>> !TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!
        echo java.property.be.engine.cluster.as.listen.url=%%AS_LISTEN_URL%%>> !TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!
        echo java.property.be.engine.cluster.as.remote.listen.url=%%AS_REMOTE_LISTEN_URL%%>> !TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!
    )
    echo java.property.com.sun.management.jmxremote.rmi.port=%%jmx_port%%>> !TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!

    if !FTL_HOME! NEQ na (
        echo INFO: Adding [ftl\!ARG_FTL_SHORT_VERSION!] to tibcohome.

        mkdir !TEMP_FOLDER!\tibcoHome\ftl\!ARG_FTL_SHORT_VERSION!\lib !TEMP_FOLDER!\tibcoHome\ftl\!ARG_FTL_SHORT_VERSION!\bin
        powershell -Command "Copy-Item '!FTL_HOME!\lib\*.dll','!FTL_HOME!\lib\*.jar','!FTL_HOME!\lib\*.lib' -Destination '!TEMP_FOLDER!\tibcoHome\ftl\!ARG_FTL_SHORT_VERSION!\lib' -Recurse | out-null"
        powershell -Command "Copy-Item '!FTL_HOME!\bin\*.dll','!FTL_HOME!\bin\*.jar','!FTL_HOME!\bin\*.lib' -Destination '!TEMP_FOLDER!\tibcoHome\ftl\!ARG_FTL_SHORT_VERSION!\bin' -Recurse | out-null"

        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!' -Pattern '^tibco.env.FTL_HOME').Line.Substring(19), 'c:/tibco/ftl/!ARG_FTL_SHORT_VERSION!' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!'"
    )

    if !HAWK_HOME! NEQ na (
        echo INFO: Adding [hawk\!ARG_HAWK_SHORT_VERSION!] to tibcohome.

        mkdir !TEMP_FOLDER!\tibcoHome\hawk\!ARG_HAWK_SHORT_VERSION!\lib !TEMP_FOLDER!\tibcoHome\hawk\!ARG_HAWK_SHORT_VERSION!\bin
        powershell -Command "Copy-Item '!HAWK_HOME!\lib\*' -Destination '!TEMP_FOLDER!\tibcoHome\hawk\!ARG_HAWK_SHORT_VERSION!\lib' -Recurse | out-null"
        powershell -Command "Copy-Item '!HAWK_HOME!\bin\*.dll','!HAWK_HOME!\bin\*.jar','!HAWK_HOME!\bin\*.lib' -Destination '!TEMP_FOLDER!\tibcoHome\hawk\!ARG_HAWK_SHORT_VERSION!\bin' -Recurse | out-null"

        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!' -Pattern '^tibco.env.HAWK_HOME').Line.Substring(20), 'c:/tibco/hawk/!ARG_HAWK_SHORT_VERSION!' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!'"
    )

    if !AS_HOME! NEQ na (
        echo INFO: Adding [as\!ARG_AS_SHORT_VERSION!] to tibcohome.

        mkdir !TEMP_FOLDER!\tibcoHome\as\!ARG_AS_SHORT_VERSION!\bin !TEMP_FOLDER!\tibcoHome\as\!ARG_AS_SHORT_VERSION!\lib
        powershell -Command "Copy-Item '!AS_HOME!\lib\*.lib','!AS_HOME!\lib\*.jar','!AS_HOME!\lib\*.dll' -Destination '!TEMP_FOLDER!\tibcoHome\as\!ARG_AS_SHORT_VERSION!\lib' -Recurse | out-null"
        powershell -Command "Copy-Item '!AS_HOME!\bin\*.lib','!AS_HOME!\bin\*.jar','!AS_HOME!\bin\*.dll' -Destination '!TEMP_FOLDER!\tibcoHome\as\!ARG_AS_SHORT_VERSION!\bin' -Recurse | out-null"

        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!' -Pattern '^tibco.env.ACTIVESPACES_HOME').Line.Substring(28), 'c:/tibco/as/!ARG_AS_SHORT_VERSION!' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\!TRA_FILE!'"
    )

    echo.
    echo INFO: Generating annotation indexes.
    cd !TEMP_FOLDER!
    set CLASSPATH=tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\aws\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\gwt\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\apache\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\emf\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\tomsawyer\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tibco\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\eclipse\plugins\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\lib\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\mm\lib\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\studio\eclipse\plugins\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\eclipse\plugins\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\lib\*;tibcoHome\ftl\!FTL_VERSION!\lib\*;tibcoHome\as\!ACTIVESPACES_VERSION!\lib\*;tibcoHome\!JAVA_HOME_DIR_NAME!\!ARG_JRE_VERSION!\lib\*;tibcoHome\!JAVA_HOME_DIR_NAME!\!ARG_JRE_VERSION!\lib\ext\*;tibcoHome\!JAVA_HOME_DIR_NAME!\!ARG_JRE_VERSION!\lib\security\policy\unlimited\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\opentelemetry\exporters\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\opentelemetry\*;
    tibcoHome\!JAVA_HOME_DIR_NAME!\!ARG_JRE_VERSION!\bin\java -Dtibco.env.BE_HOME=tibcoHome\be\!ARG_BE_SHORT_VERSION! -cp !CLASSPATH! com.tibco.be.model.functions.impl.JavaAnnotationLookup
    if EXIST tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\_annotations.idx (
        powershell -Command "(Get-Content 'tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\_annotations.idx') -replace @((Resolve-Path tibcoHome).Path -replace '\\', '/'), 'c:/tibco' | Set-Content 'tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\_annotations.idx'"
    )
    cd ..

    powershell -Command "Copy-Item '.\lib\runbe.bat','.\lib\vcredist_install.bat' -Destination '!TEMP_FOLDER!\tibcoHome\be' | out-null"

    powershell -Command "Copy-Item '!TEMP_FOLDER!\configproviders' -Destination '!TEMP_FOLDER!\tibcoHome\be' -Recurse | out-null"

    powershell -Command "(Get-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!') -replace '/', '\' | Set-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!'" > NUL
    powershell -Command "(Get-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!') -replace 'BE_HOME', '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' | Set-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!'" > NUL
    powershell -Command "(Get-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!') -replace 'JAVA_HOME', '!TEMP_FOLDER!\tibcoHome\!JAVA_HOME_DIR_NAME!\!ARG_JRE_VERSION!' | Set-Content '!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!'" > NUL

    for /f %%i in (!TEMP_FOLDER!\lib\!DEL_LIST_FILE_NAME!) do (
        if exist %%i del %%i  /F/S/Q > NUL
    )

    rd /S /Q !TEMP_FOLDER!\configproviders !TEMP_FOLDER!\app !TEMP_FOLDER!\installers 

    echo.
)

REM Building dockerimage
echo INFO: Building docker image.

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
    if !IMAGE_NAME! EQU !TEA_IMAGE! (
        docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg PYTHON_VERSION="!ARG_PYTHON_VERSION!" --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_BE_HOTFIX!"   --build-arg TEA_VERSION="!ARG_TEA_VERSION!" --build-arg TEA_PRODUCT_HOTFIX="!ARG_TEA_HOTFIX!"  --build-arg OPEN_JDK_FILENAME=!OPEN_JDK_FILENAME! --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg JRESPLMNT_VERSION="!ARG_JRESPLMNT_VERSION!" --build-arg JRESPLMNT_PRODUCT_HOTFIX="!ARG_JRESPLMNT_HOTFIX!" -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
    ) else (
        docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_BE_HOTFIX!" --build-arg AS_PRODUCT_HOTFIX="!ARG_AS_LEG_HOTFIX!" --build-arg OPEN_JDK_FILENAME=!OPEN_JDK_FILENAME! --build-arg AS_VERSION="!ARG_AS_LEG_VERSION!" --build-arg AS_SHORT_VERSION="!ARG_AS_LEG_SHORT_VERSION!" --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! --build-arg CONFIGPROVIDER="!ARG_CONFIGPROVIDER!"  --build-arg FTL_VERSION="!ARG_FTL_VERSION!" --build-arg FTL_SHORT_VERSION="!ARG_FTL_SHORT_VERSION!" --build-arg FTL_PRODUCT_HOTFIX="!ARG_FTL_HOTFIX!"  --build-arg HAWK_VERSION="!ARG_HAWK_VERSION!" --build-arg HAWK_SHORT_VERSION="!ARG_HAWK_SHORT_VERSION!" --build-arg HAWK_PRODUCT_HOTFIX="!ARG_HAWK_HOTFIX!"  --build-arg ACTIVESPACES_VERSION="!ARG_AS_VERSION!" --build-arg ACTIVESPACES_SHORT_VERSION="!ARG_AS_SHORT_VERSION!" --build-arg ACTIVESPACES_PRODUCT_HOTFIX="!ARG_AS_HOTFIX!" --build-arg JRESPLMNT_VERSION="!ARG_JRESPLMNT_VERSION!" --build-arg JRESPLMNT_PRODUCT_HOTFIX="!ARG_JRESPLMNT_HOTFIX!" -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
    )
) else (
    docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! --build-arg CONFIGPROVIDER="!ARG_CONFIGPROVIDER!" -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
)

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker build failed.
    GOTO END-withError
)

REM Remove temporary intermediate images if any.
for /f "tokens=*" %%i IN ('docker images -q -f "label=be-intermediate-image=true"') do (
    echo INFO: Deleting temporary intermediate image.
    docker rmi %%i
)

if !IMAGE_NAME! EQU !BUILDER_IMAGE! (
    docker build -f !S2I_DOCKER_FILE_APP! --build-arg ARG_IMAGE_VERSION="!ARG_IMAGE_VERSION!" -t "!FINAL_BUILDER_IMAGE_TAG!" !TEMP_FOLDER!\s2i
	docker rmi -f "!ARG_IMAGE_VERSION!"
    set "ARG_IMAGE_VERSION=!FINAL_BUILDER_IMAGE_TAG!"
)

if "!IS_PERL_INSTALLED!" EQU "false" (
    call :DEL-dockerimage
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
    echo  [-i/--image-type]    :    Type of the image to build ("!APP_IMAGE!"^|"!RMS_IMAGE!"^|"!TEA_IMAGE!"^|"!BUILDER_IMAGE!"^|"!BASE_IMAGE!") [required]
    echo.
    echo  [-a/--app-location]  :    Path to BE application where cdd, ear ^& optional supporting jars are present
    echo                            Note: Required if --image-type is "!APP_IMAGE!"
    echo                                  Optional if --image-type is "!RMS_IMAGE!"
    echo                                  Ignored  if --image-type is "!TEA_IMAGE!","!BUILDER_IMAGE!" or "!BASE_IMAGE!"
    echo.
    echo  [-s/--source]        :    Path to BE_HOME or TIBCO installers (BusinessEvents, Activespaces or FTL) are present (default "../../")
    echo.
    echo  [-t/--tag]           :    Name and optionally a tag in the 'name:tag' format [optional]
    echo.
    echo  [-d/--docker-file]   :    Dockerfile to be used for generating image [optional]
    echo.
    echo  [--config-provider]  :    Name of Config Provider to be included in the image ("gvconsul"^|"gvhttp"^|"gvcyberark"^|"cmcncf"^|"custom") [optional]
    echo                            To add more than one Config Provider use comma separated format ex: "gvconsul,gvhttp"
    echo                            Note: This flag is ignored if --image-type is "!TEA_IMAGE!"
    echo.
    echo  [-o/--openjdk]       :    Uses OpenJDK instead of tibcojre [optional]
    echo                            Note: Place OpenJDK installer archive along with TIBCO installers.
    echo                                  OpenJDK can be downloaded from https://jdk.java.net/java-se-ri/11.
    echo.
    echo  [--optimize]         :    Enables container image size optimization [optional]
    echo                            When CDD/EAR available, most of the modules are identified automatically.
    echo                            Additional module names can be passed as comma separated string. Ex: "process,query,pattern,analytics"
    if "!OPTIMIZATION_SUPPORTED_MODULES!" NEQ "na" (
        echo                            Supported modules: !OPTIMIZATION_SUPPORTED_MODULES!.
    )
    echo.
    echo  [-h/--help]          :    Print the usage of script [optional]
    echo.
    echo  NOTE: Encapsulate all the arguments between double quotes.
    echo.

:END-withError
    if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!" > NUL
    ENDLOCAL
    echo.
    EXIT /B 1

:isCLIKey
    set "KEY_NAME=%~1"
    set "FLAG_CLIKEY=%~2"

    if "!KEY_NAME!" EQU "-i" (
       set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "--image-type" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "-s" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "--source" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "-a" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "--app-location" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "-t" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "--tag" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "-d" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "--docker-file" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "--optimize" (
        set "FLAG_CLIKEY=true"
    ) else if "!KEY_NAME!" EQU "--config-provider" (
        set "FLAG_CLIKEY=true"
    ) else (
        set "FLAG_CLIKEY=false"
    )

    EXIT /B 0

:DEL-dockerimage
    docker image inspect %PERL_UTILITY_IMAGE_NAME% >NUL 2>&1
    if %ERRORLEVEL% EQU 0 (
        docker rmi -f %PERL_UTILITY_IMAGE_NAME% >NUL 2>&1
    )
