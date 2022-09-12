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
rem         * SERVERDB_USER
rem         * SERVERDB_PASSWORD
rem
rem     replace <SERVER> with the name of the server running the SQL Server instance.
rem     replace <MSSQL_INSTANCENAME> with the name of the SQL Server instance.
rem
rem     if running the script against a SQL Server instance with a case sensitive server 
rem     collation, explicitly set a (case insensitive) collation to be used by the 
rem     database in the create_server_db.sql file.
rem
rem ---------------------------------------------------------------------------

rem Set these variable to reflect the local environment:
set CONNECTIDENTIFIER=<SERVER>\<MSSQL_INSTANCENAME>
set ADMINNAME=sa
set ADMINPASSWORD=<ADMINPASSWORD>
set SERVERDB_NAME=spotfire_server
set SERVERDB_USER=<SERVERDB_USER>
set SERVERDB_PASSWORD=<SERVERDB_PASSWORD>

rem Create the server tables
@echo Creating TIBCO Spotfire Server tables
sqlcmd -S%CONNECTIDENTIFIER% -U%ADMINNAME% -P%ADMINPASSWORD% -i create_server_db.sql -v SERVERDB_NAME="%SERVERDB_NAME%" > log.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_server_db.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

rem Fill server tables with data
@echo Populating TIBCO Spotfire Server tables
sqlcmd -S%CONNECTIDENTIFIER% -U%ADMINNAME% -P%ADMINPASSWORD% -i populate_server_db.sql -v SERVERDB_NAME="%SERVERDB_NAME%" >> log.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'populate_server_db.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

rem Create the Spotfire Server database user
@echo Creating TIBCO Spotfire Server database user
sqlcmd -S%CONNECTIDENTIFIER% -U%ADMINNAME% -P%ADMINPASSWORD% -i create_server_user_rds.sql -v SERVERDB_NAME="%SERVERDB_NAME%" SERVERDB_USER="%SERVERDB_USER%" SERVERDB_PASSWORD="%SERVERDB_PASSWORD%" >> log.txt 
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_server_user_rds.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

@echo -----------------------------------------------------------------
@echo Please review the log file (log.txt) for any errors or warnings!
endlocal
