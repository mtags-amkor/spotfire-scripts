@echo off
setlocal

rem ---------------------------------------------------------------------------
rem
rem This script will create all database schemas and fill them with all the initial data.
rem
rem Before using this script you need to set or change the following variables below:
rem         * SERVER
rem         * MSSQL_INSTANCENAME
rem         * ADMINPASSWORD
rem         * ACTIONDB_USER
rem         * ACTIONDB_PASSWORD
rem
rem     replace <SERVER> with the name of the server running the SQL Server instance.
rem     replace <MSSQL_INSTANCENAME> with the name of the SQL Server instance.
rem
rem     if running the script against a SQL Server instance with a case sensitive server 
rem     collation, explicitly set a (case insensitive) collation to be used by the 
rem     database in the create_actionlog_db.sql file.
rem
rem ---------------------------------------------------------------------------

rem Set these variable to reflect the local environment:
set CONNECTIDENTIFIER=<SERVER>\<MSSQL_INSTANCENAME>
set ADMINNAME=sa
set ADMINPASSWORD=<ADMINPASSWORD>
set ACTIONDB_NAME=spotfire_actionlog
set ACTIONDB_USER=<ACTIONDB_USER>
set ACTIONDB_PASSWORD=<ACTIONDB_PASSWORD>

rem Create the actionlog tables
@echo Creating TIBCO Spotfire User Action Log tables
sqlcmd -S%CONNECTIDENTIFIER% -U%ADMINNAME% -P%ADMINPASSWORD% -i create_actionlog_db.sql -v ACTIONDB_NAME="%ACTIONDB_NAME%" > actionlog.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_actionlog_db.sql'
  @echo For more information consult the actionlog.txt file
  exit /B 1
)

rem Create the Spotfire Action log database user
@echo Creating TIBCO Spotfire User Action Log database user
sqlcmd -S%CONNECTIDENTIFIER% -U%ADMINNAME% -P%ADMINPASSWORD% -i create_actionlog_user.sql -v ACTIONDB_NAME="%ACTIONDB_NAME%" ACTIONDB_USER="%ACTIONDB_USER%" ACTIONDB_PASSWORD="%ACTIONDB_PASSWORD%" >> actionlog.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_actionlog_user.sql'
  @echo For more information consult the actionlog.txt file
  exit /B 1
)

@echo -----------------------------------------------------------------
@echo Please review the log file (actionlog.txt) for any errors or warnings!
endlocal
