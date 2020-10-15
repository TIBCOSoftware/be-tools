@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

set GVPROVIDER=na

if !GVPROVIDER! EQU na (
  exit /b 0
)

call .\gvproviders\!GVPROVIDER!\run.bat
if %ERRORLEVEL% NEQ 0 (
  exit /b 1
)

set JSON_FILE=c:\tibco\be\gvproviders\output.json
set BE_PROPS_FILE=c:\tibco\be\application\beprops_all.props

if EXIST !JSON_FILE! (
  (jq -r "keys | @csv" !JSON_FILE!) > jsonkeys

  set /p tempkeys=<jsonkeys
  set keys=!tempkeys:"=!
  
  echo # GV values from !GVPROVIDER!>>!BE_PROPS_FILE!
  
  for %%a in (!keys!) do (
    set key=%%~a
    (jq -r .%%~a !JSON_FILE!) > values
    set /p value=<values
    echo tibco.clientVar.!key!=!value! >> !BE_PROPS_FILE!
  )

  del jsonkeys values
)
