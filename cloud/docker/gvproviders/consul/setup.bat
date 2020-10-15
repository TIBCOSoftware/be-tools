@echo off
@rem Copyright (c) 2019-2020. TIBCO Software Inc.
@rem This file is subject to the license terms contained in the license file that is distributed with this file.

setlocal EnableExtensions EnableDelayedExpansion

cd c:\tibco\be\gvproviders\consul

REM Download Consul cli and extract it.
powershell -Command "Invoke-WebRequest -Uri \"https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_windows_amd64.zip\" -OutFile consul_1.6.1_windows_amd64.zip"
powershell -Command "expand-archive -DestinationPath . consul_1.6.1_windows_amd64.zip"
del consul_1.6.1_windows_amd64.zip
