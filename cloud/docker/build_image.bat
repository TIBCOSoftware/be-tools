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
set "ARG_GVPROVIDER=na"

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

REM parsing arguments
set /A counter=0
for %%x in (%*) do (
    set /A counter=!counter!+1
    call set currentArg=%%!counter!

    if !currentArg! EQU -i (
        shift
        call set "ARG_TYPE=%%!counter!"
        set "ARG_TYPE=!ARG_TYPE:"=!"
    )
    
    if !currentArg! EQU --image-type (
        shift
        call set "ARG_TYPE=%%!counter!"
        set "ARG_TYPE=!ARG_TYPE:"=!"
    )

    if !currentArg! EQU -s (
        shift
        call set "ARG_SOURCE=%%!counter!"
        set "ARG_SOURCE=!ARG_SOURCE:"=!"
    )

    if !currentArg! EQU --source (
        shift
        call set "ARG_SOURCE=%%!counter!"
        set "ARG_SOURCE=!ARG_SOURCE:"=!"
    )

    if !currentArg! EQU -a (
        shift
        call set "ARG_APP_LOCATION=%%!counter!"
        set "ARG_APP_LOCATION=!ARG_APP_LOCATION:"=!"
    )

    if !currentArg! EQU --app-location (
        shift
        call set "ARG_APP_LOCATION=%%!counter!"
        set "ARG_APP_LOCATION=!ARG_APP_LOCATION:"=!"
    )

    if !currentArg! EQU -t (
        shift
        call set "ARG_TAG=%%!counter!"
        set "ARG_TAG=!ARG_TAG:"=!"
    )

    if !currentArg! EQU --tag (
        shift
        call set "ARG_TAG=%%!counter!"
        set "ARG_TAG=!ARG_TAG:"=!"
    )

    if !currentArg! EQU -d (
        shift
        call set "ARG_DOCKER_FILE=%%!counter!"
        set "ARG_DOCKER_FILE=!ARG_DOCKER_FILE:"=!"
    )

    if !currentArg! EQU --docker-file (
        shift
        call set "ARG_DOCKER_FILE=%%!counter!"
        set "ARG_DOCKER_FILE=!ARG_DOCKER_FILE:"=!"
    )

    if !currentArg! EQU --gv-provider (
        shift
        call set "ARG_GVPROVIDER=%%!counter!"
        if "!ARG_GVPROVIDER!" NEQ "" (
            set "ARG_GVPROVIDER=!ARG_GVPROVIDER:"=!"
            set "ARG_GVPROVIDER=!ARG_GVPROVIDER: =!"
        ) else (
            set "ARG_GVPROVIDER=na"
        )
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

    call .\scripts\util.bat :ValidateFTLAndAS !ARG_BE_VERSION! !IMAGE_NAME! !RMS_IMAGE! !VALIDATE_FTL_AS!
    if !IMAGE_NAME! EQU !RMS_IMAGE! (
        SET "TRA_FILE=rms\bin\be-rms.tra"
    ) else (
        SET "TRA_FILE=bin\be-engine.tra"
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

) else (

    mkdir !TEMP_FOLDER!

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

        if !ARG_FTL_VERSION! NEQ na set ARG_FTL_SHORT_VERSION=!ARG_FTL_VERSION:~0,3!
    )
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

if !ARG_GVPROVIDER! NEQ na (
    call .\scripts\util.bat :RemoveDuplicatesAndFormatGVs "!ARG_GVPROVIDER!"
    echo INFO: GV PROVIDER                  : [!ARG_GVPROVIDER!]
)

if !ARG_JRE_VERSION! NEQ na (
    echo INFO: JRE VERSION                  : [!ARG_JRE_VERSION!]
)
echo ------------------------------------------------------------------------------
echo.

REM check be6 or not
set /a BE6VAL=!ARG_BE_VERSION:.=!
if !BE6VAL! GEQ 600 set "BE6=true"
if !BE6VAL! LSS 611 set "LESSTHANBE611=true"

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

if !INSTALLATION_TYPE! EQU fromlocal mkdir !TEMP_FOLDER!

mkdir !TEMP_FOLDER!\installers !TEMP_FOLDER!\app !TEMP_FOLDER!\lib
xcopy /Q /C /R /Y /E .\lib !TEMP_FOLDER!\lib > NUL

if "!IMAGE_NAME!" NEQ "!TEA_IMAGE!" (
    if !ARG_INSTALLERS_PLATFORM! EQU win (
        set "SCRIPT_EXTN=.bat"
    ) else (
        set "SCRIPT_EXTN=.sh"
    )
    mkdir !TEMP_FOLDER!\gvproviders
    xcopy /Q /C /Y .\gvproviders\*!SCRIPT_EXTN! !TEMP_FOLDER!\gvproviders > NUL
    if "!ARG_GVPROVIDER!" EQU "na" (
        set "ARG_GVPROVIDER=na"
    ) else (
        set GVS=!ARG_GVPROVIDER:,= !
        for %%v in (!GVS!) do (
            SET GV=%%v
            if "!GV!" EQU "http" (
                mkdir !TEMP_FOLDER!\gvproviders\!GV!
                xcopy /Q /C /Y .\gvproviders\!GV!\*!SCRIPT_EXTN! !TEMP_FOLDER!\gvproviders\!GV! > NUL
            ) else if "!GV!" EQU "consul" (
                mkdir !TEMP_FOLDER!\gvproviders\!GV!
                xcopy /Q /C /Y .\gvproviders\!GV!\*!SCRIPT_EXTN! !TEMP_FOLDER!\gvproviders\!GV! > NUL
            ) else (
                if EXIST ".\gvproviders\!GV!" (
                    if NOT EXIST ".\gvproviders\!GV!\setup!SCRIPT_EXTN!" (
                        echo ERROR: setup!SCRIPT_EXTN! is required for custom GV provider[!GV!] under the directory - [.\gvproviders\!GV!\]
                        GOTO END-withError
                    ) else if NOT EXIST ".\gvproviders\!GV!\run!SCRIPT_EXTN!" (
                        echo ERROR: run!SCRIPT_EXTN! is required for custom GV provider[!GV!] under the directory - [.\gvproviders\!GV!\]
                        GOTO END-withError
                    ) else (
                        mkdir !TEMP_FOLDER!\gvproviders\!GV!
                        xcopy /Q /C /R /Y /E .\gvproviders\!GV!\* !TEMP_FOLDER!\gvproviders\!GV! > NUL
                    )
                ) else (
                    echo ERROR: GV provider[!GV!] is not supported.
                    GOTO END-withError
                )
            )
        )
        if "!SCRIPT_EXTN!" EQU ".sh" (
            set "ARG_GVPROVIDER=!ARG_GVPROVIDER:custom\=custom/!"
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

if !INSTALLATION_TYPE! EQU frominstallers (
    echo.
    for /F "tokens=*" %%f in (!TEMP_FOLDER!\package_files.txt) do (
        set FILE=%%f
        SET FILE_PATH=!FILE:*#=!
        xcopy /Q /C /R /Y !ARG_INSTALLER_LOCATION!\!FILE_PATH! !TEMP_FOLDER!\installers > NUL
        echo INFO: Copying package: [!FILE_PATH!]
    )
    echo.
) else (
    echo.
    mkdir !TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin

    echo INFO: Adding [be\!ARG_BE_SHORT_VERSION!] to tibcohome.
    powershell -Command "Copy-Item '!BE_HOME!\..\..\tibcojre64' -Destination '!TEMP_FOLDER!\tibcoHome' -Recurse | out-null"
    powershell -Command "Copy-Item '!BE_HOME!\lib' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' -Recurse | out-null"
    powershell -Command "Copy-Item '!BE_HOME!\bin\be-engine.tra','!BE_HOME!\bin\be-engine.exe','!BE_HOME!\bin\dbkeywordmap.xml' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin' -Recurse | out-null"
    
    if exist "!BE_HOME!\bin\cassandrakeywordmap.xml" powershell -Command "Copy-Item '!BE_HOME!\bin\cassandrakeywordmap.xml' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin' -Recurse | out-null"

    REM replace tibco home path
    powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\be-engine.tra') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\be-engine.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\be-engine.tra'"

    if !IMAGE_NAME! EQU !RMS_IMAGE! (
        powershell -Command "Copy-Item '!BE_HOME!\rms','!BE_HOME!\studio','!BE_HOME!\eclipse-platform','!BE_HOME!\mm' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' -Recurse | out-null" > NUL
        powershell -Command "Copy-Item '!BE_HOME!\examples\standard\WebStudio' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\examples\standard\WebStudio' -Recurse | out-null"

        if EXIST "!BE_HOME!\decisionmanager" (
            powershell -Command "Copy-Item '!BE_HOME!\decisionmanager' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!' -Recurse | out-null"
        )

        powershell -Command "rm -Recurse -Force '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\shared\*' -ErrorAction Ignore | out-null"

        :: Replace user TIBCO_HOME path with container's tra files
        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\eclipse-platform\eclipse\dropins\TIBCOBusinessEvents-Studio-plugins.link') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\eclipse-platform\eclipse\dropins\TIBCOBusinessEvents-Studio-plugins.link'"
        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\studio\bin\studio-tools.tra') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\studio\bin\studio-tools.tra'"
        powershell -Command "(Get-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra') -replace @(Select-String -Path '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra' -Pattern '^tibco.env.TIB_HOME').Line.Substring(19), 'c:/tibco' | Set-Content '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin\be-rms.tra'"
        
        rd /S /Q !TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\aws
        if !ARG_APP_LOCATION! NEQ na (
            mkdir !TEMP_FOLDER!\tibcoHome\be\ext
            powershell -Command "Copy-Item '!TEMP_FOLDER!\app\*' -Destination '!TEMP_FOLDER!\tibcoHome\be\ext' -Recurse | out-null"
            powershell -Command "Copy-Item '!TEMP_FOLDER!\app\!CDD_FILE_NAME!' '!TEMP_FOLDER!\app\!EAR_FILE_NAME!' -Destination '!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\bin' -Recurse | out-null"
            del !TEMP_FOLDER!\tibcoHome\be\ext\!CDD_FILE_NAME! !TEMP_FOLDER!\tibcoHome\be\ext\!EAR_FILE_NAME!
        )
    ) else (
        rd /S /Q !TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\tomsawyer
        mkdir !TEMP_FOLDER!\tibcoHome\be\application\ear !TEMP_FOLDER!\tibcoHome\be\ext
        powershell -Command "Copy-Item '!TEMP_FOLDER!\app\*' -Destination '!TEMP_FOLDER!\tibcoHome\be\ext' -Recurse | out-null"
        powershell -Command "Copy-Item '!TEMP_FOLDER!\app\!CDD_FILE_NAME!' -Destination '!TEMP_FOLDER!\tibcoHome\be\application' -Recurse | out-null"
        powershell -Command "Copy-Item '!TEMP_FOLDER!\app\!EAR_FILE_NAME!' -Destination '!TEMP_FOLDER!\tibcoHome\be\application\ear' -Recurse | out-null"
        del !TEMP_FOLDER!\tibcoHome\be\ext\!CDD_FILE_NAME! !TEMP_FOLDER!\tibcoHome\be\ext\!EAR_FILE_NAME!
    )
    
    if exist "!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\eclipse" (
        rd /S /Q "!TEMP_FOLDER!\tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\eclipse" > NUL
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
    set CLASSPATH=tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\aws\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\gwt\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\apache\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\emf\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tpcl\tomsawyer\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\ext\tibco\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\eclipse\plugins\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\lib\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\mm\lib\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\studio\eclipse\plugins\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\lib\eclipse\plugins\*;tibcoHome\be\!ARG_BE_SHORT_VERSION!\rms\lib\*;tibcoHome\ftl\!FTL_VERSION!\lib\*;tibcoHome\as\!ACTIVESPACES_VERSION!\lib\*;tibcoHome\tibcojre64\!ARG_JRE_VERSION!\lib\*;tibcoHome\tibcojre64\!ARG_JRE_VERSION!\lib\ext\*;tibcoHome\tibcojre64\!ARG_JRE_VERSION!\lib\security\policy\unlimited\*;
    tibcoHome\tibcojre64\!ARG_JRE_VERSION!\bin\java -Dtibco.env.BE_HOME=tibcoHome\be\!ARG_BE_SHORT_VERSION! -cp !CLASSPATH! com.tibco.be.model.functions.impl.JavaAnnotationLookup
    if EXIST tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\_annotations.idx (
        powershell -Command "(Get-Content 'tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\_annotations.idx') -replace @((Resolve-Path tibcoHome).Path -replace '\\', '/'), 'c:/tibco' | Set-Content 'tibcoHome\be\!ARG_BE_SHORT_VERSION!\bin\_annotations.idx'"
    )
    cd ..

    powershell -Command "Copy-Item '.\lib\runbe.bat','.\lib\vcredist_install.bat' -Destination '!TEMP_FOLDER!\tibcoHome\be' | out-null"

    powershell -Command "Copy-Item '!TEMP_FOLDER!\gvproviders' -Destination '!TEMP_FOLDER!\tibcoHome\be' -Recurse | out-null"

    rd /S /Q !TEMP_FOLDER!\gvproviders !TEMP_FOLDER!\app !TEMP_FOLDER!\installers 

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
        docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_BE_HOTFIX!" --build-arg DOCKERFILE_NAME=!ARG_DOCKER_FILE! --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
    ) else (
        docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg BE_PRODUCT_ADDONS="!ARG_ADDONS!" --build-arg BE_PRODUCT_HOTFIX="!ARG_BE_HOTFIX!" --build-arg AS_PRODUCT_HOTFIX="!ARG_AS_LEG_HOTFIX!" --build-arg DOCKERFILE_NAME=!ARG_DOCKER_FILE! --build-arg AS_VERSION="!ARG_AS_LEG_VERSION!" --build-arg AS_SHORT_VERSION="!ARG_AS_LEG_SHORT_VERSION!" --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg TEMP_FOLDER=!TEMP_FOLDER! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! --build-arg GVPROVIDER="!ARG_GVPROVIDER!"  --build-arg FTL_VERSION="!ARG_FTL_VERSION!" --build-arg FTL_SHORT_VERSION="!ARG_FTL_SHORT_VERSION!" --build-arg FTL_PRODUCT_HOTFIX="!ARG_FTL_HOTFIX!"  --build-arg ACTIVESPACES_VERSION="!ARG_AS_VERSION!" --build-arg ACTIVESPACES_SHORT_VERSION="!ARG_AS_SHORT_VERSION!" --build-arg ACTIVESPACES_PRODUCT_HOTFIX="!ARG_AS_HOTFIX!"  -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
    )
) else (
    docker build -f !TEMP_FOLDER!\!ARG_DOCKER_FILE! --build-arg BE_PRODUCT_VERSION="!ARG_BE_VERSION!" --build-arg BE_SHORT_VERSION="!ARG_BE_SHORT_VERSION!" --build-arg BE_PRODUCT_IMAGE_VERSION="!ARG_IMAGE_VERSION!" --build-arg DOCKERFILE_NAME=!ARG_DOCKER_FILE! --build-arg JRE_VERSION=!ARG_JRE_VERSION! --build-arg CDD_FILE_NAME=!CDD_FILE_NAME! --build-arg EAR_FILE_NAME=!EAR_FILE_NAME! --build-arg GVPROVIDER="!ARG_GVPROVIDER!" -t "!ARG_IMAGE_VERSION!" !TEMP_FOLDER!
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
    echo  [-i/--image-type]    :    Type of the image to build ("!APP_IMAGE!"^|"!RMS_IMAGE!"^|"!TEA_IMAGE!"^|"!BUILDER_IMAGE!") [required]
    echo                            Note: For "!BUILDER_IMAGE!" image usage refer to be-tools wiki.
    echo.
    echo  [-a/--app-location]  :    Path to BE application where cdd, ear ^& optional supporting jars are present
    echo                            Note: Required if --image-type is "!APP_IMAGE!"
    echo                                  Optional if --image-type is "!RMS_IMAGE!"
    echo                                  Ignored  if --image-type is "!TEA_IMAGE!" or "!BUILDER_IMAGE!"
    echo.
    echo  [-s/--source]        :    Path to BE_HOME or TIBCO installers (BusinessEvents, Activespaces or FTL) are present (default "../../")
    echo.
    echo  [-t/--tag]           :    Name and optionally a tag in the 'name:tag' format [optional]
    echo.
    echo  [-d/--docker-file]   :    Dockerfile to be used for generating image [optional]
    echo.
    echo  [--gv-provider]      :    Name of GV provider to be included in the image ("consul"^|"http"^|"custom") [optional]
    echo                            To add more than one GV use comma separated format ex: "consul,http"
    echo                            Note: This flag is ignored if --image-type is "!TEA_IMAGE!"
    echo.
    echo  [-h/--help]          :    Print the usage of script [optional]
    echo.
    echo  NOTE: Encapsulate all the arguments between double quotes.
    echo.

:END-withError
    if exist !TEMP_FOLDER! rmdir /S /Q "!TEMP_FOLDER!"
    ENDLOCAL
    echo.
    EXIT /B 1
