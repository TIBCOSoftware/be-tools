@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

if not defined GVP_HTTP_SERVER_URL (
  echo WARN: GV provider[http] is configured but env variable GVP_HTTP_SERVER_URL is empty OR not supplied.
  echo WARN: Skip fetching GV values from http end-store.
  EXIT /B 1
)

type NUL > c:\tibco\be\gvproviders\output.json
set JSON_FILE=c:\tibco\be\gvproviders\output.json

echo INFO: GVP_HTTP_SERVER_URL = %GVP_HTTP_SERVER_URL%

set HEADER=

if not defined GVP_HTTP_HEADERS (
  echo WARN: GVP_HTTP_HEADERS not specified.
) else (
  echo INFO: GVP_HTTP_HEADERS = %GVP_HTTP_HEADERS%
  set HEADER_VAL=%GVP_HTTP_HEADERS:"=%
  for %%i in ("%HEADER_VAL:,=" "%") do (
      set HEADER=!HEADER! -H %%i
  )
)

curl -X GET %HEADER% %GVP_HTTP_SERVER_URL% -o %JSON_FILE% 

endlocal
