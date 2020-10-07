@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

REM Declaring global constants/varibales
::----------------------------------------------------------
::Valid addons
set GLOBAL_VALID_ADDONS[process]=businessevents-process
set GLOBAL_VALID_ADDONS[views]=businessevents-views

::Valid Addon For EDITION
set GLOBAL_VALID_ADDON_EDITION[enterprise]=process views

::Valid AS Version Mapping
set GLOBAL_VALID_AS_MAP[5.6.0]=2.3.0
set GLOBAL_VALID_AS_MAP_MAX[5.6.0]=2.4.0
set GLOBAL_VALID_AS_MAP[5.6.1]=2.3.0
set GLOBAL_VALID_AS_MAP_MAX[5.6.1]=2.4.1
set GLOBAL_VALID_AS_MAP[6.0.0]=2.3.0
set GLOBAL_VALID_AS_MAP_MAX[6.0.0]=2.4.1

::Valid FTL Version Mapping
set GLOBAL_VALID_FTL_MAP[6.0.0]=6.2.0
set GLOBAL_VALID_FTL_MAP_MAX[6.0.0]=6.x.x

::Valid AS3x Version Mapping
set GLOBAL_VALID_ACTIVESPACES_MAP[6.0.0]=4.2.0
set GLOBAL_VALID_ACTIVESPACES_MAP_MAX[6.0.0]=4.x.x

::JRE version
set GLOBAL_JRE_VERSION_MAP[5.6.0]=1.8.0
set GLOBAL_JRE_VERSION_MAP[5.6.1]=11
set GLOBAL_JRE_VERSION_MAP[6.0.0]=11

::REGEX
set GLOBAL_AS_PKG_REGEX=*activespaces*
set GLOBAL_HF_PKG_REGEX=*businessevents-hf*
set GLOBAL_BE_TAG="com.tibco.be"
::----------------------------------------------------------

REM Initializing variables
set ARG_BE_VERSION=na
set ARG_INSTALLER_LOCATION=%~2
set ARG_TEMP_FOLDER=%~3
set VALIDATE_ADDONS=%~4
set VALIDATE_AS=%~5
::(6)ARG_HF (7)ARG_ADDONS (8)ARG_AS_VERSION (9)ARG_AS_HF
set "ARG_ADDONS="
set ARG_HF=na
set ARG_AS_VERSION=na
set ARG_AS_HF=na

set ARG_FTL_VERSION=na
set ARG_FTL_HF=na
set ARG_ACTIVESPACES_VERSION=na
set ARG_ACTIVESPACES_HF=na

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

REM Identify BE version
SET BE_REG="^.*businessevents-enterprise.*[0-9]\.[0-9]\.[0-9]_linux.*\.zip$"
if !ARG_INSTALLERS_PLATFORM! EQU win (
  SET BE_REG=^.*businessevents-enterprise.*[0-9]\.[0-9]\.[0-9]_win.*\.zip$
)
for /f %%i in ('dir /b !ARG_INSTALLER_LOCATION! ^| findstr /I "!BE_REG!"') do (
  if !ARG_BE_VERSION! NEQ na (
    echo ERROR: Multiple BusinessEvents Enterprise installers found at the specified location.
    GOTO END-withError
  )
  set temp=%%i
  set /a ind2 = 0
  set TEMP_PKG_SPLIT_UNDERSCORE=!temp:_= !
  for %%j in (!TEMP_PKG_SPLIT_UNDERSCORE!) do (
	if !ind2! equ 2 (
	  set ARG_BE_VERSION=%%j
	)
	set /a ind2 += 1
  )
)

REM Identify Addons
SET AS_REG="^TIB_businessevents.*_[0-9]\.[0-9]\.[0-9]_linux.*\.zip$"
if !ARG_INSTALLERS_PLATFORM! EQU win (
  SET AS_REG=^TIB_businessevents.*_[0-9]\.[0-9]\.[0-9]_win.*\.zip$
)
for /f %%i in ('dir /b !ARG_INSTALLER_LOCATION! ^| findstr /I "!AS_REG!"') do (
  set temp=%%i
  set /a ind3 = 0
  set TEMP_PKG_SPLIT_UNDERSCORE=!temp:_= !
  for %%j in (!TEMP_PKG_SPLIT_UNDERSCORE!) do (
    if !ind3! equ 1 (
	  set temp2=%%j
	  set /a ind4 = 0
	  set TEMP_PKG_SPLIT_HYPHEN=!temp2:-= !
	  for %%k in (!TEMP_PKG_SPLIT_HYPHEN!) do (
	    if !ind4! equ 1 (
		  if %%k NEQ enterprise (
			set ARG_ADDONS=%%k,!ARG_ADDONS!
		  )
	    )
	    set /a ind4 += 1
      )
	)
	set /a ind3 += 1
  )
)

REM Identify BE HF
for %%i in (!ARG_INSTALLER_LOCATION!\TIB_businessevents-hf_*_HF*.zip) do (
  if !ARG_HF! NEQ na (
    echo ERROR: Multiple BusinessEvents HF found at the specified location.
    GOTO END-withError
  )
  set temp=%%~nxi
  set /a ind3 = 0
  set TEMP_PKG_SPLIT_UNDERSCORE=!temp:_= !
  for %%j in (!TEMP_PKG_SPLIT_UNDERSCORE!) do (
    if !ind3! equ 3 (
	  set temp2=%%j
	  set /a ind4 = 0
	  set TEMP_PKG_SPLIT_HYPHEN=!temp2:-= !
	  for %%k in (!TEMP_PKG_SPLIT_HYPHEN!) do (
	    if !ind4! equ 1 (
	      set ARG_HF=%%k
	    )
	    set /a ind4 += 1
      )
	)
	set /a ind3 += 1
  )
)

REM Identify AS version
SET AS_REG="^.*activespaces.*[0-9]\.[0-9]\.[0-9]_linux.*\.zip$"
if !ARG_INSTALLERS_PLATFORM! EQU win (
  SET AS_REG=^.*activespaces.*[0-9]\.[0-9]\.[0-9]_win.*\.zip$
)
for /f %%i in ('dir /b !ARG_INSTALLER_LOCATION! ^| findstr /I "!AS_REG!"') do (
  if !ARG_AS_VERSION! NEQ na (
    echo ERROR: Multiple ActiveSpaces installers found at the specified location.
    GOTO END-withError
  )
  set temp=%%i
  set /a ind2 = 0
  set TEMP_PKG_SPLIT_UNDERSCORE=!temp:_= !
  for %%j in (!TEMP_PKG_SPLIT_UNDERSCORE!) do (
	if !ind2! equ 2 (
	  set ARG_AS_VERSION=%%j
	)
	set /a ind2 += 1
  )
)

REM Identify AS HF
SET AS_HF_REG="^.*activespaces.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_linux.*\.zip$"
if !ARG_INSTALLERS_PLATFORM! EQU win (
  SET AS_HF_REG=^.*activespaces.*[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_win.*\.zip$
)
for /f %%i in ('dir /b !ARG_INSTALLER_LOCATION! ^| findstr /I "!AS_HF_REG!"') do (
  if !ARG_AS_HF! NEQ na (
    echo ERROR: Multiple ActiveSpaces HF found at the specified location.
    GOTO END-withError
  )
  set temp=%%i
  set /a ind3 = 0
  set TEMP_PKG_SPLIT_UNDERSCORE=!temp:_= !
  for %%j in (!TEMP_PKG_SPLIT_UNDERSCORE!) do (
	if !ind3! equ 3 (
	  
	  set temp2=%%j
	  set /a ind4 = 0   
	  set TEMP_PKG_SPLIT_HYPHEN=!temp2:-= !
	  for %%k in (!TEMP_PKG_SPLIT_HYPHEN!) do (
	    if !ind4! equ 1 (
	      set ARG_AS_HF=%%k
	    )
	    set /a ind4 += 1
      )
	)
	set /a ind3 += 1
  )
)

call :isLess !ARG_BE_VERSION! "6.0.0" IS_LESS
if !IS_LESS! EQU 1 (
  REM Identify ftl version
  call :IdentifyInstaller "ftl" LOCAL_INSTLR_RESULT
  if !LOCAL_INSTLR_RESULT! NEQ na (
    set ARG_FTL_VERSION=!LOCAL_INSTLR_RESULT!
  )
  if !LOCAL_INSTLR_RESULT! EQU multiple (
    GOTO END-withError
  )

  REM Identify activespaces version
  call :IdentifyInstaller "as" LOCAL_INSTLR_RESULT
  if !LOCAL_INSTLR_RESULT! NEQ na (
    set ARG_ACTIVESPACES_VERSION=!LOCAL_INSTLR_RESULT!
  )
  if !LOCAL_INSTLR_RESULT! EQU multiple (
    GOTO END-withError
  )

  REM Identify ftl HF
  call :IdentifyInstallerHf "ftl" LOCAL_INSTLR_RESULT
  if !LOCAL_INSTLR_RESULT! NEQ na (
    set ARG_FTL_HF=!LOCAL_INSTLR_RESULT!
  )
  if !LOCAL_INSTLR_RESULT! EQU multiple (
    GOTO END-withError
  )

  REM Identify activespaces HF
  call :IdentifyInstallerHf "as" LOCAL_INSTLR_RESULT
  if !LOCAL_INSTLR_RESULT! NEQ na (
    set ARG_ACTIVESPACES_HF=!LOCAL_INSTLR_RESULT!
  )
  if !LOCAL_INSTLR_RESULT! EQU multiple (
    GOTO END-withError
  )
)

set /A RESULT=0
set ARG_JRE_VERSION=!GLOBAL_JRE_VERSION_MAP[%ARG_BE_VERSION%]!

if !VALIDATE_ADDONS! NEQ true ( set "ARG_ADDONS=")
if !VALIDATE_AS! NEQ true (
  set "ARG_AS_VERSION=na"
  set "ARG_AS_HF=na"
)

REM Performing validation
call :validate "!ARG_INSTALLER_LOCATION!" "!ARG_BE_VERSION!" "!ARG_ADDONS!" "!ARG_HF!" "!ARG_AS_VERSION!" "!ARG_AS_HF!" RESULT

if "!RESULT: =!" NEQ "0" (
  echo Error Occurred, aborting.
  GOTO END-withError
)

call :isLess !ARG_BE_VERSION! "6.0.0" IS_LESS
if !IS_LESS! EQU 1 (
  REM Performing ftl validation
  if !ARG_FTL_VERSION! NEQ na (
    call :validateFTLorACTIVESPACES "%ARG_BE_VERSION%" "%ARG_FTL_VERSION%" "%ARG_FTL_HF%" "%ARG_INSTALLER_LOCATION%" "ftl" RESULT
    if "!RESULT: =!" NEQ "0" (
      echo Error in validating ftl
      GOTO END-withError
    )
  )

  REM Performing activespaces validation
  if !ARG_ACTIVESPACES_VERSION! NEQ na (
    call :validateFTLorACTIVESPACES "%ARG_BE_VERSION%" "%ARG_ACTIVESPACES_VERSION%" "%ARG_ACTIVESPACES_HF%" "%ARG_INSTALLER_LOCATION%" "as" RESULT
    if "!RESULT: =!" NEQ "0" (
      echo Error in validating activespaces
      GOTO END-withError
    )
  )
)

:END
ENDLOCAL & SET %~1=%ARG_BE_VERSION%& SET %~6=%ARG_HF%& SET %~7=%ARG_ADDONS%& SET %~8=%ARG_AS_VERSION%& SET %~9=%ARG_AS_HF%& SET %~10=%ARG_JRE_VERSION%& SET %~11=%ARG_FTL_VERSION%& SET %~12=%ARG_FTL_HF%& SET %~13=%ARG_ACTIVESPACES_VERSION%& SET %~14=%ARG_ACTIVESPACES_HF%
EXIT /B 0

:END-withError
set "ERROR=1"
( ENDLOCAL & SET %~15=%ERROR% )
EXIT /B %ERROR%

::----------------------------------------------------------------------------------------------------
REM VALIDATION SUBROUTINES
::----------------------------------------------------------------------------------------------------
:validate
  SETLOCAL
  set LOCAL_INSTALLER_LOCATION=%~1
  set LOCAL_VERSION=%~2
  set LOCAL_ADDONS=%~3
  set LOCAL_HF=%~4
  set LOCAL_AS_VERSION=%~5
  set LOCAL_AS_HF=%~6
  set /A LOCAL_RESULT=0
  
  REM Creating an empty file
  break>"!ARG_TEMP_FOLDER!/package_files.txt"
  
  REM Performing naming validation
  call :validateCorrectNaming "!LOCAL_ADDONS!" LOCAL_RESULT
  if !LOCAL_RESULT! NEQ 0 GOTO END-validate

  REM Performing version validation
  call :validateVersion "!LOCAL_VERSION!" LOCAL_RESULT
  if !LOCAL_RESULT! NEQ 0 GOTO END-validate

  REM Performing activespaces validation
  if !LOCAL_AS_VERSION! NEQ na (
    call :validateActivespace !LOCAL_VERSION! !LOCAL_AS_VERSION! !LOCAL_AS_HF! !LOCAL_INSTALLER_LOCATION! LOCAL_RESULT
    if "!LOCAL_RESULT: =!" NEQ "0" GOTO END-validate
  )
  REM Performing base product validation
  call :validateBaseProduct !LOCAL_VERSION! !LOCAL_INSTALLER_LOCATION! LOCAL_RESULT
  if !LOCAL_RESULT! NEQ 0 GOTO END-validate

  REM Performing addon validation
  call :validateAddons !LOCAL_VERSION! "!LOCAL_ADDONS!" !LOCAL_INSTALLER_LOCATION! LOCAL_RESULT
  if !LOCAL_RESULT! NEQ 0 GOTO END-validate
  
  REM Performing validation for Base HF
  call :validateHf "!LOCAL_VERSION!" "!LOCAL_HF!" "!LOCAL_INSTALLER_LOCATION!" LOCAL_RESULT
  if !LOCAL_RESULT! NEQ 0 GOTO END-validate  
  
  :END-validate
  (ENDLOCAL & REM -- RETURNING RESULT
    SET %~7=%LOCAL_RESULT%
  )

EXIT /B %LOCAL_RESULT%


:validateBaseProduct
  SETLOCAL
  set LOCAL_VERSION=%~1 
  set LOCAL_TARGET_DIR=%~2
  set /A LOCAL_RESULT=0
  
  set LOCAL_VERSION=!LOCAL_VERSION: =!
  
  SET /A COUNT=0
  FOR %%A IN (!LOCAL_TARGET_DIR!\*businessevents-enterprise_!LOCAL_VERSION!*.zip) DO SET /A COUNT += 1
  
  if !COUNT! EQU 0 (
    echo ERROR: No package found with version: !LOCAL_VERSION! and platform: !ARG_INSTALLERS_PLATFORM! in the installer location.
	set /A LOCAL_RESULT=1
	GOTO END-validateBaseProduct
  )
  if !COUNT! GTR 1 (
    echo ERROR: More than one base products are present in the installer location. There should be only one.
	set /A LOCAL_RESULT=1
	GOTO END-validateBaseProduct
  )
  
  for %%f in (!LOCAL_TARGET_DIR!\*businessevents-enterprise_!LOCAL_VERSION!*.zip) do (
    echo BE_PKG#%%f>>!ARG_TEMP_FOLDER!/package_files.txt
  )
  
  :END-validateBaseProduct
  (ENDLOCAL & REM -- RETURNING RESULT
   SET %~3=%LOCAL_RESULT%
  )
EXIT /B %LOCAL_RESULT%

:validateHf 
  SETLOCAL
  set LOCAL_VERSION=%~1 
  set LOCAL_HF=%~2
  set LOCAL_TARGET_DIR=%~3
  set /A LOCAL_RESULT=0
  
  set LOCAL_BASE_HF=!LOCAL_HF: =!
  
  if "!LOCAL_BASE_HF!" EQU "na" GOTO END-validateHf
  
  set LOCAL_VERSION=!LOCAL_VERSION: =!
  
  set /A HF_LEN=0  
  call :strLen LOCAL_BASE_HF HF_LEN
  
  if  !HF_LEN! EQU 0 (
      echo ERROR: Invalid value for base HF : !LOCAL_HF!
	  set /A LOCAL_RESULT=1
	  GOTO END-validateHf
  )
  
  if  !HF_LEN! GTR 3 (
      echo ERROR: Invalid value for base HF : !LOCAL_HF!
	  set /A LOCAL_RESULT=1
	  GOTO END-validateHf
  )
  
  if  !HF_LEN! EQU 1 (
    SET LOCAL_BASE_HF= 00!LOCAL_BASE_HF!
  )
  
  if  !HF_LEN! EQU 2 (
    SET LOCAL_BASE_HF= 0!LOCAL_BASE_HF!
  )
  
   SET /A COUNT=0
   FOR %%A IN (!LOCAL_TARGET_DIR!\*!GLOBAL_HF_PKG_REGEX!_!LOCAL_VERSION!*.zip) DO SET /A COUNT += 1
  
  if !COUNT! EQU 0 (
    echo ERROR: No package found for hotfix : !LOCAL_BASE_HF! with version: !LOCAL_VERSION! in the installer location.
	set /A LOCAL_RESULT=1
	GOTO END-validateHf
  )
  if !COUNT! GTR 1 (
    echo ERROR: More than one base products are present in the installer location. There should be only one.
	set /A LOCAL_RESULT=1
	GOTO END-validateHf
  )
  
  for %%f in (!LOCAL_TARGET_DIR!\*!GLOBAL_HF_PKG_REGEX!_!LOCAL_VERSION!*.zip) do (
	echo BE_HF_PKG#%%f >>!ARG_TEMP_FOLDER!/package_files.txt
  )
  
  :END-validateHf
  (ENDLOCAL & REM -- RETURNING RESULT
   SET %~4=%LOCAL_RESULT%
  )

EXIT /B %LOCAL_RESULT%

:validateAddons
  SETLOCAL 
  set LOCAL_VERSION=%~1 
  set LOCAL_ADDONS=%~2
  set LOCAL_TARGET_DIR=%~3
  set /A LOCAL_RESULT=0
  
  set LOCAL_VERSION=!LOCAL_VERSION: =!
  if !LOCAL_ADDONS! EQU na (
    exit /B 0
  )
  for %%i in (!LOCAL_ADDONS!) do (
	   
	set ADDON_REGEX=!GLOBAL_VALID_ADDONS[%%i]!
	  
	SET /A COUNT=0
	FOR %%A IN (!LOCAL_TARGET_DIR!\*!ADDON_REGEX!_!LOCAL_VERSION!*.zip) DO SET /A COUNT+=1
	  
	if !COUNT! EQU 0 (
	  echo ERROR: No package found for Addon: %%i with version: !LOCAL_VERSION! in the installer location.
	  set /A LOCAL_RESULT=1
	  GOTO END-validateAddons
	)
	if !COUNT! GTR 1 (
	  echo ERROR: More than one addon : %%i are present in the installer location. There should be only one.
	  set /A LOCAL_RESULT=1
	  GOTO END-validateAddons
	)
	set /A found=0
	for %%j in (!GLOBAL_VALID_ADDON_EDITION[enterprise]!) do (
	  if %%i EQU %%j set /A found=1
	)
	if !found! EQU 0 (
      echo ERROR: The specified addon : %%i is not valid.
	  set /A LOCAL_RESULT=1
	  GOTO END-validateAddons
	)  
	
	set /A first=1
	for %%f in (!LOCAL_TARGET_DIR!\*!ADDON_REGEX!_!LOCAL_VERSION!*.zip) do (
	  echo BE_ADDONS_PKG#%%f >>!ARG_TEMP_FOLDER!/package_files.txt
	)
	 
  )
  
  :END-validateAddons
  (ENDLOCAL & REM -- RETURNING LOCAL_RESULT
   SET %~4=%LOCAL_RESULT%
  )

EXIT /B %LOCAL_RESULT%


:validateActivespace 
  SETLOCAL
  set LOCAL_VERSION=%~1
  set LOCAL_AS_VERSION=%~2
  set LOCAL_AS_HF=%~3
  set LOCAL_TARGET_DIR=%~4
  set /A LOCAL_RESULT=0
  
  if "!GLOBAL_VALID_AS_MAP[%LOCAL_VERSION: =%]!"=="" (
    echo ERROR: No AS version found for base BE version !LOCAL_VERSION! 
	set /A LOCAL_RESULT=1
	GOTO END-validateActivespace
  )
    
  SET AS_REG="^.*activespaces_!LOCAL_AS_VERSION!_linux.*\.zip$"
  if !ARG_INSTALLERS_PLATFORM! EQU win (
    SET AS_REG="^.*activespaces_!LOCAL_AS_VERSION!_win.*\.zip$"
  )
  set /a index = 0
  for /f %%i in ('dir !LOCAL_TARGET_DIR! /b ^| findstr /I "!AS_REG!"') do (
    set TEMP_PKG=%%i
    set TEMP_PKG_SPLIT=!TEMP_PKG:_= !
	FOR %%k IN (!TEMP_PKG_SPLIT!) DO (
	  if !index! equ 2 (
	    set LOCAL_AS_VERSION=%%k
	    echo AS_PKG#!LOCAL_TARGET_DIR!\!TEMP_PKG!>>!ARG_TEMP_FOLDER!/package_files.txt
	  )
	  set /a index += 1
	)
  )
  
  set /A IS_LESS=0
  set /A IS_GREATER=0
  
  set LOCAL_AS_VERSION_MIN=!GLOBAL_VALID_AS_MAP[%LOCAL_VERSION: =%]! 
  set LOCAL_AS_VERSION_MAX=!GLOBAL_VALID_AS_MAP_MAX[%LOCAL_VERSION: =%]! 
  
  call :isLess !LOCAL_AS_VERSION! !LOCAL_AS_VERSION_MIN! IS_LESS
  
  call :isGreater !LOCAL_AS_VERSION! !LOCAL_AS_VERSION_MAX! IS_GREATER
  
  IF !IS_LESS! NEQ 1 (
    echo ERROR: AS Version:!LOCAL_AS_VERSION! is incompatible with the BE Version:!LOCAL_VERSION!
	set /A LOCAL_RESULT=1
	GOTO END-validateActivespace
  )
  
  IF !IS_GREATER! NEQ 1 (
    echo ERROR: AS Version:!LOCAL_AS_VERSION! is incompatible with the BE Version:!LOCAL_VERSION!
	set /A LOCAL_RESULT=1
	GOTO END-validateActivespace
  )
  
  ::Checking for only numberic in AS HF
  if !LOCAL_AS_HF! NEQ na (
    for /f "delims=0123456789" %%i in ("!LOCAL_AS_HF!") do set var=%%i
    if defined var (
      echo ERROR: Invalid value for AS_HF : !LOCAL_AS_HF! 
	  set /A LOCAL_RESULT=1
	  GOTO END-validateActivespace
    )
  
    set /A AS_HF_LEN=0
  
    call :strLen LOCAL_AS_HF AS_HF_LEN
  
    if  !AS_HF_LEN! EQU 0 (
      echo ERROR: Invalid value for AS HF : !LOCAL_AS_HF! 
	  set /A LOCAL_RESULT=1
	  GOTO END-validateActivespace
    )
  
    if !AS_HF_LEN! GTR 3 (
      echo ERROR: Invalid value for AS HF : !LOCAL_AS_HF! 
	  set /A LOCAL_RESULT=1
	  GOTO END-validateActivespace
    )
  
    if !AS_HF_LEN! EQU 1 (
      SET LOCAL_AS_HF=00!LOCAL_AS_HF!
    )
  
    if !AS_HF_LEN! EQU 2 (
      SET LOCAL_AS_HF=0!LOCAL_AS_HF!
    )
    
    for /f %%i in ('dir !LOCAL_TARGET_DIR! /b ^| findstr /I "^.*activespaces.*!LOCAL_AS_VERSION!_HF-!LOCAL_AS_HF!.*\.zip$"') DO SET /A AS_HF_COUNT+=1
		
	if !AS_HF_COUNT! EQU 0 (
      echo ERROR: No package found for Activespaces HF-!LOCAL_AS_HF! in the installer location.
	  set /A LOCAL_RESULT=1
	  GOTO END-validateActivespace
    )
    if !AS_HF_COUNT! GTR 1 (
      echo ERROR: More than one AS HF packages are present in the target directory. There should be only one.
	  set /A LOCAL_RESULT=1
	  GOTO END-validateActivespace
    )
	set /a index = 0
    if  !AS_HF_COUNT! EQU 1 (
      for /f %%i in ('dir !LOCAL_TARGET_DIR! /b ^| findstr /I "^.*activespaces.*!LOCAL_AS_VERSION!_HF-!LOCAL_AS_HF!.*\.zip$"') do (
	    set TEMP_PKG=%%i
	    set TEMP_PKG_SPLIT=!TEMP_PKG:_= !
	    FOR %%k IN (!TEMP_PKG_SPLIT!) DO (
	      if !index! equ 2 (
		    echo AS_HF_PKG#!LOCAL_TARGET_DIR!\!TEMP_PKG!>>!ARG_TEMP_FOLDER!/package_files.txt
		  )
		  set /a index += 1
		)
	  )
    )
	
  )
  
  :END-validateActivespace
  (ENDLOCAL & REM -- RETURNING RESULT
   SET %~5=%LOCAL_RESULT% 
  )

EXIT /B %LOCAL_RESULT%

:validateFTLorACTIVESPACES 
  SETLOCAL
  set LOCAL_BE_VERSION=%~1
  set LOCAL_INSTLR_VERSION=%~2
  set LOCAL_INSTLR_HF=%~3
  set LOCAL_TARGET_DIR=%~4
  set LOCAL_INSTLR_TYPE=%~5
  set /A LOCAL_RESULT=0
  set ZIPOREXE=zip
  
  if "!LOCAL_INSTLR_TYPE!"=="ftl" (
    set ZIPOREXE=exe
    if "!GLOBAL_VALID_FTL_MAP[%LOCAL_BE_VERSION: =%]!"=="" (
      echo ERROR: No FTL version found for base BE version !LOCAL_BE_VERSION!
      set /A LOCAL_RESULT=1
      GOTO END-validateFTLorACTIVESPACES
    )
  )

  if "!LOCAL_INSTLR_TYPE!"=="as" (
    if "!GLOBAL_VALID_ACTIVESPACES_MAP[%LOCAL_BE_VERSION: =%]!"=="" (
      echo ERROR: No AS3x version found for base BE version !LOCAL_BE_VERSION!
      set /A LOCAL_RESULT=1
      GOTO END-validateFTLorACTIVESPACES
    )
  )

    
  SET INSTLR_REG="^TIB_%LOCAL_INSTLR_TYPE%_%LOCAL_INSTLR_VERSION%_linux.*\.zip$"
  if !ARG_INSTALLERS_PLATFORM! EQU win (
    SET INSTLR_REG="^TIB_%LOCAL_INSTLR_TYPE%_%LOCAL_INSTLR_VERSION%_win.*\.%ZIPOREXE%$"
  )
  set /a index = 0
  for /f %%i in ('dir !LOCAL_TARGET_DIR! /b ^| findstr /I "%INSTLR_REG%"') do (
    set TEMP_PKG=%%i
    set TEMP_PKG_SPLIT=!TEMP_PKG:_= !
    FOR %%k IN (!TEMP_PKG_SPLIT!) DO (
      if !index! equ 2 (
        set LOCAL_INSTLR_VERSION=%%k
        if "!LOCAL_INSTLR_TYPE!"=="ftl" (
          echo FTL_PKG#!LOCAL_TARGET_DIR!\!TEMP_PKG!>>!ARG_TEMP_FOLDER!/package_files.txt
        )
        if "!LOCAL_INSTLR_TYPE!"=="as" (
          echo ACTIVESPACES_PKG#!LOCAL_TARGET_DIR!\!TEMP_PKG!>>!ARG_TEMP_FOLDER!/package_files.txt
        )
      )
      set /a index += 1
    )
  )
  
  set /A IS_LESS=0
  set /A IS_GREATER=0
  
  if "!LOCAL_INSTLR_TYPE!"=="ftl" (
    set LOCAL_INSTLR_VERSION_MIN=!GLOBAL_VALID_FTL_MAP[%LOCAL_BE_VERSION: =%]! 
    set LOCAL_INSTLR_VERSION_MAX=!GLOBAL_VALID_FTL_MAP_MAX[%LOCAL_BE_VERSION: =%]!
  )
  if "!LOCAL_INSTLR_TYPE!"=="as" (
    set LOCAL_INSTLR_VERSION_MIN=!GLOBAL_VALID_ACTIVESPACES_MAP[%LOCAL_BE_VERSION: =%]! 
    set LOCAL_INSTLR_VERSION_MAX=!GLOBAL_VALID_ACTIVESPACES_MAP_MAX[%LOCAL_BE_VERSION: =%]!
  )
  
  call :isLess !LOCAL_INSTLR_VERSION! !LOCAL_INSTLR_VERSION_MIN! IS_LESS
  
  call :isGreater !LOCAL_INSTLR_VERSION! !LOCAL_INSTLR_VERSION_MAX! IS_GREATER
  
  IF !IS_LESS! NEQ 1 (
    echo ERROR: !LOCAL_INSTLR_TYPE! Version:!LOCAL_INSTLR_VERSION! is incompatible with the BE Version:!LOCAL_BE_VERSION!
	  set /A LOCAL_RESULT=1
	  GOTO END-validateFTLorACTIVESPACES
  )
  
  IF !IS_GREATER! NEQ 1 (
    echo ERROR: !LOCAL_INSTLR_TYPE! Version:!LOCAL_INSTLR_VERSION! is incompatible with the BE Version:!LOCAL_BE_VERSION!
	  set /A LOCAL_RESULT=1
	  GOTO END-validateFTLorACTIVESPACES
  )
  
  ::Checking for only numberic in installer HF
  if !LOCAL_INSTLR_HF! NEQ na (
    for /f "delims=0123456789" %%i in ("!LOCAL_INSTLR_HF!") do set var=%%i
    if defined var (
      echo ERROR: Invalid value for !LOCAL_INSTLR_TYPE!_HF : !LOCAL_INSTLR_HF! 
      set /A LOCAL_RESULT=1
      GOTO END-validateFTLorACTIVESPACES
    )
    set /A INSTLR_HF_LEN=0
    call :strLen LOCAL_INSTLR_HF INSTLR_HF_LEN
    if  !INSTLR_HF_LEN! EQU 0 (
      echo ERROR: Invalid value for !LOCAL_INSTLR_TYPE! HF : !LOCAL_INSTLR_HF! 
      set /A LOCAL_RESULT=1
      GOTO END-validateFTLorACTIVESPACES
    )

    if !INSTLR_HF_LEN! GTR 3 (
      echo ERROR: Invalid value for !LOCAL_INSTLR_TYPE! HF : !LOCAL_INSTLR_HF! 
      set /A LOCAL_RESULT=1
      GOTO END-validateFTLorACTIVESPACES
    )

    if !INSTLR_HF_LEN! EQU 1 (
      SET LOCAL_INSTLR_HF=00!LOCAL_INSTLR_HF!
    )

    if !INSTLR_HF_LEN! EQU 2 (
      SET LOCAL_INSTLR_HF=0!LOCAL_INSTLR_HF!
    )
  
    for /f %%i in ('dir !LOCAL_TARGET_DIR! /b ^| findstr /I "^TIB_%LOCAL_INSTLR_TYPE%_%LOCAL_INSTLR_VERSION%_HF-%LOCAL_INSTLR_HF%_win.*\.zip$"') DO SET /A INSTLR_HF_COUNT+=1
    if !INSTLR_HF_COUNT! EQU 0 (
      echo ERROR: No package found for !LOCAL_INSTLR_TYPE! version %LOCAL_INSTLR_VERSION%  HF-!LOCAL_INSTLR_HF! in the installer location.
      set /A LOCAL_RESULT=1
      GOTO END-validateFTLorACTIVESPACES
    )
    if !INSTLR_HF_COUNT! GTR 1 (
      echo ERROR: More than one !LOCAL_INSTLR_TYPE! HF packages are present in the target directory. There should be only one.
      set /A LOCAL_RESULT=1
      GOTO END-validateFTLorACTIVESPACES
    )
    set /a index = 0
    if  !INSTLR_HF_COUNT! EQU 1 (
      for /f %%i in ('dir !LOCAL_TARGET_DIR! /b ^| findstr /I "^TIB_%LOCAL_INSTLR_TYPE%_%LOCAL_INSTLR_VERSION%_HF-%LOCAL_INSTLR_HF%_win.*\.zip$"') do (
        set TEMP_PKG=%%i
        set TEMP_PKG_SPLIT=!TEMP_PKG:_= !
          FOR %%k IN (!TEMP_PKG_SPLIT!) DO (
            if !index! equ 2 (
               if "!LOCAL_INSTLR_TYPE!"=="ftl" (
                 echo FTL_HF_PKG#!LOCAL_TARGET_DIR!\!TEMP_PKG!>>!ARG_TEMP_FOLDER!/package_files.txt
               )
               if "!LOCAL_INSTLR_TYPE!"=="as" (
                 echo ACTIVESPACES_HF_PKG#!LOCAL_TARGET_DIR!\!TEMP_PKG!>>!ARG_TEMP_FOLDER!/package_files.txt
               )
            )
            set /a index += 1
          )
      )
    )
  )
  
  :END-validateFTLorACTIVESPACES
  (ENDLOCAL & REM -- RETURNING RESULT
   SET %~6=%LOCAL_RESULT%
  )
EXIT /B 0

:validateCorrectNaming
  SETLOCAL
  set LOCAL_ADDONS=%~1
  set /A LOCAL_RESULT=0
  
  if !LOCAL_ADDONS! neq na (
	  for %%i in (!LOCAL_ADDONS!) do (
		if not defined GLOBAL_VALID_ADDONS[%%i] (
			echo ERROR: Invalid value for addon - '%%i', should be either of process, views. Aborting..
			set /A LOCAL_RESULT=1
		)
	  )
  )
  
  (ENDLOCAL & REM -- RETURNING RESULT
   SET %~2=%LOCAL_RESULT%
  )
EXIT /B 0

:validateVersion
  SETLOCAL
  set LOCAL_VERSION=%~1
  set /A LOCAL_RESULT=0
  FOR /f "tokens=1,2,3,4 delims=." %%a IN ("!LOCAL_VERSION!") do (
    set version1=%%a
	set version2=%%b
	set version3=%%c
	set version4=%%d
  )
	
  echo("!version1!"|findstr "^[\"][-][1-9][0-9]*[\"]$ ^[\"][1-9][0-9]*[\"]$ ^[\"]0[\"]$">nul && set x=1 || set LOCAL_RESULT=1 
  echo("!version2!"|findstr "^[\"][-][1-9][0-9]*[\"]$ ^[\"][1-9][0-9]*[\"]$ ^[\"]0[\"]$">nul && set x=1 || set LOCAL_RESULT=1
  echo("!version3!"|findstr "^[\"][-][1-9][0-9]*[\"]$ ^[\"][1-9][0-9]*[\"]$ ^[\"]0[\"]$">nul && set x=1 || set LOCAL_RESULT=1
	
  if [!version4!] NEQ [] (
	set LOCAL_RESULT=1
  )
  
  if !LOCAL_RESULT! NEQ 0 (
    echo ERROR: Cannot find a valid BE installer at the specified location.
  )
  
  (ENDLOCAL & REM -- RETURNING RESULT
   SET %~2=%LOCAL_RESULT%
  )
EXIT /B %LOCAL_RESULT%
  
 
::Util method for finding string length
:strLen
  SETLOCAL
  set /A len = 1
  :strLen_Loop
	if not "!%1:~%len%!"=="" set /A len+ = 1 & goto :strLen_Loop
  (endlocal & set %~2=%len%)
EXIT /B 0
 
 
::Util method for comparing as verisons
:isLess
  SETLOCAL
  set /A FLAG = 1
  set AS_VERSION=%~1
  set LOCAL_AS_VERSION_MIN=%~2
  
  FOR /f "tokens=1,2,3 delims=." %%a IN ("!AS_VERSION!") do (
    set /A version1=%%a
	set /A version2=%%b
	set /A version3=%%c
  )
  
  FOR /f "tokens=1,2,3 delims=." %%a IN ("!LOCAL_AS_VERSION_MIN!") do (
    set /A versionMin1=%%a
	set /A versionMin2=%%b
	set /A versionMin3=%%c
  )
  
  if !versionMin1! LSS !version1! (
    set /a FLAG=1
	GOTO END-isLess
  )
  if !versionMin1! GTR !version1! (
    set /a FLAG=0
	GOTO END-isLess
  )
  if !versionMin2! LSS !version2! (
    set /a FLAG=1
	GOTO END-isLess
  )
  if !versionMin2! GTR !version2! (
    set /a FLAG=0
	GOTO END-isLess
  )
  if !versionMin3! GTR !version3! (
    set /a FLAG=0
	GOTO END-isLess
  )
  :END-isLess
  (endlocal & set %~3=%FLAG%)
EXIT /B 0

:isGreater
  SETLOCAL
  set /A FLAG = 1
  set AS_VERSION=%~1
  set LOCAL_AS_VERSION_MAX=%~2
  
  FOR /f "tokens=1,2,3 delims=." %%a IN ("!AS_VERSION!") do (
    set /A version1=%%a
	set /A version2=%%b
	set /A version3=%%c
  )
  
  FOR /f "tokens=1,2,3 delims=." %%a IN ("!LOCAL_AS_VERSION_MAX!") do (
    set versionMax1=%%a
	set versionMax2=%%b
	set versionMax3=%%c
  )
  
  FOR %%a in (x X) DO (
    IF %versionMax1%==%%a set /A versionMax1=%version1%
    IF %versionMax2%==%%a set /A versionMax2=%version2%
    IF %versionMax3%==%%a set /A versionMax3=%version3%
  )

  if !versionMax1! GTR !version1! (
    set /a FLAG=1
	GOTO END-isGreater
  )
  if !versionMax1! LSS !version1! (
    set /a FLAG=0
	GOTO END-isGreater
  )
  if !versionMax2! GTR !version2! (
    set /a FLAG=1
	GOTO END-isGreater
  )
  if !versionMax2! LSS !version2! (
    set /a FLAG=0
	GOTO END-isGreater
  )
  if !versionMax3! LSS !version3! (
    set /a FLAG=0
	GOTO END-isGreater
  )
  if !versionMax3! GTR !version3! (
    set /a FLAG=1
	GOTO END-isGreater
  )
  :END-isGreater
  (endlocal & set %~3=%FLAG%)
EXIT /B 0

:IdentifyInstaller
  SETLOCAL
  set INSTLR_TYPE=%~1
  set LOCAL_INSTLR_RESULT=na
  set INSTLR_REG="^TIB_%INSTLR_TYPE%_[0-9]\.[0-9]\.[0-9]_linux.*\.zip$"
  set ZIPOREXE=zip
  if %INSTLR_TYPE% EQU ftl (
    set ZIPOREXE=exe
  )
  if !ARG_INSTALLERS_PLATFORM! EQU win (
    set INSTLR_REG=^TIB_%INSTLR_TYPE%_[0-9]\.[0-9]\.[0-9]_win.*\.%ZIPOREXE%$
  )
  for /f %%i in ('dir /b !ARG_INSTALLER_LOCATION! ^| findstr /I "!INSTLR_REG!"') do (
    if !LOCAL_INSTLR_RESULT! NEQ na (
      echo ERROR: Multiple %INSTLR_TYPE% installers found at the specified location.
      set LOCAL_INSTLR_RESULT=multiple
      GOTO END-IdentifyInstaller
    )
    set temp=%%i
    set /a ind2 = 0
    set TEMP_PKG_SPLIT_UNDERSCORE=!temp:_= !
    for %%j in (!TEMP_PKG_SPLIT_UNDERSCORE!) do (
      if !ind2! equ 2 (
        set LOCAL_INSTLR_RESULT=%%j
      )
      set /a ind2 += 1
    )
  )

  :END-IdentifyInstaller
  (ENDLOCAL & REM -- RETURNING RESULT
   SET %~2=%LOCAL_INSTLR_RESULT%
  )
EXIT /B %LOCAL_INSTLR_RESULT%

:IdentifyInstallerHf
  SETLOCAL
  set INSTLR_TYPE=%~1
  set LOCAL_INSTLR_RESULT=na
  set INSTALR_HF_REG="^TIB_%INSTLR_TYPE%_[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_linux.*\.zip$"

  if !ARG_INSTALLERS_PLATFORM! EQU win (
    SET INSTALR_HF_REG=^TIB_%INSTLR_TYPE%_[0-9]\.[0-9]\.[0-9]_HF-[0-9]*_win.*\.zip$
  )
  for /f %%i in ('dir /b !ARG_INSTALLER_LOCATION! ^| findstr /I "!INSTALR_HF_REG!"') do (
    if !LOCAL_INSTLR_RESULT! NEQ na (
      echo ERROR: Multiple %INSTLR_TYPE% HF found at the specified location.
      set LOCAL_INSTLR_RESULT=multiple
      GOTO END-IdentifyInstallerHf
    )
    set temp=%%i
    set /a ind3 = 0
    set TEMP_PKG_SPLIT_UNDERSCORE=!temp:_= !
    for %%j in (!TEMP_PKG_SPLIT_UNDERSCORE!) do (
      if !ind3! equ 3 (
        set temp2=%%j
        set /a ind4 = 0   
        set TEMP_PKG_SPLIT_HYPHEN=!temp2:-= !
        for %%k in (!TEMP_PKG_SPLIT_HYPHEN!) do (
          if !ind4! equ 1 (
            set LOCAL_INSTLR_RESULT=%%k
          )
          set /a ind4 += 1
        )
      )
      set /a ind3 += 1
    )
  )

  :END-IdentifyInstallerHf
  (ENDLOCAL & REM -- RETURNING RESULT
   SET %~2=%LOCAL_INSTLR_RESULT%
  )
EXIT /B %LOCAL_INSTLR_RESULT%