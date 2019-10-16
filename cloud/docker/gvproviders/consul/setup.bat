@echo off

setlocal EnableExtensions EnableDelayedExpansion

echo Setting up consul gv provider..

cd c:\tibco\be\gvproviders\consul

REM Download Consul cli and extract it.
powershell -Command "Invoke-WebRequest -Uri \"https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_windows_amd64.zip\" -OutFile consul_1.6.1_windows_amd64.zip"
powershell -Command "expand-archive -DestinationPath . consul_1.6.1_windows_amd64.zip"
del consul_1.6.1_windows_amd64.zip
