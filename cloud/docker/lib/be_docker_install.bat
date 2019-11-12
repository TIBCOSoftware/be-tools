@echo off

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
