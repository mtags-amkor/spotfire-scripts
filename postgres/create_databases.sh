#!/bin/sh
#
# This script will create all database schemas and fill them with all the initial data.
#
# Before using this script you need to set or change the following variables below:
#
#         * DB_HOST
#         * DBADMIN_PASSWORD
#         * SERVERDB_USER
#         * SERVERDB_PASSWORD
#
# it is assumed that the psql binary is in the PATH

# Set this variable to the hostname of the PostgreSQL instance
DB_HOST=<DB_HOST>

# Set these variables to the username and password of a database user
# with permissions to create users and databases
DBADMIN_NAME=postgres
DBADMIN_PASSWORD=<DBADMIN_PASSWORD>

# Set these variables to the name of the database to be created for the TIBCO Spotfire
# Server, and the user to be created for TIBCO Spotfire Server to access the database.
# Note that the password is entered here in plain text, you might want to delete
# any sensitive information once the script has been run.
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

# Create the table spaces and user
echo "Creating Spotfire Server database and user"
export PGPASSWORD=${DBADMIN_PASSWORD}
psql -h ${DB_HOST} -U ${DBADMIN_NAME} -f create_server_env.sql -v db_name=${SERVERDB_NAME} -v db_user=${SERVERDB_USER} -v db_pass=${SERVERDB_PASSWORD} > log.txt 2>&1
check_error $? create_server_env.sql

# Create the tables and fill them with initial data
echo "Creating TIBCO Spotfire Server tables"
export PGPASSWORD=${SERVERDB_PASSWORD}
psql -h ${DB_HOST} -U ${SERVERDB_USER} -d ${SERVERDB_NAME} -f create_server_db.sql >> log.txt 2>&1
check_error $? create_server_db.sql

echo "Populating TIBCO Spotfire Server tables"
psql -h ${DB_HOST} -U ${SERVERDB_USER} -d ${SERVERDB_NAME} -f populate_server_db.sql >> log.txt 2>&1
check_error $? populate_server_db.sql


echo "-----------------------------------------------------------------"
echo "Please review the log file (log.txt) for any errors or warnings!"
exit 0
