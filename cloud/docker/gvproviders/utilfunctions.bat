@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

set GVPROVIDER=%1

call .\gvproviders\!GVPROVIDER!\run.bat

(jq -r "keys | @csv" output.json) > jsonkeys

set /p tempkeys=<jsonkeys

set keys=%tempkeys:"=%


set BE_PROPS_FILE="c:\tibco\be\application\beprops_all.props"

echo #Latest GV values>>%BE_PROPS_FILE%


 for %%a in ("%keys:,=" "%") do (
   set key=%%~a
   (jq -r .%%~a output.json) > values
   set /p value=<values
   echo tibco.clientVar.!key!=!value! >> %BE_PROPS_FILE%
 )

 (jq -r 'to_entries[] | "tibco.clientVar.\(.key)=\(.value)"' output.json) >> $BE_PROPS_FILE

del jsonkeys values
