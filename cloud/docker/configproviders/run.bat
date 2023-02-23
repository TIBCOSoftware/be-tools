@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

set CONFIGPROVIDER=na

if !CONFIGPROVIDER! EQU na (
  exit /b 0
)

set CPS=!CONFIGPROVIDER:,= !
for %%v in (!CPS!) do (
    SET CP=%%v

    SET GVFLAG=false

    if /i "%CP:~0,2%"=="gv" (
      SET GVFLAG=true
    )
    if /i "%CP:~0,8%"=="custom/gv" (
      SET GVFLAG=true
    )

    if !GVFLAG! EQU true (
      echo INFO: Reading GV values from [!CP!]

      set JSON_FILE=c:\tibco\be\configproviders\output.json
      set BE_PROPS_FILE=c:\tibco\be\application\beprops_all.props

      if EXIST !JSON_FILE! (
        del !JSON_FILE!
      )
      call .\configproviders\!CP!\run.bat
      if %ERRORLEVEL% NEQ 0 (
        exit /b 1
      )

      if EXIST !JSON_FILE! (
        (jq -r "keys | @csv" !JSON_FILE!) > jsonkeys

        set /p tempkeys=<jsonkeys
        set keys=!tempkeys:"=!
        
        echo # >>!BE_PROPS_FILE!
        echo # GV values from !CP!>>!BE_PROPS_FILE!
        
        if "!keys!" EQU "" (
          echo WARN: 0[zero] GV values fetched from the Config Provider[!CP!]
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
        echo WARN: 0[zero] GV values fetched from the Config Provider[!CP!]
        echo.
      )
    )

    if !GVFLAG! EQU false (
      echo INFO: Running Config Provider [!CP!]
      call .\configproviders\!CP!\run.bat
    )
)
