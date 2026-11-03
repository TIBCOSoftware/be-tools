@echo off
@rem Entrypoint of the Quarkus RMS image (native installer, BE 7.0.0 and above).
@rem
@rem RMS is configured through properties files in its instance directory (RMS_INSTANCE_DIR). Environment variables
@rem outrank those files, so a container is normally configured with them alone:
@rem
@rem   RMS_DB_HOST [RMS_DB_PORT=5432] [RMS_DB_NAME=rms]   PostgreSQL to use (builds the JDBC URL)
@rem   RMS_DB_USER, RMS_DB_PASSWORD                       database credentials
@rem   QUARKUS_DATASOURCE_JDBC_URL, _USERNAME, _PASSWORD  same values in Quarkus form; these win over the RMS_DB_* ones
@rem   RMS_BOOTSTRAP_ADMIN_USERNAME, _EMAIL, _PASSWORD    first administrator
@rem   QUARKUS_HTTP_HOST                                  listen address, 0.0.0.0 unless set
@rem   any other Quarkus/RMS key, e.g. RMS_UI_BASE_URL for rms.ui.base-url
@rem
@rem On first start with an empty instance directory the image's seed is copied in, and be-rms-server init generates this
@rem container's JWT signing key pair and token-encryption key. Keep the instance directory on a volume: those keys decrypt
@rem the Git credentials RMS stores in its database, so losing them strands every stored credential.
setlocal

if "%BE_SHORT_VERSION%" EQU "" (
	echo ERROR: BE_SHORT_VERSION is not set.
	exit /b 1
)
if "%RMS_INSTANCE_DIR%" EQU "" set "RMS_INSTANCE_DIR=c:\tibco\rms-instance\be\%BE_SHORT_VERSION%"
if "%RMS_INSTANCE_SEED_DIR%" EQU "" set "RMS_INSTANCE_SEED_DIR=c:\tibco\rms-instance-seed"
@rem xcopy does not take forward slashes, which the image ENV values use
set "RMS_INSTANCE_DIR=%RMS_INSTANCE_DIR:/=\%"
set "RMS_INSTANCE_SEED_DIR=%RMS_INSTANCE_SEED_DIR:/=\%"
set "RMS_BE_HOME=c:\tibco\be\%BE_SHORT_VERSION%"
set "LAUNCHER=%RMS_BE_HOME%\rms-server\bin\be-rms-server.bat"
set "CONF_DIR=%RMS_INSTANCE_DIR%\config"

if not exist "%LAUNCHER%" (
	echo ERROR: RMS launcher %LAUNCHER% not found. This is not a BE 7.0.0+ native-installer RMS image.
	exit /b 1
)

if not exist "%CONF_DIR%\application.properties" (
	echo INFO: Seeding RMS instance directory %RMS_INSTANCE_DIR% from %RMS_INSTANCE_SEED_DIR%
	xcopy /E /I /Y /Q "%RMS_INSTANCE_SEED_DIR%" "%RMS_INSTANCE_DIR%" > NUL
	if errorlevel 1 (
		echo ERROR: Could not seed %RMS_INSTANCE_DIR%.
		exit /b 1
	)
)

@rem A secrets file that still holds an installer placeholder on a non-comment line has no keys yet. init refuses (exit 3) to overwrite keys
@rem that exist, so this never regenerates them.
findstr /R /C:"^[^#]*@@" "%CONF_DIR%\rms-secrets.properties" > NUL 2>&1
if errorlevel 1 goto :KeysReady
call :GenerateKeys
if errorlevel 1 exit /b %ERRORLEVEL%
:KeysReady

@rem The shipped config binds to 127.0.0.1, which is unreachable from outside a container.
if "%QUARKUS_HTTP_HOST%" EQU "" set "QUARKUS_HTTP_HOST=0.0.0.0"

if "%RMS_DB_PORT%" EQU "" set "RMS_DB_PORT=5432"
if "%RMS_DB_NAME%" EQU "" set "RMS_DB_NAME=rms"
if "%RMS_DB_HOST%" NEQ "" if "%QUARKUS_DATASOURCE_JDBC_URL%" EQU "" set "QUARKUS_DATASOURCE_JDBC_URL=jdbc:postgresql://%RMS_DB_HOST%:%RMS_DB_PORT%/%RMS_DB_NAME%?options=-c%%20TimeZone%%3DUTC"
if "%RMS_DB_USER%" NEQ "" if "%QUARKUS_DATASOURCE_USERNAME%" EQU "" set "QUARKUS_DATASOURCE_USERNAME=%RMS_DB_USER%"
if "%RMS_DB_PASSWORD%" NEQ "" if "%QUARKUS_DATASOURCE_PASSWORD%" EQU "" set "QUARKUS_DATASOURCE_PASSWORD=%RMS_DB_PASSWORD%"

@rem Maven, which RMS forks, needs JAVA_HOME. Use the bundled JRE: the highest numeric folder under jrehome.
if "%JAVA_HOME%" EQU "" for /d %%d in (c:\tibco\jrehome\*) do if exist "%%d\bin\java.exe" set "JAVA_HOME=%%d"

@rem RMS forks Maven for EAR builds. Maven is installed in the image, and the installer merged the offline repository into
@rem the installing user's profile, which a container user does not share, so point Maven at the one inside the BE home.
set "PATH=c:\maven\bin;%PATH%"
if "%MAVEN_ARGS%" EQU "" if exist "%RMS_BE_HOME%\maven\m2-repo" set "MAVEN_ARGS=-Dmaven.repo.local=%RMS_BE_HOME%\maven\m2-repo"

call "%LAUNCHER%" run
exit /b %ERRORLEVEL%

:GenerateKeys
echo INFO: Generating RMS key material
call "%LAUNCHER%" init
set "INIT_EXIT=%ERRORLEVEL%"
if "%INIT_EXIT%" EQU "0" exit /b 0
if "%INIT_EXIT%" EQU "3" exit /b 0
echo ERROR: be-rms-server init failed with exit code %INIT_EXIT%.
exit /b %INIT_EXIT%
