#!/bin/sh
#
# This script will create all database schemas and fill them with all the initial data.
#
# Before using this script you need to you need to set or change the following variables below:
#         * CONNECTIDENTIFIER
#         * ADMINNAME
#         * ADMINPASSWORD
#         * SERVERDB_USER
#         * SERVERDB_PASSWORD
#
#

# Set these variable to reflect the local environment:

# A connect identifier to the container database or the pluggable database
# for a pluggable database a service name like //localhost/pdborcl.example.com
# could be the SID, TNSNAME etc, see the documentation for sqlplus
CONNECTIDENTIFIER=<//localhost/pdborcl.example.com>

# a username and password for an administrator in this (pluggable) database
ADMINNAME=<system>
ADMINPASSWORD=<ADMINPASSWORD>

# Username and password for the Spotfire instance this user will be created,
# remember that the password is written here in cleartext,
# you might want to delete this sensitive info once the script is run
SERVERDB_USER=<SERVERDB_USER>
SERVERDB_PASSWORD=<SERVERDB_PASSWORD>

# The spotfire tablespaces, alter if you want to run multiple instances in the same database
SERVER_DATA_TABLESPACE=SPOTFIRE_DATA
SERVER_TEMP_TABLESPACE=SPOTFIRE_TEMP

# end of the variables

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
echo "Creating Spotfire Server table spaces and user"
sqlplus ${ADMINNAME}/${ADMINPASSWORD}@${CONNECTIDENTIFIER} @create_server_env_rds.sql "${SERVERDB_USER}" "${SERVERDB_PASSWORD}" "${SERVER_DATA_TABLESPACE}" "${SERVER_TEMP_TABLESPACE}" > log.txt
check_error $? create_server_env_rds.sql 

# Create the tables and fill them with initial data
echo "Creating Spotfire Server tables"
sqlplus ${SERVERDB_USER}/${SERVERDB_PASSWORD}@${CONNECTIDENTIFIER} @create_server_db.sql >> log.txt
check_error $? create_server_db.sql

echo "Populating Spotfire Server tables"
sqlplus ${SERVERDB_USER}/${SERVERDB_PASSWORD}@${CONNECTIDENTIFIER} @populate_server_db.sql >> log.txt
check_error $? populate_server_db.sql

echo "-----------------------------------------------------------------"
echo "Please review the log file (log.txt) for any errors or warnings!"
exit 0
