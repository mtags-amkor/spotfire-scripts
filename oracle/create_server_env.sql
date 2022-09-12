/*
 * Copyright (c) 2008-2013 Spotfire AB,
 * Första Långgatan 26, SE-413 28 Göteborg, Sweden.
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Spotfire AB ("Confidential Information"). You shall not
 * disclose such Confidential Information and may not use it in any way,
 * absent an express written license agreement between you and Spotfire AB
 * or TIBCO Software Inc. that authorizes such use.
 */

--
-- This script creates an Oracle database user for
-- use with TIBCO Spotfire Server.
--
-- Optionally you may modify the following names:
--     the tablespaces SPOTFIRE_DATA and SPOTFIRE_TEMP
--
-- Parameters:
--
-- &1                   The ROOTFOLDER file system path
-- &2                   SERVERDB_USER
-- &3                   SERVERDB_PASSWORD
-- &4                   SERVER_DATA_TABLESPACE
-- &5                   SERVER_TEMP_TABLESPACE
--

WHENEVER SQLERROR EXIT FAILURE

CREATE TABLESPACE &4 LOGGING 
DATAFILE '&1/&4..dbf'
SIZE 400M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED
/

CREATE TEMPORARY TABLESPACE &5 
TEMPFILE '&1/&5..dbf'
SIZE 41472K AUTOEXTEND ON NEXT 20736K MAXSIZE 800M
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 20M
/

CREATE USER &2 IDENTIFIED BY &3
 DEFAULT TABLESPACE &4 
 TEMPORARY TABLESPACE &5 
 QUOTA UNLIMITED ON &4 
/

GRANT CREATE SESSION TO &2
/
GRANT CREATE TABLE TO &2
/
GRANT CREATE PROCEDURE TO &2
/
GRANT CREATE VIEW TO &2
/
GRANT QUERY REWRITE TO &2
/

EXIT
