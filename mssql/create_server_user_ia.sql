/*
 * Copyright (c) 2008-2015 Spotfire AB,
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
GO

/* Create login, comment out this if the login already exists */
use master
GO

CREATE LOGIN [$(WINDOWS_LOGIN_ACCOUNT)] FROM WINDOWS WITH DEFAULT_DATABASE=[$(SERVERDB_NAME)], DEFAULT_LANGUAGE=[us_english]
GO

ALTER LOGIN  [$(WINDOWS_LOGIN_ACCOUNT)] ENABLE
GO

DENY VIEW ANY DATABASE
TO  [$(WINDOWS_LOGIN_ACCOUNT)]
GO
/* done creating login */

use [$(SERVERDB_NAME)]
GO


/* Create the user, comment out the statement below if
 * the WINDOWS_LOGIN_ACCOUNT is the same as the user
 * running this script
 */
CREATE USER [$(SERVERDB_USER)] FOR LOGIN [$(WINDOWS_LOGIN_ACCOUNT)]
GO

GRANT CONTROL TO [$(SERVERDB_USER)]
GO
