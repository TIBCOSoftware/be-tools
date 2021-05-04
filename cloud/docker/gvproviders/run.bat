@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

set GVPROVIDER=na

if !GVPROVIDER! EQU na (
  exit /b 0
)

set GVS=!GVPROVIDER:,= !
for %%v in (!GVS!) do (
    SET GV=%%v
    echo INFO: Reading GV values from [!GV!]

    set JSON_FILE=c:\tibco\be\gvproviders\output.json
    set BE_PROPS_FILE=c:\tibco\be\application\beprops_all.props

    if EXIST !JSON_FILE! (
      del !JSON_FILE!
    )
    call .\gvproviders\!GV!\run.bat
    if %ERRORLEVEL% NEQ 0 (
      exit /b 1
    )

    if EXIST !JSON_FILE! (
      (jq -r "keys | @csv" !JSON_FILE!) > jsonkeys

      set /p tempkeys=<jsonkeys
      set keys=!tempkeys:"=!
      
      echo # >>!BE_PROPS_FILE!
      echo # GV values from !GV!>>!BE_PROPS_FILE!
      
      if "!keys!" EQU "" (
        echo WARN: 0[zero] GV values fetched from the GV provider[!GV!]
        echo.
        exit /b 0
      )

      for %%a in (!keys!) do (
        set key=%%~a
        (jq -r .\"%%~a\" !JSON_FILE!) > values
        set /p value=<values
        echo tibco.clientVar.!key!=!value! >> !BE_PROPS_FILE!
      )

      del jsonkeys values
    ) else (
      echo WARN: 0[zero] GV values fetched from the GV provider[!GV!]
      echo.
    )
)
