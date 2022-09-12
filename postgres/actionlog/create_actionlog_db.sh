#!/bin/sh
#
# This script will create the User Action Log schema.
#
# Before using this script you need to you need to set or change the following variables below:
#         * DB_HOST
#         * DBADMIN_PASSWORD
#         * ACTIONDB_PASSWORD
#
# it is assumed that the psql binary is in the PATH

# Set this variable to the hostname of the PostgreSQL instance
DB_HOST=<DB_HOST>

# Set these variables to the username and password of a database user
# with permissions to create users and databases
DBADMIN_NAME=postgres
DBADMIN_PASSWORD=<DBADMIN_PASSWORD>

# Change these variables 
ACTIONDB_NAME=spotfire_actionlog
ACTIONDB_USER=spotfire_actionlog
ACTIONDB_PASSWORD=<ACTIONDB_PASSWORD>

# Common error checking function
check_error()
{
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
export PGPASSWORD=${DBADMIN_PASSWORD}
psql -h ${DB_HOST} -U ${DBADMIN_NAME} -f create_actionlog_env.sql -v db_name=${ACTIONDB_NAME} -v db_user=${ACTIONDB_USER} -v db_pass=${ACTIONDB_PASSWORD} > actionlog.txt
check_error $? create_actionlog_env.sql

# Create the User Action Log table
echo "Creating TIBCO Spotfire User Action Log tables"
export PGPASSWORD=${ACTIONDB_PASSWORD}
psql -h ${DB_HOST} -U ${ACTIONDB_USER} -d ${ACTIONDB_NAME} -f create_actionlog_db.sql >> actionlog.txt
check_error $? create_actionlog_db.sql

echo "----------------------------------------------------------------------"
echo "Please review the log file (actionlog.txt) for any errors or warnings!"
exit 0
