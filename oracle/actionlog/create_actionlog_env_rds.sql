/*
 * Copyright (c) 2008-2016 Spotfire AB,
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
-- &1                   ACTIONDB_USER
-- &2                   ACTIONDB_PASSWORD
-- &3                   ACTION_DATA_TABLESPACE
-- &4                   ACTION_TEMP_TABLESPACE
--

WHENEVER SQLERROR EXIT FAILURE OR EXIT 1

CREATE TABLESPACE &3 LOGGING 
DATAFILE 
SIZE 400M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED
/

CREATE TEMPORARY TABLESPACE &4 
TEMPFILE 
SIZE 41472K AUTOEXTEND ON NEXT 20736K MAXSIZE 800M
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 20M
/

CREATE USER &1 IDENTIFIED BY &2
 DEFAULT TABLESPACE &3 
 TEMPORARY TABLESPACE &4 
 QUOTA UNLIMITED ON &3 
/

GRANT CREATE SESSION TO &1
/
GRANT CREATE TABLE TO &1
/
GRANT CREATE PROCEDURE TO &1
/
GRANT CREATE VIEW TO &1
/
GRANT QUERY REWRITE TO &1
/

EXIT
