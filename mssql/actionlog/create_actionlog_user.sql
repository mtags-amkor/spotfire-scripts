/*
 * Copyright (c) 2008-2012 Spotfire AB,
 * Första Långgatan 26, SE-413 28 Göteborg, Sweden.
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Spotfire AB ("Confidential Information"). You shall not
 * disclose such Confidential Information and may not use it in any way,
 * absent an express written license agreement between you and Spotfire AB
 * or TIBCO Software Inc. that authorizes such use.
 */

:on ERROR EXIT
go

/* spotfire_server */
use master
go

CREATE LOGIN  $(ACTIONDB_USER) WITH PASSWORD=N'$(ACTIONDB_PASSWORD)', DEFAULT_DATABASE=[$(ACTIONDB_NAME)], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER LOGIN  $(ACTIONDB_USER) ENABLE
GO

DENY VIEW ANY DATABASE
TO  $(ACTIONDB_USER)

use [$(ACTIONDB_NAME)]
GO

CREATE USER  $(ACTIONDB_USER)

GRANT CONTROL TO  $(ACTIONDB_USER)
GO
