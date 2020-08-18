@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

echo INFO: Reading GV values..

type NUL > c:\tibco\be\output.json
set JSON_FILE=c:\tibco\be\output.json

if not defined HTTP_SERVER_URL (
  echo ERROR: Cannot read GVs from Consul..
  echo ERROR: Specify env variable HTTP_SERVER_URL
  EXIT /B 1
)

rem set HTTP_SERVER_URL=%2
echo INFO: HTTP_SERVER_URL = %HTTP_SERVER_URL%


if not defined HEADER_VALUES (
  echo ERROR: Cannot read GVs from Consul..
  echo ERROR: Specify env variable HEADER_VALUES
  EXIT /B 1
)

rem set HEADER_VALUES=%1
echo INFO: HEADER_VALUES = %HEADER_VALUES%

set HEADER=

set HEADER_VAL=%HEADER_VALUES:"=%

for %%i in ("%HEADER_VAL:,=" "%") do (
    set HEADER=!HEADER! -H %%i
)

curl -X GET %HEADER% %HTTP_SERVER_URL% -o %JSON_FILE% 

endlocal