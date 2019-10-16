@echo off

set BE_PROPS_FILE=c:\tibco\be\beprops_all.props

if not defined APP_CONFIG_PROFILE (
  set APP_CONFIG_PROFILE=default
)

if not defined BE_APP_NAME (
  echo ERROR: Cannot read GVs from Consul..
  echo ERROR: Specify env variable BE_APP_NAME, when specifying CONSUL_SERVER_URL.
  EXIT /B 1
)

echo INFO: CONSUL_SERVER_URL = %CONSUL_SERVER_URL%
REM echo INFO: BE_PROPS_FILE = %BE_PROPS_FILE%
echo INFO: BE_APP_NAME = %BE_APP_NAME%
echo INFO: APP_CONFIG_PROFILE = %APP_CONFIG_PROFILE%

REM skip prefix ($BE_APP_NAME/$APP_CONFIG_PROFILE/) from key
set PREFIX="%BE_APP_NAME%/%APP_CONFIG_PROFILE%/"
set CONSUL_EXECUTABLE=c:\tibco\be\gvproviders\consul\consul.exe

echo INFO: Reading GV values from Consul.. (%PREFIX%)
echo # GV values from Consul>>%BE_PROPS_FILE%
powershell -Command "%CONSUL_EXECUTABLE% kv export -http-addr=%CONSUL_SERVER_URL% %BE_APP_NAME%/%APP_CONFIG_PROFILE% | ConvertFrom-Json | foreach { $i = $_.key; foreach($k in $i) {Add-Content -Path %BE_PROPS_FILE% -NoNewLine -Value tibco.clientVar.,$k.substring('%PREFIX%'.length),=,$(%CONSUL_EXECUTABLE% kv get -http-addr=%CONSUL_SERVER_URL% $k),`r`n }}
echo.
