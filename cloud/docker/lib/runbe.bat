@echo off

if "%AS_DISCOVER_URL%" == "self" (
  set AS_DISCOVER_URL=tcp://%COMPUTERNAME%:50000
)

if "%AS_LISTEN_URL%" == "" set AS_LISTEN_URL=tcp://%COMPUTERNAME%:50000
if "%AS_REMOTE_LISTEN_URL%" == "" set AS_REMOTE_LISTEN_URL=tcp://%COMPUTERNAME%:50001

if "%AS_PROXY_NODE%" == "" set AS_PROXY_NODE=false
set TRA_FILE=%BE_HOME%\bin\be-engine.tra

:: set be-rms.tra
:: Workaround for - https://github.com/moby/moby/issues/20127
if "%COMPONENT%" == "rms" (
	set "TRA_FILE=%BE_HOME%\rms\bin\be-rms.tra"
	powershell -Command "if ((Get-ChildItem '%BE_HOME%\rms\config\security' | Measure-Object ).Count -eq 0) { Copy-Item '%BE_HOME%\rms\config\_security\*' -Destination '%BE_HOME%\rms\config\security' -Recurse }; rm -Recurse -Force '%BE_HOME%\rms\config\_security' -ErrorAction Ignore"
	powershell -Command "if ((Get-ChildItem '%BE_HOME%\rms\config\notify' | Measure-Object ).Count -eq 0) { Copy-Item '%BE_HOME%\rms\config\_notify\*' -Destination '%BE_HOME%\rms\config\notify' -Recurse }; rm -Recurse -Force '%BE_HOME%\rms\config\_notify' -ErrorAction Ignore"
	powershell -Command "if ((Get-ChildItem '%BE_HOME%\rms\lib\locales' | Measure-Object ).Count -eq 0) { Copy-Item '%BE_HOME%\rms\lib\_locales\*' -Destination '%BE_HOME%\rms\lib\locales' -Recurse }; rm -Recurse -Force '%BE_HOME%\rms\lib\_locales' -ErrorAction Ignore"
	powershell -Command "if ((Get-ChildItem '%BE_HOME%\rms\shared' | Measure-Object ).Count -eq 0) { Copy-Item '%BE_HOME%\rms\_shared\*' -Destination '%BE_HOME%\rms\shared' -Recurse }; rm -Recurse -Force '%BE_HOME%\rms\_shared' -ErrorAction Ignore"
	powershell -Command "if ((Get-ChildItem '%BE_HOME%\examples\standard\WebStudio' | Measure-Object ).Count -eq 0) { Copy-Item '%BE_HOME%\examples\standard\_WebStudio\*' -Destination '%BE_HOME%\examples\standard\WebStudio' -Recurse }; rm -Recurse -Force '%BE_HOME%\examples\standard\_WebStudio' -ErrorAction Ignore"
)

::TODO component tea
if "%COMPONENT%" == "tea" (
	set "TRA_FILE=%BE_HOME%\teagent\bin\be-teagent.tra"
	set "TEA_PROPS_FILE=%BE_HOME%\teagent\config\be-teagent.props"
)

if "%JMX_PORT%" == "" set JMX_PORT=5555

echo JMX_PORT: %JMX_PORT%
echo BE_HOME: %BE_HOME%
echo TRA FILE: %TRA_FILE%
echo ENGINE NAME: %ENGINE_NAME%

echo CDD FILE: %CDD_FILE%
echo PROCESSING UNIT: %PU%
echo EAR FILE: %EAR_FILE%
echo AS DISCOVER URL: %AS_DISCOVER_URL%
echo AS LISTEN URL: %AS_LISTEN_URL%

set BE_PROPS_FILE="c:\tibco\be\application\beprops_all.props"

::Set more properties in the tra file.
echo tibco.env.CUSTOM_EXT_PREPEND_CP=c:\\tibco\\be\\ext>> %TRA_FILE%
echo tibco.class.path.extended %%CUSTOM_EXT_PREPEND_CP%%%%PSP%%%%STD_EXT_CP%%%%PSP%%%%CUSTOM_EXT_APPEND_CP%%%%PSP%%>> %TRA_FILE%
echo java.property.be.trace.log.dir=c:\\mnt\\tibco\\be\\logs>> %TRA_FILE%
echo java.property.be.engine.cluster.as.storePath=c:\\mnt\\tibco\\be\\data-store>> %TRA_FILE%
echo java.property.be.engine.jmx.connector.port=%%jmx_port%%>> %TRA_FILE%

if %DOCKER_HOST% EQU localhost (
	powershell -Command "Write-Host java.property.java.rmi.server.hostname=$((Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -ne \"Disconnected\" }).IPv4Address.IPAddress)">> %TRA_FILE%
)
if %DOCKER_HOST% NEQ localhost (
	echo java.property.java.rmi.server.hostname=%DOCKER_HOST%>> %TRA_FILE%
)
if NOT "%LOG_LEVEL%" == "na" echo java.property.be.trace.roles=%LOG_LEVEL%>> %TRA_FILE%

::beprops_all.props file
cd /d c:\\tibco\be
type NUL>%BE_PROPS_FILE%

for /r %%f in (*.props) do type %%f>>%BE_PROPS_FILE%

if defined CONSUL_SERVER_URL (
	call .\gvproviders\consul\run.bat
)
echo #BE props file>>%BE_PROPS_FILE%

::Append env variables starting with tra. to the current tra file and others to beprops file.
powershell -Command "Get-ChildItem Env: | Foreach-Object { if ($_.Name -like 'tra.*') {Add-Content -Path %TRA_FILE% -NoNewLine -Value $_.Name.Substring(1),=,$_.Value,`r`n} else {Add-Content -Path %BE_PROPS_FILE% -NoNewLine -Value tibco.clientVar.,$_.Name,=,$_.Value,`r`n} }"

::Update the Cdd File to replace all BE_HOME values with container's BE_HOME; correct the dataStore path.
powershell -Command "$prop = @(Select-String -Path '%CDD_FILE%' -Pattern '<property.*value=\""[a-z]\:' | Select-Object -First 1).Line.trim(); $start = $prop.LastIndexOf('value=\""')+7; $end=$prop.LastIndexOf('/be/'); $oldPath = $prop.Substring($start, $end-$start+7); (Get-Content '%CDD_FILE%') -replace $oldPath, '%BE_HOME%' | Set-Content '%CDD_FILE%'"
powershell -Command "(Get-Content '%CDD_FILE%') -replace '<data-store-path.*>', '<data-store-path>c:\mnt\tibco\be\data-store</data-store-path>' | Set-Content '%CDD_FILE%'"

cd /d c:\\tibco\be\application
echo Starting Application..
if "%AS_PROXY_NODE%" == "true" (
	echo java.property.be.engine.cluster.as.remote.listen.url=%AS_REMOTE_LISTEN_URL%>>%TRA_FILE%
	%BE_HOME%\bin\be-engine.exe --propFile %TRA_FILE% --propVar AS_DISCOVER_URL=%AS_DISCOVER_URL% --propVar AS_LISTEN_URL=%AS_LISTEN_URL% --propVar AS_REMOTE_LISTEN_URL=%AS_REMOTE_LISTEN_URL% --propVar jmx_port=%JMX_PORT% -n %ENGINE_NAME% -c %CDD_FILE% -u %PU% -p %BE_PROPS_FILE% %EAR_FILE%
)
if "%AS_PROXY_NODE%" == "false" (
	%BE_HOME%\bin\be-engine.exe --propFile %TRA_FILE% --propVar AS_DISCOVER_URL=%AS_DISCOVER_URL% --propVar AS_LISTEN_URL=%AS_LISTEN_URL% --propVar jmx_port=%JMX_PORT% -n %ENGINE_NAME% -c %CDD_FILE% -u %PU% -p %BE_PROPS_FILE% %EAR_FILE%
)
