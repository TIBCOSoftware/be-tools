@echo off

setlocal EnableExtensions EnableDelayedExpansion

REM setup the gv providers
set gvproviders=%1
powershell -Command "if ('%gvproviders%'.Contains(\"consul\")) { c:\tibco\be\gvproviders\consul\setup.bat }"
