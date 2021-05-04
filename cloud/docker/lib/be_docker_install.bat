@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

if "%AS_VERSION%" EQU "" set AS_VERSION=na
if "%FTL_VERSION%" EQU "" set FTL_VERSION=na
if "%ACTIVESPACES_VERSION%" EQU "" set ACTIVESPACES_VERSION=na

if "%COMPONENT%" EQU "rms" (
	set TRA_FILE=rms/bin/be-rms.tra
) else (
	set TRA_FILE=bin/be-engine.tra
)

powershell -Command "mkdir c:\tibco -ErrorAction Ignore | out-null; mkdir c:\tibco\be\application -ErrorAction Ignore | out-null"
:: if AS is available extract and install it.
if "%AS_VERSION%" NEQ "na" (
	echo Extracting ActiveSpaces Legacy %AS_VERSION%
	powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_activespaces_[0-9]\.[0-9]\.[0-9]_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
	cd /d c:/working/installer
	echo Installing ActiveSpaces Legacy %AS_VERSION% ...
	powershell -Command "(Get-Content 'TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent') -replace '<entry key=\"installationRoot\">c:\\TIBCO</entry>', '<entry key=\"installationRoot\">c:\tibco</entry>' | Set-Content 'TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent'"
	TIBCOUniversalInstaller-x86-64.exe -silent
	powershell -Command "while (Get-Process TIBCOUniversalInstaller-x86-64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"
	
	REM Install AS HF
	cd /d c:/working
	powershell -Command "Get-ChildItem -Path 'c:\working\installer' -exclude TIBCOUniversalInstaller-x86-64.exe | Remove-Item -Recurse -force"
	if "%AS_VERSION%" NEQ "na" (
		powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_activespaces_.*[0-9]\.[0-9]\.[0-9]_HF.*_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
		if exist c:/working/installer/TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent (
			echo Extracting ActiveSpaces Legacy HF
			cd /d c:/working/installer
			echo Installing ActiveSpaces Legacy HF ...
			powershell -Command "(Get-Content 'TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent') -replace '<entry key=\"installationRoot\">c:\\TIBCO</entry>', '<entry key=\"installationRoot\">c:\tibco</entry>' | Set-Content 'TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent'"
			TIBCOUniversalInstaller-x86-64.exe -silent
			powershell -Command "while (Get-Process TIBCOUniversalInstaller-x86-64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"
		)
	)
	mkdir c:\_tibco\as\%AS_SHORT_VERSION%\lib
	powershell -Command "Copy-Item 'c:\tibco\as\%AS_SHORT_VERSION%\lib\*.dll','c:\tibco\as\%AS_SHORT_VERSION%\lib\*.jar','c:\tibco\as\%AS_SHORT_VERSION%\lib\*.lib' -Destination 'c:\_tibco\as\%AS_SHORT_VERSION%\lib' -Recurse | out-null"
)

cd /d c:/working
powershell -Command "rm -Recurse -Force 'c:/working/installer' -ErrorAction Ignore | out-null"

:: Extract and install BE and addons (if any)
echo Extracting BusinessEvents %BE_PRODUCT_VERSION%
powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_businessevents-.*_[0-9]\.[0-9]\.[0-9]_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
cd /d c:/working/installer
:: If AS is not available disable DataGrid.
if "%AS_VERSION%" EQU "na" (
	powershell -Command "(Get-Content 'TIBCOUniversalInstaller_businessevents-enterprise_%BE_PRODUCT_VERSION%.silent') -replace '(.*)TIBCO BusinessEvents DataGrid(.*)true(.*)', '$1TIBCO BusinessEvents DataGrid$2false$3' | Set-Content 'TIBCOUniversalInstaller_businessevents-enterprise_%BE_PRODUCT_VERSION%.silent'"
)
echo Installing BusinessEvents %BE_PRODUCT_VERSION% ...
TIBCOUniversalInstaller-x86-64.exe -silent
:: Wait for installation to complete, check every 2sec.
powershell -Command "while (Get-Process TIBCOUniversalInstaller-x86-64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"

:: Backup installer exe file, needed while installing HFs
powershell -Command "Copy-Item 'c:\working\installer\TIBCOUniversalInstaller-x86-64.exe' -Destination 'c:\working'"


:: Install BE HF
cd /d c:/working
powershell -Command "Get-ChildItem -Path 'c:\working\installer' -exclude TIBCOUniversalInstaller-x86-64.exe | Remove-Item -Recurse -force"
powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_businessevents-.*[0-9]\.[0-9]\.[0-9]_HF.*_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
if exist c:/working/installer/TIBCOUniversalInstaller.silent (
	echo Extracting BusinessEvents HF
	cd /d c:/working/installer
	echo Installing BusinessEvents HF ...
	TIBCOUniversalInstaller-x86-64.exe -silent
	powershell -Command "while (Get-Process TIBCOUniversalInstaller-x86-64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"
)

:: if FTL is available extract and install it.
if "%FTL_VERSION%" NEQ "na" (
	call :InstallFTLorAS "%FTL_VERSION%" "%FTL_SHORT_VERSION%" "ftl"
	:: if ftl hf present install it.
	if "%FTL_PRODUCT_HOTFIX%" NEQ "na" (
		call :InstallFtlorASHf "%FTL_VERSION%" "%FTL_SHORT_VERSION%" "ftl"
	)
	mkdir c:\_tibco\ftl\%FTL_SHORT_VERSION%\lib c:\_tibco\ftl\%FTL_SHORT_VERSION%\bin
	powershell -Command "Copy-Item 'c:\tibco\ftl\%FTL_SHORT_VERSION%\lib\*.dll','c:\tibco\ftl\%FTL_SHORT_VERSION%\lib\*.jar','c:\tibco\ftl\%FTL_SHORT_VERSION%\lib\*.lib' -Destination 'c:\_tibco\ftl\%FTL_SHORT_VERSION%\lib' -Recurse | out-null"
	powershell -Command "Copy-Item 'c:\tibco\ftl\%FTL_SHORT_VERSION%\bin\*.dll','c:\tibco\ftl\%FTL_SHORT_VERSION%\bin\*.jar','c:\tibco\ftl\%FTL_SHORT_VERSION%\bin\*.lib' -Destination 'c:\_tibco\ftl\%FTL_SHORT_VERSION%\bin' -Recurse | out-null"
)

:: if ACTIVESPACES is available extract and install it.
if "%ACTIVESPACES_VERSION%" NEQ "na" (
	call :InstallFTLorAS "%ACTIVESPACES_VERSION%" "%ACTIVESPACES_SHORT_VERSION%" "as"
	:: if activespaces hf present install it.
	if "%ACTIVESPACES_PRODUCT_HOTFIX%" NEQ "na" (
		call :InstallFtlorASHf "%ACTIVESPACES_VERSION%" "%ACTIVESPACES_SHORT_VERSION%" "as"
	)
	mkdir c:\_tibco\as\%ACTIVESPACES_SHORT_VERSION%\lib c:\_tibco\as\%ACTIVESPACES_SHORT_VERSION%\bin
	powershell -Command "Copy-Item 'c:\tibco\as\%ACTIVESPACES_SHORT_VERSION%\lib\*.dll','c:\tibco\as\%ACTIVESPACES_SHORT_VERSION%\lib\*.jar','c:\tibco\as\%ACTIVESPACES_SHORT_VERSION%\lib\*.lib' -Destination 'c:\_tibco\as\%ACTIVESPACES_SHORT_VERSION%\lib' -Recurse | out-null"
	powershell -Command "Copy-Item 'c:\tibco\as\%ACTIVESPACES_SHORT_VERSION%\bin\*.dll','c:\tibco\as\%ACTIVESPACES_SHORT_VERSION%\bin\*.jar','c:\tibco\as\%ACTIVESPACES_SHORT_VERSION%\bin\*.lib' -Destination 'c:\_tibco\as\%ACTIVESPACES_SHORT_VERSION%\bin' -Recurse | out-null"
)

:: Delete installer zip files.
cd /d c:/working
powershell -Command "rm -Recurse -Force 'c:/working/TIBCOUniversalInstaller-x86-64.exe' -ErrorAction Ignore | out-null; rm -Recurse -Force 'c:/working/*.zip' -ErrorAction Ignore | out-null"

:: If AS is available append relevent properties to tra.
if %AS_VERSION% NEQ na (
	echo java.property.be.engine.cluster.as.discover.url=%%AS_DISCOVER_URL%%>> %BE_HOME%/%TRA_FILE%
	echo java.property.be.engine.cluster.as.listen.url=%%AS_LISTEN_URL%%>> %BE_HOME%/%TRA_FILE%
	echo java.property.be.engine.cluster.as.remote.listen.url=%%AS_REMOTE_LISTEN_URL%%>> %BE_HOME%/%TRA_FILE%
)
echo java.property.com.sun.management.jmxremote.rmi.port=%%jmx_port%%>> %BE_HOME%/%TRA_FILE%

:: Perform annotations processing (_annotations.idx)
cd %BE_HOME%/bin
set CLASSPATH=%BE_HOME%/lib/*;%BE_HOME%/lib/ext/tpcl/*;%BE_HOME%/lib/ext/tpcl/aws/*;%BE_HOME%/lib/ext/tpcl/gwt/*;%BE_HOME%/lib/ext/tpcl/apache/*;%BE_HOME%/lib/ext/tpcl/emf/*;%BE_HOME%/lib/ext/tpcl/tomsawyer/*;%BE_HOME%/lib/ext/tibco/*;%BE_HOME%/lib/eclipse/plugins/*;%BE_HOME%/rms/lib/*;%BE_HOME%/mm/lib/*;%JRE_HOME%/lib/*;%JRE_HOME%/lib/ext/*;
echo Building annotation indexes..
%JRE_HOME%/bin/java -cp %CLASSPATH% com.tibco.be.model.functions.impl.JavaAnnotationLookup

if "%COMPONENT%" EQU "rms" (
	mkdir c:\_tibco\be\%BE_SHORT_VERSION%\bin c:\_tibco\be\%BE_SHORT_VERSION%\examples\standard\WebStudio
	powershell -Command "Copy-Item '%BE_HOME%\lib','%BE_HOME%\rms','%BE_HOME%\studio','%BE_HOME%\mm','%BE_HOME%\eclipse-platform' -Destination 'c:\_tibco\be\%BE_SHORT_VERSION%' -Recurse | out-null"
	rd /S /Q c:\_tibco\be\%BE_SHORT_VERSION%\lib\ext\tpcl\aws
	powershell -Command "Copy-Item '%BE_HOME%\examples\standard\WebStudio' -Destination 'c:\_tibco\be\%BE_SHORT_VERSION%\examples\standard\WebStudio' -Recurse | out-null"
	if exist "%BE_HOME%\decisionmanager" powershell -Command "Copy-Item '%BE_HOME%\decisionmanager' -Destination 'c:\_tibco\be\%BE_SHORT_VERSION%' -Recurse | out-null"
) else (
	mkdir c:\_tibco\be\%BE_SHORT_VERSION%\bin
	powershell -Command "Copy-Item '%BE_HOME%\lib' -Destination 'c:\_tibco\be\%BE_SHORT_VERSION%' -Recurse | out-null"
	rd /S /Q c:\_tibco\be\%BE_SHORT_VERSION%\lib\ext\tpcl\tomsawyer
)
if exist "%BE_HOME%\hotfix" powershell -Command "Copy-Item '%BE_HOME%\hotfix' -Destination 'c:\_tibco\be\%BE_SHORT_VERSION%' -Recurse | out-null"
powershell -Command "Copy-Item 'c:\tibco\tibcojre64' -Destination 'c:\_tibco' -Recurse | out-null"
powershell -Command "Copy-Item '%BE_HOME%/bin/be-engine.tra','%BE_HOME%\bin\be-engine.exe','%BE_HOME%\bin\_annotations.idx','%BE_HOME%\bin\dbkeywordmap.xml' -Destination 'c:\_tibco\be\%BE_SHORT_VERSION%\bin' -Recurse | out-null"

if exist "%BE_HOME%\bin\cassandrakeywordmap.xml" powershell -Command "Copy-Item '%BE_HOME%\bin\cassandrakeywordmap.xml' -Destination 'c:\_tibco\be\%BE_SHORT_VERSION%\bin' -Recurse | out-null"

if exist "c:\_tibco\be\%BE_SHORT_VERSION%\lib\eclipse" (
	rd /S /Q "c:\_tibco\be\%BE_SHORT_VERSION%\lib\eclipse" > NUL
)

if exist "c:\_tibco\be\ext\%CDD_FILE_NAME%" (
	if "%COMPONENT%" EQU "rms" copy "c:\_tibco\be\ext\%CDD_FILE_NAME%"  "c:\_tibco\be\%BE_SHORT_VERSION%\rms\bin"  > NUL
	del /S /Q "c:\_tibco\be\ext\%CDD_FILE_NAME%" > NUL
)

if exist "c:\_tibco\be\ext\%EAR_FILE_NAME%" (
	if "%COMPONENT%" EQU "rms" copy "c:\_tibco\be\ext\%EAR_FILE_NAME%"  "c:\_tibco\be\%BE_SHORT_VERSION%\rms\bin"  > NUL
	del /S /Q "c:\_tibco\be\ext\%EAR_FILE_NAME%" > NUL
)

EXIT /B 0

::----------------------------------------------------------------------------------------------------
REM INSTALLERS SUBROUTINES
::----------------------------------------------------------------------------------------------------
:InstallFTLorAS
	SETLOCAL
  	set VERSION=%~1
	set SHORT_VERSION=%~2
	set InstallerType=%~3

	if %InstallerType% EQU as (
		echo Extracting Activespaces %VERSION%
		powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_%InstallerType%_[0-9]\.[0-9]\.[0-9]_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
		cd /d c:/working/installer
		echo Installing Activespaces %VERSION% ...
	)
	if %InstallerType% EQU ftl (
		cd /d c:/working
		echo Installing FTL %VERSION% ...
	)

	powershell -Command "mkdir c:/tibco/%InstallerType%/%SHORT_VERSION% | out-null"
	TIB_%InstallerType%_%VERSION%_win_x86_64.exe /S /D=c:/tibco/%InstallerType%/%SHORT_VERSION%
	powershell -Command "while (Get-Process TIB_%InstallerType%_%VERSION%_win_x86_64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"
	powershell -Command "Get-ChildItem -Path 'c:\tibco\%InstallerType%\%SHORT_VERSION%' -exclude lib, bin | Remove-Item -Recurse -force"
	echo Completed

	cd /d c:/working
	powershell -Command "rm -Recurse -Force 'c:/working/installer' -ErrorAction Ignore | out-null"

	if exist %BE_HOME%/%TRA_FILE% (
		if %InstallerType% EQU ftl powershell -Command "(Get-Content '%BE_HOME%/%TRA_FILE%') -replace 'tibco.env.FTL_HOME=', 'tibco.env.FTL_HOME=c:/tibco/%InstallerType%/%SHORT_VERSION%' | Set-Content '%BE_HOME%/%TRA_FILE%'"
		if %InstallerType% EQU as powershell -Command "(Get-Content '%BE_HOME%/%TRA_FILE%') -replace 'tibco.env.ACTIVESPACES_HOME=', 'tibco.env.ACTIVESPACES_HOME=c:/tibco/%InstallerType%/%SHORT_VERSION%' | Set-Content '%BE_HOME%/%TRA_FILE%'"
	)
Exit /B 0

:InstallFtlorASHf
	SETLOCAL
	set VERSION=%~1
	set SHORT_VERSION=%~2
	set InstallerType=%~3

	echo Extracting %InstallerType% hf
	powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_%InstallerType%_[0-9]\.[0-9]\.[0-9]_HF.*_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
	cd /d c:/working/installer
	if exist c:/working/installer/%InstallerType%/%SHORT_VERSION% (
		echo Copying %InstallerType% hf ...
		if exist c:/working/installer/%InstallerType%/%SHORT_VERSION%/bin powershell -Command "copy-item -path c:\working\installer\%InstallerType%\%SHORT_VERSION%\bin\* –destination c:\tibco\%InstallerType%\%SHORT_VERSION%\bin -Force"
		if exist c:/working/installer/%InstallerType%/%SHORT_VERSION%/lib powershell -Command "copy-item -path c:\working\installer\%InstallerType%\%SHORT_VERSION%\lib\* –destination c:\tibco\%InstallerType%\%SHORT_VERSION%\lib -Force"
		echo Completed
	) else (
		echo "WARN: Inavlid hf"
	)
	cd /d c:/working
	powershell -Command "rm -Recurse -Force 'c:/working/installer' -ErrorAction Ignore | out-null"
Exit /B 0
