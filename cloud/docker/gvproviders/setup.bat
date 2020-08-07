@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

REM setup the gv providers
set gvproviders=%1
powershell -Command "if ('%gvproviders%'.Contains(\"consul\")) { c:\tibco\be\gvproviders\consul\setup.bat }"
