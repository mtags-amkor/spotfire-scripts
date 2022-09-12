@echo off
setlocal

rem ---------------------------------------------------------------------------
rem
rem This script will create all database schemas and fill them with all the initial data.
rem
rem Before using this script you need to set or change the following variables below:
rem         * CONNECTIDENTIFIER
rem         * ADMINNAME
rem         * ADMINPASSWORD
rem         * ACTIONDB_PASSWORD
rem
rem ---------------------------------------------------------------------------

rem Set these variable to reflect the local environment:
set CONNECTIDENTIFIER=<//localhost/pdborcl.example.com>
set ADMINNAME=<system>
set ADMINPASSWORD=<ADMINPASSWORD>
set ACTIONDB_USER=spotfire_actionlog
set ACTIONDB_PASSWORD=<ACTIONDB_PASSWORD>
set ACTION_DATA_TABLESPACE=SPOTFIRE_ACTION_DATA
set ACTIONDB_TEMP_TABLESPACE=SPOTFIRE_ACTION_TEMP

rem Create the tablespaces and user
@echo Creating Spotfire Action table spaces and user
sqlplus %ADMINNAME%/%ADMINPASSWORD%@%CONNECTIDENTIFIER%  @create_actionlog_env_rds.sql "%ACTIONDB_USER%" "%ACTIONDB_PASSWORD%" "%ACTION_DATA_TABLESPACE%" "%ACTIONDB_TEMP_TABLESPACE%" > actionlog.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_actionlog_env.sql'
  @echo For more information consult the actionlog.txt file
  exit /B 1
)

rem Create the tables and fill them with initial data
@echo Creating Spotfire Action log tables
sqlplus %ACTIONDB_USER%/%ACTIONDB_PASSWORD%@%CONNECTIDENTIFIER% @create_actionlog_db.sql >> actionlog.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_actionlog_db.sql'
  @echo For more information consult the actionlog.txt file
  exit /B 1
)


@echo -----------------------------------------------------------------
@echo Please review the log file (actionlog.txt) for any errors or warnings!
endlocal
