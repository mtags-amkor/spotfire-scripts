#!/bin/sh
#
# ---------------------------------------------------------------------------
#
# This script will create all database schemas and fill them with all the initial data.
#
# Before using this script you need to set or change the following variables below:
#         * SERVER
#         * MSSQL_INSTANCENAME
#         * ADMINPASSWORD
#         * SERVERDB_USER
#         * SERVERDB_PASSWORD
#
#     replace <SERVER> with the name of the server running the SQL Server instance.
#     replace <MSSQL_INSTANCENAME> with the name of the SQL Server instance.
#
#     if running the script against a SQL Server instance with a case sensitive server
#     collation, explicitly set a (case insensitive) collation to be used by the
#     database in the create_server_db.sql file.
#
#     It is assumed that sqlcmd is in the path
#
# ---------------------------------------------------------------------------

CONNECTIDENTIFIER=<SERVER>\\<MSSQL_INSTANCENAME>
ADMINNAME=sa
ADMINPASSWORD=<ADMINPASSWORD>
SERVERDB_NAME=spotfire_server
SERVERDB_USER=<SERVERDB_USER>
SERVERDB_PASSWORD=<SERVERDB_PASSWORD>

# Common error checking function
check_error()
{
  # Function.
  # Parameter 1 is the return code to check
  # Parameter 2 is the name of the SQL script run
  if [ "${1}" -ne "0" ]; then
    echo "Error while running SQL script '${2}'"
    echo "For more information consult the log (log.txt) file"
    exit 1
  fi
}

# Make variables available to sqlcmd
export SERVERDB_NAME SERVERDB_USER SERVERDB_PASSWORD

# Create the server tables
echo "Creating TIBCO Spotfire Server tables"
sqlcmd -S "${CONNECTIDENTIFIER}" -U "${ADMINNAME}" -P "${ADMINPASSWORD}" -i create_server_db.sql > log.txt 2>&1
check_error $? create_server_db.sql

# Fill server tables with data
echo "Populating TIBCO Spotfire Server tables"
sqlcmd -S "${CONNECTIDENTIFIER}" -U "${ADMINNAME}" -P "${ADMINPASSWORD}" -i populate_server_db.sql >> log.txt 2>&1
check_error $? populate_server_db.sql

# Create the Spotfire Server database user
echo "Creating TIBCO Spotfire Server database user"
sqlcmd -S "${CONNECTIDENTIFIER}" -U "${ADMINNAME}" -P "${ADMINPASSWORD}" -i create_server_user_rds.sql >> log.txt 2>&1
check_error $? create_server_user_rds.sql

echo "-----------------------------------------------------------------"
echo "Please review the log file (log.txt) for any errors or warnings!"
exit 0
