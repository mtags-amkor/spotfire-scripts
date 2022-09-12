#!/bin/sh
#
# This script will create the User Action Log schema.
#
# Before using this script you need to you need to set or change the following variables below:
#         * CONNECTIDENTIFIER
#         * ADMINNAME
#         * ADMINPASSWORD
#         * ACTIONDB_PASSWORD
#

# Set these variables to reflect the local environment:
CONNECTIDENTIFIER=<//localhost/pdborcl.example.com>
ADMINNAME=<system>
ADMINPASSWORD=<ADMINPASSWORD>
ACTIONDB_USER=spotfire_actionlog
ACTIONDB_PASSWORD=<ACTIONDB_PASSWORD>
ACTIONDB_DATA_TABLESPACE=SPOTFIRE_ACTION_DATA
ACTIONDB_TEMP_TABLESPACE=SPOTFIRE_ACTION_TEMP

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

# Create the User Action Log database and user
echo "Creating TIBCO Spotfire User Action Log database and user"
sqlplus ${ADMINNAME}/${ADMINPASSWORD}@${CONNECTIDENTIFIER} @create_actionlog_env_rds.sql  "${ACTIONDB_USER}" "${ACTIONDB_PASSWORD}" "${ACTIONDB_DATA_TABLESPACE}" "${ACTIONDB_TEMP_TABLESPACE}" > actionlog.txt
check_error $? create_actionlog_env.sql

# Create the User Action Log table
echo "Creating TIBCO Spotfire User Action log tables"
sqlplus ${ACTIONDB_USER}/${ACTIONDB_PASSWORD}@${CONNECTIDENTIFIER} @create_actionlog_db.sql >> actionlog.txt
check_error $? create_actionlog_db.sql

echo "----------------------------------------------------------------------"
echo "Please review the log file (actionlog.txt) for any errors or warnings!"
exit 0
