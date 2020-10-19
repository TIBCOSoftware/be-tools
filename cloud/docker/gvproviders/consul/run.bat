@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

if not defined CONSUL_SERVER_URL (
  echo WARN: GV provider[consul] is configured but env variable CONSUL_SERVER_URL is empty OR not supplied.
  echo WARN: Skip fetching GV values from Consul.
  EXIT /B 1
)

type NUL > c:\tibco\be\gvproviders\output.json
set JSON_FILE=c:\tibco\be\gvproviders\output.json
type NUL > c:\tibco\be\temp.json
set TEMP_FILE=c:\tibco\be\temp.json


if not defined APP_CONFIG_PROFILE (
  set APP_CONFIG_PROFILE=default
)

if not defined BE_APP_NAME (
  echo ERROR: Cannot read GVs from Consul..
  echo ERROR: Specify env variable BE_APP_NAME, when specifying CONSUL_SERVER_URL.
  EXIT /B 1
)

echo INFO: CONSUL_SERVER_URL = %CONSUL_SERVER_URL%
echo INFO: BE_APP_NAME = %BE_APP_NAME%
echo INFO: APP_CONFIG_PROFILE = %APP_CONFIG_PROFILE%

set PREFIX="%BE_APP_NAME%/%APP_CONFIG_PROFILE%/"
set CONSUL_EXECUTABLE=c:\tibco\be\gvproviders\consul\consul.exe

echo INFO: Reading GV values from Consul.. (%PREFIX%)

type NUL > c:\tibco\be\consulval.json
set CONSUL_RESULT=c:\tibco\be\consulval.json

powershell -Command "%CONSUL_EXECUTABLE% kv export -http-addr=%CONSUL_SERVER_URL% %BE_APP_NAME%/%APP_CONFIG_PROFILE% | ConvertFrom-Json | foreach { $i = $_.key; foreach($k in $i) {Add-Content -Path %CONSUL_RESULT% -NoNewLine -Value $k.substring('%PREFIX%'.length),=,$(%CONSUL_EXECUTABLE% kv get -http-addr=%CONSUL_SERVER_URL% $k),',' }}

set /p CONSULVAL=<%CONSUL_RESULT%

set "CONSULVAL=%CONSULVAL:~2,-1%"


echo { >> %TEMP_FILE%

  for %%i in (%CONSULVAL%) do (
    if not defined varname (
      set varname=%%i
    ) else (
      echo ^"!varname!^":^"%%i^", >> %TEMP_FILE%
      set "varname="
    )
  )

set OUTPUTVAL=

for /F "delims=" %%j in (%TEMP_FILE%) do set OUTPUTVAL=!OUTPUTVAL!%%j

set "OUTPUTVAL=%OUTPUTVAL:~0,-2%"

>"%JSON_FILE%" echo(%OUTPUTVAL%

echo } >> %JSON_FILE%

echo.
