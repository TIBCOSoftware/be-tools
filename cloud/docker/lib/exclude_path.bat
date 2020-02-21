@echo off
@rem Copyright (c) 2019. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal enabledelayedexpansion

REM Script delete files not required to move

SET EXCLUDE_STRING=%1

for %%a in (%EXCLUDE_STRING%) do (
		del "%%a" /s /f /q 
		)  