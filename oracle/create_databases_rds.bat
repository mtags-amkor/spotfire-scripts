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
rem         * SERVERDB_USER
rem         * SERVERDB_PASSWORD
rem
rem ---------------------------------------------------------------------------

rem Set these variable to reflect the local environment:

rem A connect identifier to the container database or the pluggable database
rem for a pluggable database  a service name like //localhost/pdborcl.example.com
rem could be the SID, TNSNAME etc, see the documentation for sqlplus
set CONNECTIDENTIFIER=<//localhost/pdborcl.example.com>

rem a username and password for an administrator in this (pluggable) database
set ADMINNAME=<system>
set ADMINPASSWORD=<ADMINPASSWORD>

rem Username and password for the Spotfire instance this user will be created,
rem remember that the password is written here in cleartext,
rem you might want to delete this sensitive info once the script is run
set SERVERDB_USER=<SERVERDB_USER>
set SERVERDB_PASSWORD=<SERVERDB_PASSWORD>

rem The spotfire tablespaces, alter if you want to run multiple instances in the same database
set SERVER_DATA_TABLESPACE=SPOTFIRE_DATA
set SERVER_TEMP_TABLESPACE=SPOTFIRE_TEMP
rem end of the variables

rem Create the tablespaces and user
@echo Creating Spotfire Server table spaces and user
sqlplus %ADMINNAME%/%ADMINPASSWORD%@%CONNECTIDENTIFIER% @create_server_env_rds.sql "%SERVERDB_USER%" "%SERVERDB_PASSWORD%" "%SERVER_DATA_TABLESPACE%" "%SERVER_TEMP_TABLESPACE%" > log.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_server_env_rds.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

rem Create the tables and fill them with initial data
@echo Creating Spotfire Server tables
sqlplus %SERVERDB_USER%/%SERVERDB_PASSWORD%@%CONNECTIDENTIFIER% @create_server_db.sql >> log.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_server_db.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

@echo Populating Spotfire Server tables
sqlplus %SERVERDB_USER%/%SERVERDB_PASSWORD%@%CONNECTIDENTIFIER% @populate_server_db.sql >> log.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'populate_server_db.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

@echo -----------------------------------------------------------------
@echo Please review the log file (log.txt) for any errors or warnings!
endlocal
