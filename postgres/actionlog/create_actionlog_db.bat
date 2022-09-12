@echo off
setlocal

rem ---------------------------------------------------------------------------
rem
rem This script will create all database schemas and fill them with all the initial data.
rem
rem Before using this script you need to set or change the following variables below:
rem         * DB_HOST
rem         * DBADMIN_PASSWORD
rem         * ACTIONDB_PASSWORD
rem         * PSQL_PATH
rem
rem ---------------------------------------------------------------------------

rem Set these variable to reflect the local environment:
set DBADMIN_NAME=postgres
set DBADMIN_PASSWORD=<DBADMIN_PASSWORD>
set DB_HOST=<DB_HOST>

rem Username and password for the actionlog database. This user will be created,
rem note that the password is written here in cleartext, you might want to delete
rem any sensitive information once the script has been run.
set ACTIONDB_NAME=spotfire_actionlog
set ACTIONDB_USER=spotfire_actionlog
set ACTIONDB_PASSWORD=<ACTIONDB_PASSWORD>

rem Where is the path to the bin directory of the PostgreSQL installation
rem where the psql.exe binary is installed
set PSQL_PATH=<PSQL_PATH>

rem Create the User Action Log database and user
@echo Creating TIBCO Spotfire User Action Log database and user
set PGPASSWORD=%DBADMIN_PASSWORD%
"%PSQL_PATH%\psql" -h %DB_HOST% -U %DBADMIN_NAME% -f create_actionlog_env.sql -v db_name=%ACTIONDB_NAME% -v db_user=%ACTIONDB_USER% -v db_pass=%ACTIONDB_PASSWORD% > actionlog.txt  2>&1
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_actionlog_env.sql'
  @echo For more information consult the actionlog.txt file
  exit /B 1
)

rem Create the User Action Log table
@echo Creating TIBCO Spotfire User Action Log tables
set PGPASSWORD=%ACTIONDB_PASSWORD%
"%PSQL_PATH%\psql" -h %DB_HOST% -U %ACTIONDB_USER% -d %ACTIONDB_NAME% -f create_actionlog_db.sql >> actionlog.txt 2>&1
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_actionlog_db.sql'
  @echo For more information consult the actionlog.txt file
  exit /B 1
)

@echo -----------------------------------------------------------------
@echo Please review the log file (actionlog.txt) for any errors or warnings!
endlocal
