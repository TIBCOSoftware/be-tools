@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

powershell -Command "mkdir c:\tibco -ErrorAction Ignore | out-null; mkdir c:\tibco\be\application -ErrorAction Ignore | out-null"
:: if AS is available extract and install it.
if %AS_VERSION% NEQ na (
	echo Extracting ActiveSpaces
	powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_activespaces_[0-9]\.[0-9]\.[0-9]_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
	cd /d c:/working/installer
	echo Installing ActiveSpaces..
	powershell -Command "(Get-Content 'TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent') -replace '<entry key=\"installationRoot\">c:\\TIBCO</entry>', '<entry key=\"installationRoot\">c:\tibco</entry>' | Set-Content 'TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent'"
	TIBCOUniversalInstaller-x86-64.exe -silent
	powershell -Command "while (Get-Process TIBCOUniversalInstaller-x86-64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"
	
	REM Install AS HF
	cd /d c:/working
	powershell -Command "Get-ChildItem -Path 'c:\working\installer' -exclude TIBCOUniversalInstaller-x86-64.exe | Remove-Item -Recurse -force"
	if %AS_VERSION% NEQ na (
		powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_activespaces_.*[0-9]\.[0-9]\.[0-9]_HF.*_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
		if exist c:/working/installer/TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent (
			echo Extracting ActiveSpaces HF
			cd /d c:/working/installer
			echo Installing ActiveSpaces HF..
			powershell -Command "(Get-Content 'TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent') -replace '<entry key=\"installationRoot\">c:\\TIBCO</entry>', '<entry key=\"installationRoot\">c:\tibco</entry>' | Set-Content 'TIBCOUniversalInstaller_activespaces_%AS_VERSION%.silent'"
			TIBCOUniversalInstaller-x86-64.exe -silent
			powershell -Command "while (Get-Process TIBCOUniversalInstaller-x86-64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"
		)
	)
)

cd /d c:/working
powershell -Command "rm -Recurse -Force 'c:/working/installer' -ErrorAction Ignore | out-null"

:: Extract and install BE and addons (if any)
echo Extracting BusinessEvents
powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_businessevents-.*_[0-9]\.[0-9]\.[0-9]_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
cd /d c:/working/installer
:: If AS is not available disable DataGrid.
if %AS_VERSION% EQU na (
	powershell -Command "(Get-Content 'TIBCOUniversalInstaller_businessevents-enterprise_%BE_PRODUCT_VERSION%.silent') -replace '(.*)TIBCO BusinessEvents DataGrid(.*)true(.*)', '$1TIBCO BusinessEvents DataGrid$2false$3' | Set-Content 'TIBCOUniversalInstaller_businessevents-enterprise_%BE_PRODUCT_VERSION%.silent'"
)
echo Installing BusinessEvents..
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
	echo Installing BusinessEvents HF..
	TIBCOUniversalInstaller-x86-64.exe -silent
	powershell -Command "while (Get-Process TIBCOUniversalInstaller-x86-64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"
)

:: if FTL is available extract and install it.
if %FTL_VERSION% NEQ na (
	call :InstallFTLorAS %FTL_VERSION% %FTL_SHORT_VERSION% "ftl"
	:: if ftl hf present install it.
	if %FTL_PRODUCT_HOTFIX% NEQ na (
		call :InstallFtlorASHf %FTL_VERSION% %FTL_SHORT_VERSION% "ftl"
	)
)

:: if AS3X is available extract and install it.
if %AS3X_VERSION% NEQ na (
	call :InstallFTLorAS %AS3X_VERSION% %AS3X_SHORT_VERSION% "as"
	:: if as3x hf present install it.
	if %AS3X_PRODUCT_HOTFIX% NEQ na (
		call :InstallFtlorASHf %AS3X_VERSION% %AS3X_SHORT_VERSION% "as"
	)
)

:: Delete installer zip files.
cd /d c:/working
powershell -Command "rm -Recurse -Force 'c:/working/TIBCOUniversalInstaller-x86-64.exe' -ErrorAction Ignore | out-null; rm -Recurse -Force 'c:/working/*.zip' -ErrorAction Ignore | out-null"

:: If AS is available append relevent properties to tra.
if %AS_VERSION% NEQ na (
	echo java.property.be.engine.cluster.as.discover.url=%%AS_DISCOVER_URL%%>> %BE_HOME%\bin\be-engine.tra
	echo java.property.be.engine.cluster.as.listen.url=%%AS_LISTEN_URL%%>> %BE_HOME%\bin\be-engine.tra
	echo java.property.be.engine.cluster.as.remote.listen.url=%%AS_REMOTE_LISTEN_URL%%>> %BE_HOME%\bin\be-engine.tra
)
echo java.property.com.sun.management.jmxremote.rmi.port=%%jmx_port%%>> %BE_HOME%\bin\be-engine.tra

:: Perform annotations processing (_annotations.idx)
cd %BE_HOME%/bin
set CLASSPATH=%BE_HOME%/lib/*;%BE_HOME%/lib/ext/tpcl/*;%BE_HOME%/lib/ext/tpcl/aws/*;%BE_HOME%/lib/ext/tpcl/gwt/*;%BE_HOME%/lib/ext/tpcl/apache/*;%BE_HOME%/lib/ext/tpcl/emf/*;%BE_HOME%/lib/ext/tpcl/tomsawyer/*;%BE_HOME%/lib/ext/tibco/*;%BE_HOME%/lib/eclipse/plugins/*;%BE_HOME%/rms/lib/*;%BE_HOME%/mm/lib/*;%JRE_HOME%/lib/*;%JRE_HOME%/lib/ext/*;
echo Building annotation indexes..
%JRE_HOME%/bin/java -cp %CLASSPATH% com.tibco.be.model.functions.impl.JavaAnnotationLookup
EXIT /B 0

::----------------------------------------------------------------------------------------------------
REM INSTALLERS SUBROUTINES
::----------------------------------------------------------------------------------------------------
:InstallFTLorAS
	SETLOCAL
  	set VERSION=%~1
	set SHORT_VERSION=%~2
	set InstallerType=%~3

	echo Extracting %InstallerType%
	powershell -Command "Get-ChildItem c:/working | Where{$_.Name -Match '^TIB_%InstallerType%_[0-9]\.[0-9]\.[0-9]_win.*'} | expand-archive -DestinationPath c:/working/installer -force"
	cd /d c:/working/installer
	echo Installing %InstallerType%..
	powershell -Command "mkdir c:/tibco/%InstallerType%/%SHORT_VERSION% | out-null"
	TIB_%InstallerType%_%VERSION%_win_x86_64.exe /S /D=c:/tibco/%InstallerType%/%SHORT_VERSION%
	powershell -Command "while (Get-Process TIB_%InstallerType%_%VERSION%_win_x86_64 -ErrorAction SilentlyContinue) { Start-Sleep 2 }"
	powershell -Command "Get-ChildItem -Path 'c:\tibco\%InstallerType%\%SHORT_VERSION%' -exclude lib, bin | Remove-Item -Recurse -force"
	echo Completed

	cd /d c:/working
	powershell -Command "rm -Recurse -Force 'c:/working/installer' -ErrorAction Ignore | out-null"

	if exist %BE_HOME%/bin/be-engine.tra (
		if %InstallerType% EQU ftl powershell -Command "(Get-Content '%BE_HOME%/bin/be-engine.tra') -replace 'tibco.env.FTL_HOME=', 'tibco.env.FTL_HOME=c:/tibco/%InstallerType%/%SHORT_VERSION%' | Set-Content '%BE_HOME%/bin/be-engine.tra'"
		if %InstallerType% EQU as powershell -Command "(Get-Content '%BE_HOME%/bin/be-engine.tra') -replace 'tibco.env.AS3x_HOME=', 'tibco.env.AS3x_HOME=c:/tibco/%InstallerType%/%SHORT_VERSION%' | Set-Content '%BE_HOME%/bin/be-engine.tra'"
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
		echo Copying %InstallerType% hf
		if exist c:/working/installer/%InstallerType%/%SHORT_VERSION%/bin powershell -Command "copy-item -path c:\working\installer\%InstallerType%\%SHORT_VERSION%\bin\* –destination c:\tibco\%InstallerType%\%SHORT_VERSION%\bin -Force"
		if exist c:/working/installer/%InstallerType%/%SHORT_VERSION%/lib powershell -Command "copy-item -path c:\working\installer\%InstallerType%\%SHORT_VERSION%\lib\* –destination c:\tibco\%InstallerType%\%SHORT_VERSION%\lib -Force"
		echo Completed
	) else (
		echo "WARN: Inavlid hf"
	)
	cd /d c:/working
	powershell -Command "rm -Recurse -Force 'c:/working/installer' -ErrorAction Ignore | out-null"
Exit /B 0