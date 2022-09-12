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
#         * ACTIONDB_USER
#         * ACTIONDB_PASSWORD
#
#     replace <SERVER> with the name of the server running the SQL Server instance.
#     replace <MSSQL_INSTANCENAME> with the name of the SQL Server instance.
#
#     if running the script against a SQL Server instance with a case sensitive server
#     collation, explicitly set a (case insensitive) collation to be used by the
#     database in the create_actionlog_db.sql file.
#
#     It is assumed that sqlcmd is in the path
#
# ---------------------------------------------------------------------------

# Set these variable to reflect the local environment:
CONNECTIDENTIFIER=<SERVER>\\<MSSQL_INSTANCENAME>
ADMINNAME=sa
ADMINPASSWORD=<ADMINPASSWORD>
ACTIONDB_NAME=spotfire_actionlog
ACTIONDB_USER=<ACTIONDB_USER>
ACTIONDB_PASSWORD=<ACTIONDB_PASSWORD>

# Make variables available to sqlcmd
export ACTIONDB_NAME ACTIONDB_USER ACTIONDB_PASSWORD

# Common error checking function
check_error()
{
  # Function.
  # Parameter 1 is the return code to check
  # Parameter 2 is the name of the SQL script run
  if [ "${1}" -ne "0" ]; then
    echo "Error while running SQL script '${2}'"
    echo "For more information consult the log (actionlog.txt) file"
    exit 1
  fi
}

# Create the actionlog tables
echo "Creating TIBCO Spotfire User Action Log tables"
sqlcmd -S "${CONNECTIDENTIFIER}" -U "${ADMINNAME}" -P "${ADMINPASSWORD}" -i create_actionlog_db.sql > actionlog.txt 2>&1
check_error $? create_actionlog_db.sql

# Create the Spotfire Action log database user
echo "Creating TIBCO Spotfire User Action Log database user"
sqlcmd -S "${CONNECTIDENTIFIER}" -U "${ADMINNAME}" -P "${ADMINPASSWORD}" -i create_actionlog_user_rds.sql >> actionlog.txt 2>&1
check_error $? create_actionlog_user_rds.sql

echo "----------------------------------------------------------------------"
echo "Please review the log file (actionlog.txt) for any errors or warnings!"
