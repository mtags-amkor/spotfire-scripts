/*
 * Copyright (c) 2008-2021 Spotfire AB,
 * Första Långgatan 26, SE-413 28 Göteborg, Sweden.
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Spotfire AB ("Confidential Information"). You shall not
 * disclose such Confidential Information and may not use it in any way,
 * absent an express written license agreement between you and Spotfire AB
 * or TIBCO Software Inc. that authorizes such use.
 */

-- ================================
--  Report errors
-- ================================

WHENEVER SQLERROR EXIT FAILURE

-- ================================
--      Create Database Schema
-- ================================

create table SN_VERSION
(
  SPOTFIRE_VERSION varchar2(20) not null,
  SCHEMA_VERSION varchar2(20) not null,
  ENCRYPTION_CANARY varchar2(400) null,
  CLUSTER_ID char(36) null
)
/

create table LICENSE_NAMES (
	LICENSE_NAME VARCHAR(256) not null,
	LICENSE_DISPLAY_NAME NVARCHAR2(400) null, constraint LICENSE_NAMES_PK primary key (LICENSE_NAME) )
/

create table PREFERENCE_OBJECTS (
	CLASS_NAME VARCHAR(250) not null,
	OBJECT_NAME VARCHAR(250) not null,
	LAST_MODIFIED TIMESTAMP null,
	USER_ID CHAR(36) null,
	GROUP_ID CHAR(36) null,
	IS_DEFAULT SMALLINT null,
	OBJECT_VALUE VARCHAR(4000) null,
	OBJECT_BLOB_VALUE BLOB null, constraint PREFERENCE_OBJECTS_PK primary key (CLASS_NAME, OBJECT_NAME) )
/

create table LICENSE_ORIGIN (
	PACKAGE_ID CHAR(36) null,
	ASSEMBLY_QUALIFIED_NAME VARCHAR(400) not null,
	LICENSE_FUNCTION_ID CHAR(36) not null)
/

create table EXCLUDED_FUNCTIONS (
	CUSTOMIZED_LICENSE_ID CHAR(36) not null,
	LICENSE_FUNCTION_ID CHAR(36) not null, constraint EXCLUDED_FUNCTIONS_PK primary key (CUSTOMIZED_LICENSE_ID, LICENSE_FUNCTION_ID) )
/

create table CUSTOMIZED_LICENSES (
	CUSTOMIZED_LICENSE_ID CHAR(36) not null,
	GROUP_ID CHAR(36) not null,
	LICENSE_NAME VARCHAR(256) null, constraint CUSTOMIZED_LICENSES_PK primary key (CUSTOMIZED_LICENSE_ID) )
/

create table LICENSE_FUNCTIONS (
	LICENSE_FUNCTION_ID CHAR(36) not null,
	LICENSE_NAME VARCHAR(256) not null,
	LICENSE_FUNCTION_NAME VARCHAR(50) not null,
	LICENSE_FUNCTION_DISPLAY_NAME NVARCHAR2(400) null, constraint LICENSE_FUNCTIONS_PK primary key (LICENSE_FUNCTION_ID) )
/

create table PREFERENCE_VALUES (
	PREFERENCE_VALUE VARCHAR(4000) null,
	LAST_MODIFIED TIMESTAMP not null,
	USER_ID CHAR(36) null,
	GROUP_ID CHAR(36) null,
	PREFERENCE_ID CHAR(36) not null,
	PREFERENCE_BLOB_VALUE BLOB null)
/

create table DEP_AREA_ALLOWED_GRP (
	AREA_ID CHAR(36) not null, 
	GROUP_ID CHAR(36) not null, constraint DEP_AREA_ALLOWED_GRP_PK primary key (GROUP_ID) )
/

create index DEP_AREA_ALWD_GRP_AREA_ID_IDX 
  on DEP_AREA_ALLOWED_GRP(AREA_ID)
/

create table GROUP_MEMBERS (
	GROUP_ID CHAR(36) not null,
	MEMBER_USER_ID CHAR(36) null,
	MEMBER_GROUP_ID CHAR(36) null)
/

create index GROUP_MEMBER_REVERSE_USER_IX 
  on GROUP_MEMBERS(MEMBER_USER_ID, GROUP_ID)
/

create index GROUP_MEMBER_REVERSE_GRP_IX 
  on GROUP_MEMBERS(MEMBER_GROUP_ID, GROUP_ID)
/

create table USERS (
  USER_ID CHAR(36) not null,
  USER_NAME NVARCHAR2(200) not null,
  DOMAIN_NAME NVARCHAR2(200) not null,
  EXTERNAL_ID NVARCHAR2(450) null,
  PRIMARY_GROUP_ID CHAR(36) null,
  LAST_MODIFIED_MEMBERSHIP TIMESTAMP null,
  PASSWORD VARCHAR2(150) null,
  DISPLAY_NAME NVARCHAR2(450) not null,
  EMAIL NVARCHAR2(450) null,
  ENABLED SMALLINT not null,
  FIXED SMALLINT default 0 not null,  
  LOCKED_UNTIL TIMESTAMP null,
  LAST_LOGIN TIMESTAMP null, constraint USERS_PK primary key (USER_ID) )
/

create view GROUP_MEMBERS_VIEW as 
  select GROUP_ID, MEMBER_USER_ID, MEMBER_GROUP_ID from GROUP_MEMBERS
  union all
  select '19e7e430-9997-11da-fbc4-0010ac110215' as GROUP_ID, u.USER_ID as MEMBER_USER_ID, null as MEMBER_GROUP_ID 
  from USERS u where u.DOMAIN_NAME !=  N'ANONYMOUS'
/

create global temporary table USERS_TEMP (
  USER_ID CHAR(36) not null,
  USER_NAME NVARCHAR2(200) not null,
  DOMAIN_NAME NVARCHAR2(200) not null,
  EXTERNAL_ID NVARCHAR2(450) not null,
  DISPLAY_NAME NVARCHAR2(450) not null,
  EMAIL NVARCHAR2(450) null,
  ENABLED SMALLINT not null,
  constraint USERS_TEMP_PK primary key (USER_NAME, DOMAIN_NAME) )
/

create unique index USERS_TEMP_EXTERNAL_ID_INDEX
  on USERS_TEMP(EXTERNAL_ID)
/

create unique index USERS_TEMP_NAME_DOMAIN_U_UIDX 
  on USERS_TEMP (upper(USER_NAME), upper(DOMAIN_NAME))
/

create table GROUPS (
  GROUP_ID CHAR(36) not null,
  GROUP_NAME NVARCHAR2(200) not null,
  DOMAIN_NAME NVARCHAR2(200) not null,
  EXTERNAL_ID NVARCHAR2(450) null, 
  PRIMARY_GROUP_ID CHAR(36) null,
  DISPLAY_NAME NVARCHAR2(450) not null,
  EMAIL NVARCHAR2(450) null,
  CONNECTED SMALLINT not null,
  FIXED SMALLINT default 0 not null,
  constraint GROUPS_PK primary key (GROUP_ID) )
/

create global temporary table GROUPS_TEMP (
  GROUP_ID CHAR(36) not null,
  GROUP_NAME NVARCHAR2(200) not null,
  DOMAIN_NAME NVARCHAR2(200) not null,
  EXTERNAL_ID NVARCHAR2(450) not null,
  DISPLAY_NAME NVARCHAR2(450) not null,
  EMAIL NVARCHAR2(450) null,
  CONNECTED SMALLINT not null,
  constraint GROUPS_TEMP_PK primary key (GROUP_NAME, DOMAIN_NAME) )
/

create unique index GROUPS_TEMP_EXTERNAL_ID_INDEX on GROUPS_TEMP(EXTERNAL_ID)
/

create unique index GROUPS_TEMP_NAME_DOMAIN_U_UIDX 
  on GROUPS_TEMP (upper(GROUP_NAME), upper(DOMAIN_NAME))
/

create global temporary table GROUP_MEMBERS_TEMP (
  GROUP_NAME NVARCHAR2(200) not null,
  GROUP_DOMAIN_NAME NVARCHAR2(200) not null,
  MEMBER_USER_NAME NVARCHAR2(200) null,
  MEMBER_GROUP_NAME NVARCHAR2(200) null,
  MEMBER_DOMAIN_NAME NVARCHAR2(200) not null)
/

create unique index GROUP_MEMBERS_TEMP_INDEX on GROUP_MEMBERS_TEMP (
  GROUP_NAME,
  GROUP_DOMAIN_NAME,
  MEMBER_USER_NAME,
  MEMBER_GROUP_NAME,
  MEMBER_DOMAIN_NAME)
/

create index GROUP_MEMBERS_TEMP_IX1 on GROUP_MEMBERS_TEMP (
  upper(GROUP_NAME), 
  upper(GROUP_DOMAIN_NAME), 
  upper(MEMBER_DOMAIN_NAME), 
  upper(MEMBER_USER_NAME))
/

create index GROUP_MEMBERS_TEMP_IX2 on GROUP_MEMBERS_TEMP (
  upper(GROUP_NAME), 
  upper(GROUP_DOMAIN_NAME), 
  upper(MEMBER_DOMAIN_NAME), 
  upper(MEMBER_GROUP_NAME))
/

create global temporary table GROUP_MEMBERSHIPS (
  GROUP_ID char(36) not null,
  constraint GROUP_MEMBERSHIPS_PK primary key (GROUP_ID) )
/

create table DEP_AREAS_DEF (
	AREA_ID CHAR(36) not null,
	DEP_AREA_NAME VARCHAR2(50) not null,
	IS_DEFAULT_AREA char(1) not null,
	constraint DEP_AREAS_DEF_PK primary key (AREA_ID),
	constraint DEP_AREAS_DEF_UC1 unique (DEP_AREA_NAME) )
/

create table DEP_AREAS (
	AREA_ID CHAR(36) not null,
	DISTRIBUTION_ID CHAR(36) not null,
	DEPLOYMENT_TIME TIMESTAMP not null,
	STATE SMALLINT null,
	URL VARCHAR(50) null, constraint DEP_AREAS_PK primary key (AREA_ID) )
/

create table DEP_DISTRIBUTION_CONTENTS (
	PACKAGE_ID CHAR(36) not null,
	DISTRIBUTION_ID CHAR(36) not null, constraint DEP_DISTRIBUTION_CONTENTS_PK primary key (PACKAGE_ID, DISTRIBUTION_ID) )
/

create table DEP_DISTRIBUTIONS (
	DISTRIBUTION_ID CHAR(36) not null,
	NAME VARCHAR(200) not null,
	MODIFIED_DATE DATE not null,
	VERSION VARCHAR(50) null,
	ADDINS_XML BLOB null,
	MANIFEST_XML BLOB null,
	DESCRIPTION VARCHAR(400) null,
	METADATA_XML BLOB null, constraint DEP_DISTRIBUTIONS_PK primary key (DISTRIBUTION_ID) )
/

create table DEP_PACKAGES (
	PACKAGE_ID CHAR(36) not null,
	SERIE_ID CHAR(36) not null,
	NAME VARCHAR(200) not null,
	ZIP BLOB not null,
	MODIFIED_DATE DATE not null,
	VERSION VARCHAR(32) not null,
	DESCRIPTION VARCHAR(400) null)
/

create table PREFERENCE_KEYS (
	CATEGORY_NAME VARCHAR(250) not null,
	PREFERENCE_NAME VARCHAR(250) not null,
	CLASS_TYPE VARCHAR(250) not null,
	PREFERENCE_ID CHAR(36) not null, constraint PREFERENCE_KEYS_PK primary key (PREFERENCE_ID) )
/

alter table LICENSE_FUNCTIONS add constraint LICENSE_FUNCTIONS_UC1 unique (
	LICENSE_FUNCTION_NAME,
	LICENSE_NAME)
/

alter table PREFERENCE_VALUES add constraint PREFERENCE_VALUES_UC1 unique (
	GROUP_ID,
	USER_ID,
	PREFERENCE_ID)
/

create unique index GROUP_MEMBER_IX on GROUP_MEMBERS (
	GROUP_ID,
	MEMBER_GROUP_ID,
	MEMBER_USER_ID)
/

alter table "GROUP_MEMBERS" add constraint "GROUP_MEMBERS_XOR" check (			
	("MEMBER_USER_ID" is null and "MEMBER_GROUP_ID" is not null) 
	or 
	("MEMBER_USER_ID" is not null and "MEMBER_GROUP_ID" is null)
	or 
	("GROUP_ID" = '19e7e430-9997-11da-fbc4-0010ac110215')
)
/

create unique index USERS_NAME_DOMAIN_UIDX on USERS (USER_NAME, DOMAIN_NAME)
/

alter table USERS add constraint USERS_NAME_DOMAIN_UIDX 
  unique (USER_NAME, DOMAIN_NAME)
/

create unique index USERS_NAME_DOMAIN_U_UIDX on USERS (upper(USER_NAME), upper(DOMAIN_NAME))
/

create unique index GROUPS_NAME_DOMAIN_UIDX on GROUPS (GROUP_NAME, DOMAIN_NAME)
/

alter table GROUPS add constraint GROUPS_NAME_DOMAIN_UIDX 
  unique (GROUP_NAME, DOMAIN_NAME)
/ 

create unique index GROUPS_NAME_DOMAIN_U_UIDX on GROUPS (upper(GROUP_NAME), upper(DOMAIN_NAME))
/

create index GROUPS_PRIMARY_GROUP_ID_IDX on GROUPS (PRIMARY_GROUP_ID)
/

create index USERS_PRIMARY_GROUP_ID_IDX on USERS (PRIMARY_GROUP_ID)
/

create unique index DEP_PACKAGES_PK on DEP_PACKAGES (
	PACKAGE_ID)
/

alter table DEP_PACKAGES add constraint DEP_PACKAGES_PK_UC1 unique (
	PACKAGE_ID)
/

alter table PREFERENCE_KEYS add constraint PREFERENCE_KEYS_UC1 unique (
	CATEGORY_NAME,
	PREFERENCE_NAME,
        CLASS_TYPE)
/

alter table PREFERENCE_OBJECTS
	add constraint GROUPS_PREFERENCE_OBJECTS_FK1 foreign key (
		GROUP_ID)
	 references GROUPS (
		GROUP_ID) ON DELETE CASCADE
/

alter table PREFERENCE_OBJECTS
	add constraint USERS_PREFERENCE_OBJECTS_FK1 foreign key (
		USER_ID)
	 references USERS (
		USER_ID) ON DELETE CASCADE
/

alter table LICENSE_ORIGIN
	add constraint DEP_PKGS_LIC_ORIGIN_FK1 foreign key (
		PACKAGE_ID)
	 references DEP_PACKAGES (
		PACKAGE_ID) ON DELETE SET NULL
/

alter table LICENSE_ORIGIN
	add constraint LIC_FUNS_LIC_ORIGIN_FK1 foreign key (
		LICENSE_FUNCTION_ID)
	 references LICENSE_FUNCTIONS (
		LICENSE_FUNCTION_ID) ON DELETE CASCADE
/

alter table EXCLUDED_FUNCTIONS
	add constraint CUSTOMIZED_LIC_EXCLUDED_FN_FK1 foreign key (
		CUSTOMIZED_LICENSE_ID)
	 references CUSTOMIZED_LICENSES (
		CUSTOMIZED_LICENSE_ID) ON DELETE CASCADE
/

alter table EXCLUDED_FUNCTIONS
	add constraint LIC_FUNS_EXCL_FUNS_FK1 foreign key (
		LICENSE_FUNCTION_ID)
	 references LICENSE_FUNCTIONS (
		LICENSE_FUNCTION_ID) ON DELETE CASCADE
/

alter table CUSTOMIZED_LICENSES
	add constraint GROUPS_CUSTOMIZED_LICENSES_FK1 foreign key (
		GROUP_ID)
	 references GROUPS (
		GROUP_ID) ON DELETE CASCADE
/

alter table CUSTOMIZED_LICENSES
	add constraint LICENSE_NAMES_CUST_LIC_FK1 foreign key (
		LICENSE_NAME)
	 references LICENSE_NAMES (
		LICENSE_NAME) ON DELETE CASCADE
/

alter table LICENSE_FUNCTIONS
	add constraint LICENSE_NAMES_LIC_FUNS_FK1 foreign key (
		LICENSE_NAME)
	 references LICENSE_NAMES (
		LICENSE_NAME) ON DELETE CASCADE
/

alter table PREFERENCE_VALUES
	add constraint GROUPS_PREFERENCE_VALUES_FK1 foreign key (
		GROUP_ID)
	 references GROUPS (
		GROUP_ID) ON DELETE CASCADE
/

alter table PREFERENCE_VALUES
	add constraint USERS_PREFERENCE_VALUES_FK1 foreign key (
		USER_ID)
	 references USERS (
		USER_ID) ON DELETE CASCADE
/

alter table PREFERENCE_VALUES
	add constraint PREFERENCE_KEY_VALUES_FK1 foreign key (
		PREFERENCE_ID)
	 references PREFERENCE_KEYS (
		PREFERENCE_ID) ON DELETE CASCADE
/

alter table DEP_AREA_ALLOWED_GRP
	add constraint GROUPS__GROUP_ID_FK1 foreign key (
		GROUP_ID)
	 references GROUPS (
		GROUP_ID) ON DELETE CASCADE
/

alter table DEP_AREA_ALLOWED_GRP
	add constraint DEP_AREAS_AREA_ID_FK1 foreign key (
		AREA_ID)
	 references DEP_AREAS_DEF (
		AREA_ID) ON DELETE CASCADE
/

alter table GROUP_MEMBERS
	add constraint GROUP_MEMBERS_FK1 foreign key (
		MEMBER_GROUP_ID)
	 references GROUPS (
		GROUP_ID) ON DELETE CASCADE
/

alter table GROUP_MEMBERS
	add constraint GROUP_ID_FK2 foreign key (
		GROUP_ID)
	 references GROUPS (
		GROUP_ID) ON DELETE CASCADE
/

alter table GROUP_MEMBERS
	add constraint USERS_GROUP_MEMBERS_FK1 foreign key (
		MEMBER_USER_ID)
	 references USERS (
		USER_ID) ON DELETE CASCADE
/

alter table USERS
	add constraint GROUPS_USERS_FK1 foreign key (
		PRIMARY_GROUP_ID)
	 references GROUPS (
		GROUP_ID) ON DELETE SET NULL
/

alter table GROUPS
	add constraint GROUPS_GROUPS_FK1 foreign key (
		PRIMARY_GROUP_ID)
	 references GROUPS (
		GROUP_ID) ON DELETE SET NULL
/

alter table DEP_AREAS
	add constraint DEP_DIST_AREA_DIST_ID_FK1 foreign key (
		DISTRIBUTION_ID)
	 references DEP_DISTRIBUTIONS (
		DISTRIBUTION_ID) ON DELETE CASCADE
		
/

alter table DEP_AREAS
	add constraint DEP_AREAS_DEF_FK1 foreign key (
		AREA_ID)
	 references DEP_AREAS_DEF(
		AREA_ID) ON DELETE CASCADE
		
/

alter table DEP_DISTRIBUTION_CONTENTS
	add constraint DEP_DISTRIBUTIONS_DIST_ID_FK1 foreign key (
		DISTRIBUTION_ID)
	 references DEP_DISTRIBUTIONS (
		DISTRIBUTION_ID) ON DELETE CASCADE
/
		
alter table DEP_DISTRIBUTION_CONTENTS
	add constraint DEP_PACKAGES_PACKAGE_ID_FK1 foreign key (
		PACKAGE_ID)
	 references DEP_PACKAGES (
		PACKAGE_ID) ON DELETE CASCADE
/

create view UTC_TIME as select sys_extract_utc(systimestamp) as TS from dual
/

/* ----------------- library --------------------- */

create table "LIB_ITEM_TYPES" (
	"TYPE_ID" CHAR(36) not null,
	"LABEL" VARCHAR2(255) not null, 
	"LABEL_PREFIX" VARCHAR2(255) not null,
	"DISPLAY_NAME" VARCHAR2(255) not null,
	"IS_CONTAINER" CHAR(1) not null,
	"FILE_SUFFIX" VARCHAR2(255) null,
	"MIME_TYPE" VARCHAR2(255) null, 
	constraint "PK_LIB_ITEM_TYPES" primary key ("TYPE_ID"),
	constraint "LIB_ITEM_TYPES_CONSTRAINT" unique ("LABEL", "LABEL_PREFIX")	)
/

create table "LIB_CONTENT_TYPES" (
	"TYPE_ID" number(2,0) not null,
	"CONTENT_TYPE" varchar2(50) not null, 
	constraint "PK_LIB_CONTENT_TYPES" primary key ("TYPE_ID") )
/

create table "LIB_CONTENT_ENCODINGS" (
	"ENCODING_ID" number(2,0) not null,
	"CONTENT_ENCODING" varchar2(50) not null, 
	constraint "PK_LIB_CONTENT_ENCODINGS" primary key ("ENCODING_ID") )
/

create table "LIB_CHARACTER_ENCODINGS" (
	"ENCODING_ID" number(2,0) not null,
	"CHARACTER_ENCODING" varchar2(50) not null, 
	constraint "PK_LIB_CHARACTER_ENCODINGS" primary key ("ENCODING_ID") )
/

create table "LIB_ITEMS" (
	"ITEM_ID" char(36) not null,
	"TITLE" nvarchar2(256) not null,
	"DESCRIPTION" nvarchar2(1000) null,
	"ITEM_TYPE" char(36) not null,
	"FORMAT_VERSION" varchar2(50) null,
	"CREATED_BY" char(36) null,
	"CREATED" timestamp(6) not null,
	"MODIFIED_BY" char(36) null,
	"MODIFIED" timestamp(6) not null,
	"ACCESSED" timestamp(6) null,
	"CONTENT_SIZE" int default 0 not null,   
	"PARENT_ID" char(36) null, 
	"HIDDEN" char(1) not null,
	constraint "PK_ITEM_ID" primary key ("ITEM_ID"),
	constraint "FK_LIB_ITEM_ITEM_TYPE" foreign key ("ITEM_TYPE")
		references "LIB_ITEM_TYPES" ("TYPE_ID"),
	constraint "LIB_ITEM_USER_FK1" foreign key ("CREATED_BY")
		references "USERS" ("USER_ID") on delete set null,
	constraint "LIB_ITEM_USER_FK2" foreign key ("MODIFIED_BY")
		references "USERS" ("USER_ID") on delete set null,
	constraint "FK_LIB_ITEM_PARENT_ID" foreign key ("PARENT_ID")
		references "LIB_ITEMS" ("ITEM_ID") on delete cascade )
/

alter table "LIB_ITEMS" add constraint "LIB_ITEMS_PARENT_NEQ_ITEM" 
	check ("ITEM_ID" != "PARENT_ID")
/

create index "LIB_ITEM_INDEX1" on "LIB_ITEMS"("CREATED_BY") 
/

create index "LIB_ITEM_INDEX2" on "LIB_ITEMS"("MODIFIED_BY") 
/

create index "LIB_ITEM_INDEX3" on "LIB_ITEMS"("ITEM_TYPE") 
/

create index "LIB_ITEM_INDEX4" on "LIB_ITEMS"(upper("TITLE")) 
/

create index "LIB_ITEM_INDEX5" on "LIB_ITEMS"("PARENT_ID") 
/

create table "LIB_DATA" (
	"ITEM_ID" char(36) not null,
	"CONTENT_TYPE" number(2,0) null,
	"CONTENT_ENCODING" number(2,0) null,
	"CHARACTER_ENCODING" number(2,0) null,
	"DATA" blob not null, 
	constraint "PK_LIB_DATA_ITEM_ID" primary key ("ITEM_ID"),
	constraint "FK_LIB_DATA_ITEM_ID" foreign key ("ITEM_ID")
		references "LIB_ITEMS" ("ITEM_ID") on delete cascade,
	constraint "FK_LIB_DATA_CONTENT_TYPE" foreign key ("CONTENT_TYPE")
		references "LIB_CONTENT_TYPES" ("TYPE_ID"),
	constraint "FK_LIB_DATA_CONTENT_ENCODING" foreign key ("CONTENT_ENCODING")
		references "LIB_CONTENT_ENCODINGS" ("ENCODING_ID"),
	constraint "FK_LIB_DATA_CHARACTER_ENCODING" foreign key ("CHARACTER_ENCODING")
		references "LIB_CHARACTER_ENCODINGS" ("ENCODING_ID") )
/

create table "LIB_PROPERTIES" ( 
	"ITEM_ID" char(36) not null,
	"PROPERTY_NAME" nvarchar2(150) not null,
	"PROPERTY_VALUE" nvarchar2(256) not null,
	"PROPERTY_BLOB_VALUE" blob null,
	constraint "FK_LIB_PROPERTIES_LIB_ITEM" foreign key ("ITEM_ID")
	 	references "LIB_ITEMS" ("ITEM_ID") on delete cascade )
/

create index "LIB_PROP_IX1" on "LIB_PROPERTIES"("ITEM_ID", upper("PROPERTY_NAME"),
       	     		    upper("PROPERTY_VALUE"))
/

create index "LIB_PROP_IX2" on "LIB_PROPERTIES" (
  upper("PROPERTY_NAME"), 
  upper("PROPERTY_VALUE"), 
  "ITEM_ID")
/

create table "LIB_PRINCIPAL_PROPS" ( 
  "ITEM_ID" char(36) not null,
  "USER_ID" char(36) null,
  "GROUP_ID" char(36) null,
  "PROPERTY_NAME" nvarchar2(150) not null,
  "PROPERTY_VALUE_JSON" blob null,
  constraint "FK_LPP_LIB_ITEMS" foreign key ("ITEM_ID")
    references "LIB_ITEMS" ("ITEM_ID") on delete cascade,
  constraint "FK_LPP_USERS" foreign key ("USER_ID")
    references "USERS" ("USER_ID") on delete cascade,
  constraint "FK_LPP_GROUPS" foreign key ("GROUP_ID")
    references "GROUPS" ("GROUP_ID") on delete cascade,
  constraint "LPP_UC1" 
    unique ("ITEM_ID", "USER_ID", "GROUP_ID", "PROPERTY_NAME") )
/

create index "LIB_PRINCIPAL_PROPS_IX2" on "LIB_PRINCIPAL_PROPS" (
  "USER_ID",
  "PROPERTY_NAME",
  "ITEM_ID")
/

create index "LIB_PRINCIPAL_PROPS_IX3" on "LIB_PRINCIPAL_PROPS" (
  "GROUP_ID",
  "PROPERTY_NAME",
  "ITEM_ID")
/

alter table "LIB_PRINCIPAL_PROPS" add constraint "LIB_PRINCIPAL_PROPS_XOR" check (      
  ("USER_ID" is null and "GROUP_ID" is not null) 
  or 
  ("USER_ID" is not null and "GROUP_ID" is null)
)
/

create table "LIB_WORDS" (
	"ITEM_ID" char(36) not null,
	"PROPERTY" nvarchar2(150) not null,
	"WORD" nvarchar2(256) not null,
	constraint "FK_LIB_WORDS_LIB_ITEM" foreign key ("ITEM_ID")
		references "LIB_ITEMS" ("ITEM_ID") on delete cascade ) 
/

create index "LIB_WORDS_IX1" on "LIB_WORDS"("ITEM_ID", upper("PROPERTY"), upper("WORD"))
/

create table "LIB_ACCESS" ( 
	"ITEM_ID" char(36) not null,
	"USER_ID" char(36) null,
    "GROUP_ID" char(36) null,
    "PERMISSION" char(1) not null,
    constraint "FK_LIB_ACCESS_LIB_ITEM" foreign key ("ITEM_ID")
	 	references "LIB_ITEMS" ("ITEM_ID") on delete cascade,
	constraint "FK_LIB_ACCESS_USER" foreign key ("USER_ID")
	 	references "USERS" ("USER_ID") on delete cascade,
	constraint "FK_LIB_ACCESS_GROUPS" foreign key ("GROUP_ID")
	 	references "GROUPS" ("GROUP_ID") on delete cascade,
	constraint "LIB_ACCESS_UC1" unique ("ITEM_ID", "USER_ID", "GROUP_ID", "PERMISSION") )
/

alter table "LIB_ACCESS" add constraint "LIB_ACCESS_XOR" check (
	("USER_ID" is null and "GROUP_ID" is not null) 
	or 
	("USER_ID" is not null and "GROUP_ID" is null) )
/

create index "LIB_ACCESS_INDEX1" on "LIB_ACCESS"("USER_ID") 
/

create index "LIB_ACCESS_INDEX2" on "LIB_ACCESS"("GROUP_ID") 
/

create table "LIB_RESOLVED_DEPEND" (
	"DEPENDENT_ID" char(36) not null,
	"REQUIRED_ID" char(36) not null,
	"DESCRIPTION" nvarchar2(1000) null,
	"CASCADING_DELETE" char(1) not null,
	"ORIGINAL_REQUIRED_ID" char(36) null,
	constraint "LIB_RESOLVED_DEPEND_PK" primary key ("DEPENDENT_ID", "REQUIRED_ID"),
	constraint "LIB_RESOLVED_DEPEND_FK1" foreign key ("DEPENDENT_ID")
	 	references "LIB_ITEMS" ("ITEM_ID") on delete cascade,
	constraint "LIB_RESOLVED_DEPEND_FK2" foreign key ("REQUIRED_ID")
	 	references "LIB_ITEMS" ("ITEM_ID") on delete cascade )
/

alter table "LIB_RESOLVED_DEPEND" add constraint "RESOLVED_DEP_NEQ_REQ" 
	check ("DEPENDENT_ID" != "REQUIRED_ID")
/

create index "LIB_RESOLVED_INDEX1" on "LIB_RESOLVED_DEPEND"("REQUIRED_ID")
/

create index "LIB_RESOLVED_INDEX2" on "LIB_RESOLVED_DEPEND"("DEPENDENT_ID")
/

create table "LIB_UNRESOLVED_DEPEND" (
	"DEPENDENT_ID" char(36) not null,
	"REQUIRED_ID" char(36) not null,
	"DESCRIPTION" nvarchar2(1000) null,
	"CASCADING_DELETE" char(1) not null,
	"ORIGINAL_REQUIRED_ID" char(36) null,
	constraint "LIB_UNRESOLVED_DEPEND_PK" primary key ("DEPENDENT_ID", "REQUIRED_ID"),
	constraint "LIB_UNRESOLVED_DEPEND_FK1" foreign key ("DEPENDENT_ID")
	 	references "LIB_ITEMS" ("ITEM_ID") on delete cascade )
/

alter table "LIB_UNRESOLVED_DEPEND" add constraint "UNRESOLVED_DEP_NEQ_REQ" 
	check ("DEPENDENT_ID" != "REQUIRED_ID")
/

create index "LIB_UNRESOLVED_INDEX1" on "LIB_UNRESOLVED_DEPEND"("REQUIRED_ID")
/

create index "LIB_UNRESOLVED_INDEX2" on "LIB_UNRESOLVED_DEPEND"("DEPENDENT_ID")
/

create table "LIB_APPLICATIONS" (
	"APPLICATION_ID" number(5) not null,
	"APPLICATION_NAME" varchar2(256) not null,
	constraint "PK_APPLICATIONS" primary key ("APPLICATION_ID") )
/	

create unique index "UK_LIB_APPLICATIONS_IDX" on "LIB_APPLICATIONS" ("APPLICATION_NAME")
/

create table "LIB_VISIBLE_TYPES" (
	"TYPE_ID" char(36) not null,
	"APPLICATION_ID" number(5) not null,
	constraint "PK_VISIBLE_TYPES" primary key ("TYPE_ID", "APPLICATION_ID"),
	constraint "FK_LIB_VISIBLE_TYPES01" foreign key ("TYPE_ID")
		references "LIB_ITEM_TYPES" ("TYPE_ID") on delete cascade, 
	constraint "FK_LIB_VISIBLE_TYPES02" foreign key ("APPLICATION_ID")
		references "LIB_APPLICATIONS" ("APPLICATION_ID") on delete cascade )
/		

-- Temporary table used by the usp_deleteItem stored procedure
create global temporary table "LIB_TEMP_DESCENDANTS" (
  "ANCESTOR_ID" char(36),
  "DESCENDANT_ID" char(36) )
/

create index "LIB_TEMP_DESCENDANTS_INDEX"
	on "LIB_TEMP_DESCENDANTS"("ANCESTOR_ID")
/

create global temporary table "LIB_COPY_MAPPING" (
  "ORIGINAL_ID" char(36),
  "COPY_ID" char(36) )
/

create index "LIB_COPY_MAPPING_INDEX"
	on "LIB_COPY_MAPPING"("ORIGINAL_ID")
/

create or replace procedure usp_copyItem (
  oldId in LIB_ITEMS.ITEM_ID%type,
  newId in LIB_ITEMS.ITEM_ID%type,
  parentId in LIB_ITEMS.PARENT_ID%type,
  caller in LIB_ITEMS.MODIFIED_BY%type,
  newTitle in LIB_ITEMS.TITLE%type) as
timeOfUpdate timestamp(6);
begin
  select sys_extract_utc(systimestamp) into timeOfUpdate from DUAL;

  if (newTitle is null) then
    insert into LIB_ITEMS (ITEM_ID, TITLE, DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, CREATED, MODIFIED_BY,
      MODIFIED, CONTENT_SIZE, PARENT_ID, HIDDEN)
    select newId as ITEM_ID,
      TITLE, DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, CREATED,
      caller as MODIFIED_BY,
      timeOfUpdate as MODIFIED,
      CONTENT_SIZE,
      parentId as PARENT_ID,
      HIDDEN
    from LIB_ITEMS original
    where original.ITEM_ID = oldId;
  else
    insert into LIB_ITEMS (ITEM_ID, TITLE, DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, CREATED, MODIFIED_BY,
      MODIFIED, CONTENT_SIZE, PARENT_ID, HIDDEN)
    select newId as ITEM_ID,
      newTitle as TITLE,
      DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, CREATED,
      caller as MODIFIED_BY,
      timeOfUpdate as MODIFIED,
      CONTENT_SIZE,
      parentId as PARENT_ID,
      HIDDEN
    from LIB_ITEMS original
    where original.ITEM_ID = oldId;
  end if;

  insert into LIB_COPY_MAPPING (ORIGINAL_ID, COPY_ID) values (oldId, newId);

end usp_copyItem;
/

create or replace procedure usp_moveItem (
  itemId in LIB_ITEMS.ITEM_ID%type, 
  newParentId in LIB_ITEMS.PARENT_ID%type,
  caller in LIB_ITEMS.MODIFIED_BY%type,
  newTitle in LIB_ITEMS.TITLE%type) as
timeOfUpdate timestamp(6);  
begin
  select sys_extract_utc(systimestamp) into timeOfUpdate from DUAL;

  if (newTitle is null) then
    update LIB_ITEMS set MODIFIED_BY = caller, MODIFIED = timeOfUpdate, PARENT_ID = newParentId where ITEM_ID = itemId;
  else
    update LIB_ITEMS set TITLE = newTitle, MODIFIED_BY = caller, MODIFIED = timeOfUpdate,  PARENT_ID = newParentId where ITEM_ID = itemId;
  end if;
end usp_moveItem;
/

create or replace procedure usp_finishCopy
as
begin
  -- Content
  insert into LIB_DATA (ITEM_ID, CONTENT_TYPE, CONTENT_ENCODING, CHARACTER_ENCODING, DATA) 
    select cm.COPY_ID as ITEM_ID, CONTENT_TYPE, CONTENT_ENCODING, CHARACTER_ENCODING, DATA 
    from LIB_DATA original, LIB_COPY_MAPPING cm 
    where original.ITEM_ID = cm.ORIGINAL_ID;
  
  -- Properties
  insert into LIB_PROPERTIES (ITEM_ID, PROPERTY_NAME, PROPERTY_VALUE, PROPERTY_BLOB_VALUE) 
    select cm.COPY_ID as ITEM_ID, PROPERTY_NAME, PROPERTY_VALUE, PROPERTY_BLOB_VALUE
    from LIB_PROPERTIES original, LIB_COPY_MAPPING cm 
    where original.ITEM_ID = cm.ORIGINAL_ID;
          
  -- Permissions
  insert into LIB_ACCESS (ITEM_ID, USER_ID, GROUP_ID, PERMISSION) 
    select cm.COPY_ID as ITEM_ID, USER_ID, GROUP_ID, PERMISSION 
    from LIB_ACCESS original, LIB_COPY_MAPPING cm 
    where original.ITEM_ID = cm.ORIGINAL_ID;

  -- Words
  insert into LIB_WORDS (ITEM_ID, PROPERTY, WORD)
    select cm.COPY_ID as ITEM_ID, PROPERTY, WORD
    from LIB_WORDS original, LIB_COPY_MAPPING cm
    where original.ITEM_ID = cm.ORIGINAL_ID;

  -- Unresolved dependencies
  insert into LIB_UNRESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
    select cm.COPY_ID as DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID 
    from LIB_UNRESOLVED_DEPEND original, LIB_COPY_MAPPING cm 
    where original.DEPENDENT_ID = cm.ORIGINAL_ID;

  -- Resolved dependencies where the required items also have been copied and there is no original required ID
  insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
    select 
    dep.COPY_ID as DEPENDENT_ID, 
    req.COPY_ID as REQUIRED_ID, 
    original.DESCRIPTION, 
    original.CASCADING_DELETE,
    original.REQUIRED_ID
    from LIB_RESOLVED_DEPEND original, LIB_COPY_MAPPING dep, LIB_COPY_MAPPING req
    where original.DEPENDENT_ID = dep.ORIGINAL_ID
    and original.REQUIRED_ID = req.ORIGINAL_ID
    and ORIGINAL_REQUIRED_ID is null;

  -- Resolved dependencies where the required items also have been copied and there is an original required ID
  insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
    select 
    dep.COPY_ID as DEPENDENT_ID, 
    req.COPY_ID as REQUIRED_ID, 
    original.DESCRIPTION, 
    original.CASCADING_DELETE,
    original.ORIGINAL_REQUIRED_ID
    from LIB_RESOLVED_DEPEND original, LIB_COPY_MAPPING dep, LIB_COPY_MAPPING req
    where original.DEPENDENT_ID = dep.ORIGINAL_ID
    and original.REQUIRED_ID = req.ORIGINAL_ID
  and ORIGINAL_REQUIRED_ID is not null;
  
  -- Resolved dependencies where the required items has not been copied
  insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
    select 
    dep.COPY_ID as DEPENDENT_ID, 
    original.REQUIRED_ID, 
    original.DESCRIPTION, 
    original.CASCADING_DELETE, 
    original.ORIGINAL_REQUIRED_ID
    from LIB_RESOLVED_DEPEND original, LIB_COPY_MAPPING dep
    where original.DEPENDENT_ID = dep.ORIGINAL_ID
    and not exists (select 1 from LIB_COPY_MAPPING where ORIGINAL_ID = original.REQUIRED_ID);
  
end usp_finishCopy;
/

create or replace procedure usp_insertDepencency (
  dependentId in LIB_RESOLVED_DEPEND.DEPENDENT_ID%type, 
  requiredId in LIB_RESOLVED_DEPEND.REQUIRED_ID%type,
  description in LIB_RESOLVED_DEPEND.DESCRIPTION%type,
  cascadingDelete in LIB_RESOLVED_DEPEND.CASCADING_DELETE%type,
  originalRequiredId in LIB_RESOLVED_DEPEND.ORIGINAL_REQUIRED_ID%type) as
cnt number;
begin
  select count(*) into cnt from LIB_ITEMS where ITEM_ID = requiredId;
  
  if (cnt > 0) then
    insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
      values (dependentId, requiredId, description, cascadingDelete, originalRequiredId);
  else
    insert into LIB_UNRESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
      values (dependentId, requiredId, description, cascadingDelete, originalRequiredId);    
  end if;
  
end usp_insertDepencency;
/

create or replace procedure usp_verifyAccess (
  itemId in LIB_ACCESS.ITEM_ID%type, 
  caller in LIB_ACCESS.USER_ID%type,
  requiredPermission in LIB_ACCESS.PERMISSION%type,
  administrationEnabled in number,
  cnt out number) as
begin
  if (administrationEnabled = 1) then
    select count(*) into cnt 
      from GROUP_MEMBERS where GROUP_ID in (select GROUP_ID from GROUPS where GROUP_NAME in 
      (N'Library Administrator', N'Administrator') and DOMAIN_NAME = N'SPOTFIRE')
      connect by prior GROUP_ID = MEMBER_GROUP_ID 
      start with MEMBER_USER_ID = caller;
  else 
    cnt := 0;
  end if;

  if (cnt = 0) then
    select count(*) into cnt
      from LIB_ACCESS 
      where ITEM_ID in 
        (select item.ITEM_ID from LIB_ITEMS item 
        left join LIB_ACCESS acl on item.ITEM_ID = acl.ITEM_ID
        connect by prior item.PARENT_ID = item.ITEM_ID 
        and prior acl.PERMISSION is null 
        start with item.ITEM_ID = itemId)
      and 
      (USER_ID = caller
      or GROUP_ID in (
        select gm.GROUP_ID from GROUP_MEMBERS_VIEW gm
          start with gm.MEMBER_USER_ID = caller
          connect by gm.MEMBER_GROUP_ID = prior gm.GROUP_ID
        )
      )
      and PERMISSION = requiredPermission;
  end if;

end usp_verifyAccess;
/

create or replace procedure usp_verifyWriteOnDescendants (
  itemId in LIB_ITEMS.ITEM_ID%type, 
  caller in LIB_ITEMS.MODIFIED_BY%type,
  administrationEnabled in number) as
cursor allDescendants is
  select ITEM_ID, PARENT_ID, ITEM_TYPE from LIB_ITEMS 
  connect by prior ITEM_ID = PARENT_ID 
  start with ITEM_ID = itemId;
cnt number;    
begin
  select count(*) into cnt from GROUP_MEMBERSHIPS;
  if (cnt = 0) then
    insert into GROUP_MEMBERSHIPS 
      select distinct gm.GROUP_ID from GROUP_MEMBERS_VIEW gm
      start with gm.MEMBER_USER_ID = caller
      connect by gm.MEMBER_GROUP_ID = prior gm.GROUP_ID;
  end if;

  if (administrationEnabled = 1) then
    select count(*) into cnt from GROUP_MEMBERSHIPS 
    where GROUP_ID in (select GROUP_ID from GROUPS 
                       where GROUP_NAME in (N'Library Administrator', N'Administrator') and DOMAIN_NAME = N'SPOTFIRE');
  else 
    cnt := 0;
  end if;

  if (cnt = 0) then
    for descendant in allDescendants
    loop
      if (descendant.ITEM_ID = itemId) then  -- is the parent readable
        select count(*) into cnt
          from LIB_ACCESS 
          where ITEM_ID in 
            (select item.ITEM_ID from LIB_ITEMS item 
            left join LIB_ACCESS acl on item.ITEM_ID = acl.ITEM_ID
            connect by prior item.PARENT_ID = item.ITEM_ID 
            and prior acl.PERMISSION is null 
            start with item.ITEM_ID = descendant.PARENT_ID)
          and (USER_ID = caller or GROUP_ID in (select GROUP_ID from GROUP_MEMBERSHIPS))
          and PERMISSION = 'W';
        if (cnt = 0) then
          raise_application_error(-20002, 'Insufficient access');
        end if;
      elsif (descendant.ITEM_TYPE = '4f83cd41-71b5-11dd-050e-00100a64217d') then -- only check descendant folders and only if they containt ACL settings
        select count(*) into cnt from LIB_ACCESS where ITEM_ID = descendant.ITEM_ID;
        if (cnt > 0) then
          select count(*) into cnt
            from LIB_ACCESS 
            where ITEM_ID = descendant.ITEM_ID 
            and (USER_ID = caller or GROUP_ID in (select GROUP_ID from GROUP_MEMBERSHIPS))
            and PERMISSION = 'W';
          if (cnt = 0) then
            raise_application_error(-20002, 'Insufficient access');
          end if;
        end if;
      end if;
    end loop;
  end if;

end usp_verifyWriteOnDescendants;
/

create or replace procedure usp_insertItem (
  newItemId in LIB_ITEMS.ITEM_ID%type,
  newTitle in LIB_ITEMS.TITLE%type,
  newDescription in LIB_ITEMS.DESCRIPTION%type,
  newItemType in LIB_ITEMS.ITEM_TYPE%type,
  newFormatVersion in LIB_ITEMS.FORMAT_VERSION%type,
  newContentSize in LIB_ITEMS.CONTENT_SIZE%type,
  newParentId in LIB_ITEMS.PARENT_ID%type,
  newHidden in LIB_ITEMS.HIDDEN%type,
  caller in LIB_ITEMS.CREATED_BY%type,
  verifyAccess in number,
  administrationEnabled in number) as
hasAccess number;
timeOfInsertion timestamp(6);
isContainer char(1);
cnt number;
begin
  -- Verify that the parent exists
  select count(1) into cnt from LIB_ITEMS where ITEM_ID = newParentId;
  if (cnt = 0) then
    raise_application_error(-20005, 'Item does not exist');
  end if;

  -- Verify that the parent is a container item
  select it.IS_CONTAINER into isContainer from LIB_ITEM_TYPES it, LIB_ITEMS i 
    where i.ITEM_TYPE = it.TYPE_ID
    and i.ITEM_ID = newParentId;
  if (isContainer = '0') then
    raise_application_error(-20004, 'Invalid parent item');
  end if;

    -- Verify access
  if (verifyAccess = 1) then
    usp_verifyAccess (newParentId, caller, 'W', administrationEnabled, hasAccess);
    if (hasAccess = 0) then
      raise_application_error(-20002, 'Insufficient access');
    end if;
  end if;

  -- Verify that the ID is unique
  select count(1) into cnt from LIB_ITEMS where ITEM_ID = newItemId;
  if (cnt > 0) then
    raise_application_error(-20001, 'Item already exists');
  end if;

  -- Verify that the title-type-parent combination is unique
  select count(1) into cnt from LIB_ITEMS where upper(TITLE) = upper(newTitle) and ITEM_TYPE = newItemType and PARENT_ID = newParentId;
  if (cnt > 0) then
    raise_application_error(-20001, 'Item already exists');
  end if;

  -- Verify that the maximum folder depth is not exceeded
  select max(level) into cnt from LIB_ITEMS connect by prior PARENT_ID = ITEM_ID start with ITEM_ID = newParentId;
  if (cnt > 99) then
    raise_application_error(-20003, 'Maximum folder depth exceeded');
  end if;

  -- Store the current timestamp
  select sys_extract_utc(systimestamp) into timeOfInsertion from DUAL;

  -- Insert the item
  insert into LIB_ITEMS (ITEM_ID, TITLE, DESCRIPTION, ITEM_TYPE, FORMAT_VERSION, CREATED_BY, 
      CREATED, MODIFIED_BY, MODIFIED, CONTENT_SIZE, PARENT_ID, HIDDEN)
    values (newItemId, newTitle, newDescription, newItemType, newFormatVersion, caller, timeOfInsertion, 
      caller, timeOfInsertion, newContentSize, newParentId, newHidden);

  -- Move any unresolved dependencies upon the inserted item into the set of resolved dependencies
  insert into LIB_RESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID)
  (
    select DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID 
    from LIB_UNRESOLVED_DEPEND
    where REQUIRED_ID = newItemId
  );
  delete from LIB_UNRESOLVED_DEPEND where REQUIRED_ID = newItemId;

end usp_insertItem;
/

create or replace procedure usp_updateItem (
  itemId in LIB_ITEMS.ITEM_ID%type,
  newTitle in LIB_ITEMS.TITLE%type,
  newDescription in LIB_ITEMS.DESCRIPTION%type,
  newFormatVersion in LIB_ITEMS.FORMAT_VERSION%type,
  newHidden in LIB_ITEMS.HIDDEN%type,
  caller in LIB_ITEMS.MODIFIED_BY%type,
  verifyAccess in number,
  administrationEnabled in number,
  contentSize in out number) as
parentId char(36);
itemType char(36);
hasAccess number;
timeOfUpdate timestamp(6);
cnt number;
begin
  -- Verify that the item exists
  select count(1) into cnt from LIB_ITEMS where ITEM_ID = itemId;
  if (cnt = 0) then
    raise_application_error(-20005, 'Item does not exist');
  end if;

  -- Fetch and store the parent ID, the item type and the current timestamp
  select PARENT_ID, ITEM_TYPE, sys_extract_utc(systimestamp) into parentId, itemType, timeOfUpdate from LIB_ITEMS where ITEM_ID = itemId;

  -- Verify access
  if (verifyAccess = 1) then
    usp_verifyAccess (parentId, caller, 'W', administrationEnabled, hasAccess);
    if (hasAccess = 0) then
      raise_application_error(-20002, 'Insufficient access');
    end if;
  end if;

  -- Verify that the title-type-parent combination is unique
  select count(1) into cnt from LIB_ITEMS
    where upper(TITLE) = upper(newTitle) and ITEM_TYPE = itemType and PARENT_ID = parentId and ITEM_ID != itemId;
  if (cnt > 0) then
    raise_application_error(-20001, 'Item already exists');
  end if;

  -- Update the item
  if (contentSize = 0) then
  update LIB_ITEMS set TITLE = newTitle, DESCRIPTION = newDescription, FORMAT_VERSION = newFormatVersion, 
      MODIFIED_BY = caller, MODIFIED = timeOfUpdate, HIDDEN = newHidden where ITEM_ID = itemId;
  else
    update LIB_ITEMS set TITLE = newTitle, DESCRIPTION = newDescription, FORMAT_VERSION = newFormatVersion, 
      MODIFIED_BY = caller, MODIFIED = timeOfUpdate, CONTENT_SIZE = contentSize, HIDDEN = newHidden where ITEM_ID = itemId;
  end if;

end usp_updateItem;
/

-- Stored procedure used for deleting items
create or replace procedure usp_deleteItem (
  itemId in LIB_ITEMS.ITEM_ID%type, 
  caller in LIB_ITEMS.MODIFIED_BY%type,
  verifyAccess in number,
  administrationEnabled in number,
  allowUnresolvedDependencies in number) as
cursor dependentItemsCascadingDelete is
    select DEPENDENT_ID
    from LIB_RESOLVED_DEPEND
    where CASCADING_DELETE = '1'
    and REQUIRED_ID in (select DESCENDANT_ID from LIB_TEMP_DESCENDANTS where ANCESTOR_ID = itemId)
    minus (select DESCENDANT_ID from LIB_TEMP_DESCENDANTS where ANCESTOR_ID = itemId);
cnt number;
parentId LIB_ITEMS.PARENT_ID%type;
timeOfDeletion LIB_ITEMS.MODIFIED%type;
begin
  -- If the item has already been deleted there is nothing more to do
  select count(1) into cnt from LIB_ITEMS where ITEM_ID = itemId;
  if (cnt = 0) then
    return;
  end if;

  -- Verify access
  if (verifyAccess = 1) then
    usp_verifyWriteOnDescendants(itemId, caller, administrationEnabled);
  end if;
  
  -- Fetch the parent ID and verify that it's not null (cannot delete the root item)
  select PARENT_ID, sys_extract_utc(systimestamp) into parentId, timeOfDeletion from LIB_ITEMS where ITEM_ID = itemId;
  if (parentId is null) then
    raise_application_error(-20004, 'Cannot delete the root item');
  end if;
  
  -- Fetch all descendants
  insert into LIB_TEMP_DESCENDANTS (ANCESTOR_ID, DESCENDANT_ID) 
    select itemId, ITEM_ID from LIB_ITEMS 
    connect by prior ITEM_ID = PARENT_ID 
    start with ITEM_ID = itemId;
  
  -- If creating dangling references is disallowed we need to verify that no dependencies upon the items 
  -- being deleted exists. 
  if (allowUnresolvedDependencies = 0) then
    select count(1) into cnt
      from LIB_RESOLVED_DEPEND rd, LIB_TEMP_DESCENDANTS ds
      where rd.CASCADING_DELETE = '0' 
      and rd.REQUIRED_ID = ds.DESCENDANT_ID
      and ds.ANCESTOR_ID = itemId;
    if (cnt > 0) then
      raise_application_error(-20006, 'Dependencies without cascading delete found');
    end if;
  end if;

  -- Move any dependency declarations, with non-cascading delete, upon the item being deleted 
  -- and all of its descendants from the set of resolved dependencies to the set of unresolved 
  -- dependencies.
  insert into LIB_UNRESOLVED_DEPEND (DEPENDENT_ID, REQUIRED_ID, DESCRIPTION, CASCADING_DELETE, ORIGINAL_REQUIRED_ID) 
    (
      select rd.DEPENDENT_ID, rd.REQUIRED_ID, rd.DESCRIPTION, rd.CASCADING_DELETE, rd.ORIGINAL_REQUIRED_ID 
      from LIB_RESOLVED_DEPEND rd, LIB_TEMP_DESCENDANTS ds
      where rd.CASCADING_DELETE = '0' 
      and rd.REQUIRED_ID = ds.DESCENDANT_ID
      and ds.ANCESTOR_ID = itemId
    );
      
  -- Delete all dependent items with cascading delete
  for dependentItem in dependentItemsCascadingDelete
  loop
    usp_deleteItem (dependentItem.DEPENDENT_ID, caller, verifyAccess, administrationEnabled, allowUnresolvedDependencies);
  end loop;
      
  -- Delete all declarations of depencencies upon the item and all of its descendants
  delete from LIB_RESOLVED_DEPEND where REQUIRED_ID in 
    (select DESCENDANT_ID from LIB_TEMP_DESCENDANTS where ANCESTOR_ID = itemId);

  -- Delete the item itself and any descendants
  delete from LIB_ITEMS where ITEM_ID in 
    (select DESCENDANT_ID from LIB_TEMP_DESCENDANTS where ANCESTOR_ID = itemId);

  -- Touch the parent
  update LIB_ITEMS set MODIFIED_BY = caller, MODIFIED = timeOfDeletion where ITEM_ID = parentId;

end usp_deleteItem;
/

create or replace procedure usp_finishDelete(
  deleted out sys_refcursor)
as
begin
	open deleted for
    select DESCENDANT_ID from LIB_TEMP_DESCENDANTS;
end usp_finishDelete;
/

/* ----------------- configuration --------------------- */

create table SERVER_CONFIGURATIONS (
    CONFIG_HASH char(40) not null,
    CONFIG_DATE timestamp(0) not null,
    CONFIG_VERSION varchar2(50) not null,
    CONFIG_DESCRIPTION nvarchar2(1000) not null,
    CONFIG_CONTENT blob not null, 
    constraint PK_SERVER_CONFIGURATIONS primary key (CONFIG_HASH) )
/

create table CONFIG_HISTORY (
    CONFIG_HASH char(40) not null,
    CONFIG_DATE timestamp(0) not null,
    CONFIG_COMMENT nvarchar2(1000) not null,
    constraint PK_CONFIG_HISTORY PRIMARY KEY (CONFIG_HASH, CONFIG_DATE),
    constraint FK_CONFIG_HISTORY_CONFIG_HASH foreign key (CONFIG_HASH)
      references SERVER_CONFIGURATIONS (CONFIG_HASH) on delete cascade )
/

/* ----------------- JMX --------------------- */

create table JMX_USERS (
  USER_NAME nvarchar2(200) not null,
  PASSWORD_HASH varchar2(150) not null,
  ACCESS_LEVEL varchar2(20) not null,
  constraint JMX_USERS_PK primary key (USER_NAME) )
/

/* ------------------ nodes ------------------ */
create table SITES (
   SITE_ID char(36) not null,
   NAME nvarchar2(200) not null,
   PROPERTIES_JSON blob null,
   constraint PK_SITES primary key (SITE_ID)
)
/

create unique index SITES_NAME_INDEX on SITES(upper(NAME))
/

create table NODES(
   ID char(36) NOT NULL,
   DEPLOYMENT_AREA char(36),
   IS_ONLINE smallint,
   PLATFORM varchar(36),
   PORT varchar(5) NOT NULL,
   CLEAR_TEXT_PORT varchar(5) DEFAULT 0,
   PRIMUS_CAPABLE smallint,   
   BUNDLE_VERSION varchar(200),
   PRODUCT_VERSION varchar(200),
   SITE_ID char(36) not null,
   constraint PK_NODES primary key (ID),
   constraint FK_NODES_SITE_ID foreign key (SITE_ID) references SITES (SITE_ID)
)
/
alter table NODES add constraint FK_NODES_AREA_ID foreign key(DEPLOYMENT_AREA) references DEP_AREAS_DEF(AREA_ID) on delete set null
/

CREATE INDEX NODES_PRIMUS_CAPABLE ON NODES(PRIMUS_CAPABLE)
/

CREATE INDEX NODES_PRIMUS_CAPABLE_ONLINE ON NODES(PRIMUS_CAPABLE, IS_ONLINE)
/

CREATE INDEX NODES_ONLINE ON NODES(IS_ONLINE)
/

CREATE INDEX NODES_SITES ON NODES(SITE_ID)
/


create table NODE_SERVER_INFO(
   NODE_ID char(36) NOT NULL,
   SERVERNAME varchar(200) NOT NULL,
   PRIORITY smallint
)
/

alter table NODE_SERVER_INFO add constraint FK_NODE_SERVER_INFO_ID_NODES foreign key(NODE_ID) references NODES(ID) on delete cascade
/

CREATE INDEX NODE_SERVER_INFO_NODE_ID on NODE_SERVER_INFO (NODE_ID)
/

CREATE INDEX NODE_SERVER_INFO_ID_PRIO ON NODE_SERVER_INFO(NODE_ID, PRIORITY)
/

/* ----------------- server life cycle events --------------------- */

create table LIFECYCLE_EVENTS (
    SERVER_NAME varchar2(250) not null,
    SERVER_IP varchar2(100) not null,
    SERVER_VERSION varchar2(250) not null,
    EVENT_DATE timestamp(0) not null,
    EVENT_NAME varchar2(250) not null,
    IS_PRIMUS char(1) not null,
    IS_SITE_PRIMUS char(1) not null,
    NODE_ID char(36) null,
    constraint PK_LIFECYCLE_EVENTS primary key ( EVENT_NAME, EVENT_DATE, SERVER_NAME ),
    constraint FK_LIFECYCLE_EVENTS_NODE_ID foreign key (NODE_ID) references NODES (ID) on delete set null
)
/

CREATE INDEX LIFECYCLE_EVENTS_PRIMUS ON LIFECYCLE_EVENTS(IS_PRIMUS)
/

CREATE INDEX LIFECYCLE_EVENTS_SITE_PRIMUS ON LIFECYCLE_EVENTS(IS_SITE_PRIMUS)
/

CREATE INDEX LIFECYCLE_EVENTS_EVENT_NAME ON LIFECYCLE_EVENTS(EVENT_NAME)
/

CREATE INDEX LIFECYCLE_EVENT_NODE_EVENT ON LIFECYCLE_EVENTS(NODE_ID, EVENT_NAME)
/

/* ------------------ types of services provided by the node manager ------------------ */
create table NODE_SERVICE_TYPES(
    ID smallint NOT NULL,
    SERVICE_TYPE char(36),
    constraint PK_NODE_SERVICE_TYPES primary key (ID)
)
/

/* ------------------ services managed by the node manager ------------------ */
create table NODE_SERVICES(
   ID char(36) NOT NULL,  
   NODE_ID char(36) NOT NULL,
   SERVICE_TYPE smallint NOT NULL, 
   SERVICENAME varchar(200) NOT NULL, 
   SERVICEVERSION varchar(100) NOT NULL, 
   WORKING_DIR varchar(255), 
   CAPABILITIES varchar(200) NOT NULL, 
   EXTERNALLY_MANAGED smallint NULL, 
   EXTERNALLY_STARTED smallint NULL, 
   ON_STOP_STATUS varchar(36) NOT NULL, 
   RESTART_ON_STOP varchar(36) NOT NULL,
   SERVICE_MANAGER varchar(200), 
   STARTUP_COMMAND varchar(255), 
   DEPLOYMENT_AREA char(36), 
   REPLACED_BY_ID char(36), 
   STATUS varchar(36) NOT NULL, 
   NEXT_STATUS varchar(36) NOT NULL, 
   URL varchar(200) NULL,
   BUNDLE_VERSION varchar(200),
   VERSIONHASH varchar(64),
   TECHVERSION varchar(64),
   constraint PK_NODE_SERVICES primary key(ID)
)
/

alter table NODE_SERVICES add constraint FK_NODE_SERVICES_AREA_ID foreign key(DEPLOYMENT_AREA) references DEP_AREAS_DEF(AREA_ID) on delete set null
/

create table NODE_SERVICES_PKGS (
    ID CHAR(36) NOT NULL,
    SERVICE_ID CHAR(36) NOT NULL,
    PACKAGE_ID CHAR(36) NOT NULL,
    NAME varchar(200) NOT NULL,
    VERSION varchar(32) NOT NULL,
    INTENDED_CLIENT varchar(32) NOT NULL,
    INTENDED_PLATFORM varchar(32) NOT NULL,
    LAST_MODIFIED timestamp DEFAULT CURRENT_TIMESTAMP,
    constraint PK_NODE_SERVICES_PKGS primary key(ID)
)
/

alter table NODE_SERVICES_PKGS add constraint FK_NSPKGS_NODE_SERVICES_ID foreign key(SERVICE_ID) references NODE_SERVICES(ID) on delete cascade
/

create table SERVICE_CONFIGS (
  CONFIG_ID char(36) not null,
  CONFIG_NAME nvarchar2(200) not null,
  CAPABILITY varchar2(200) not null,
  PKG_ID char(36) not null,
  PKG_VERSION varchar2(32) not null,
  IS_DEFAULT char(1) not null,
  MODIFICATION_DATE timestamp(0) not null,
  DATA blob not null,
  CONFIG_VERSION varchar(50) DEFAULT '1' not null,
  constraint PK_SERVICE_CONFIGS primary key (CONFIG_ID)
)
/

create unique index SERVICE_CONFIGS_CONFIG_NAME_IX
  on SERVICE_CONFIGS (CONFIG_NAME)
/

create table ACTIVE_SERVICE_CONFIGS (
  SERVICE_ID char(36) not null,
  CONFIG_ID char(36) not null,
  CONFIG_VERSION varchar(50) DEFAULT '1' not null,
  constraint PK_ACTIVE_SERVICE_CONFIGS primary key (SERVICE_ID, CONFIG_ID),
  constraint FK_A_S_C_SERVICE_ID foreign key (SERVICE_ID)
    references NODE_SERVICES (ID) on delete cascade,
  constraint FK_A_S_C_CONFIG_ID foreign key (CONFIG_ID)
    references SERVICE_CONFIGS (CONFIG_ID) on delete cascade
)
/

create table SITE_SERVICE_CONFIGS (
  SITE_ID char(36) not null,
  CAPABILITY varchar2(200) not null,
  CONFIG_ID char(36) not null,
  constraint PK_SITE_SERVICE_CONFIGS primary key (CAPABILITY),
  constraint FK_SSC_SITE_ID foreign key (SITE_ID)
    references SITES (SITE_ID) on delete cascade,
  constraint FK_SSC_CONFIG_ID foreign key (CONFIG_ID)
    references SERVICE_CONFIGS (CONFIG_ID) on delete cascade
)
/

alter table NODE_SERVICES add constraint FK_NODE_ID_NODES foreign key(NODE_ID) references NODES(ID) on delete cascade
/

alter table NODE_SERVICES add constraint FK_SERVICE_TYPE_NODE_SVCS_TYPE foreign key(SERVICE_TYPE) references NODE_SERVICE_TYPES(ID)
/

CREATE INDEX NODE_SERVICES_NODE_ID on NODE_SERVICES (NODE_ID)
/

CREATE INDEX NODE_SERVICES_N_ID_W_DIR_TYPE on NODE_SERVICES (NODE_ID,WORKING_DIR,SERVICE_TYPE)
/

CREATE INDEX NODE_SERVICES_N_ID_W_DIR on NODE_SERVICES (NODE_ID,WORKING_DIR)
/

CREATE INDEX NODE_SERVICES_N_ID_TYPE on NODE_SERVICES (NODE_ID,SERVICE_TYPE)
/

CREATE INDEX NODE_SERVICES_TYPE_REPLACED on NODE_SERVICES (SERVICE_TYPE, REPLACED_BY_ID)
/


create table NODE_AUTH_REQUEST(
   ID char(36) NOT NULL,
   CSR BLOB NOT NULL,
   LAST_MODIFIED TIMESTAMP null,
   FINGERPRINT varchar2(128) null,
   constraint PK_NODE_AUTH_REQUEST primary key(ID)
)
/

alter table NODE_AUTH_REQUEST add constraint FK_ID_NODES foreign key(ID) references NODES(ID) on delete cascade
/

create table NODE_EVENT_BUS( 
   ID char(36) NOT NULL,
   NODE_ID char(36) NOT NULL,
   COMMAND_ID char(36) NOT NULL,
   USER_ID char(36) DEFAULT NULL,
   EVENT_TYPE smallint NOT NULL,
   EVENT_SUB_TYPE char(36) NOT NULL,
   EVENT_DATA CLOB,
   LAST_MODIFIED timestamp DEFAULT CURRENT_TIMESTAMP,
   constraint PK_NODE_EVENT_BUS primary key(ID)
)
/

alter table NODE_EVENT_BUS add constraint FK_NODE_ID_EVENT_BUS foreign key(NODE_ID) references NODES(ID) on delete cascade
/

alter table NODE_EVENT_BUS add constraint FK_USERS_ID_EVENT_BUS foreign key(USER_ID) references USERS(USER_ID) on delete set null
/

CREATE INDEX NODE_EVENT_BUS_NODE_IDX ON NODE_EVENT_BUS (NODE_ID)
/

CREATE INDEX NODE_EVENT_BUS_COMMAND_IDX ON NODE_EVENT_BUS (COMMAND_ID)
/

CREATE INDEX NODE_EVENT_BUS_INDEX_CID on NODE_EVENT_BUS (COMMAND_ID,LAST_MODIFIED)
/

CREATE INDEX NODE_EVENT_BUS_INDEX_NID on NODE_EVENT_BUS (NODE_ID,LAST_MODIFIED)
/

CREATE INDEX NODE_EVENT_BUS_INDEX_NID_EST on NODE_EVENT_BUS (COMMAND_ID,EVENT_SUB_TYPE,LAST_MODIFIED)
/

CREATE INDEX NODE_EVENT_BUS_COMMAND_TYPE on NODE_EVENT_BUS(COMMAND_ID, EVENT_TYPE)
/

CREATE INDEX NODE_EVENT_BUS_N_E_STYPE on NODE_EVENT_BUS(NODE_ID, EVENT_SUB_TYPE)
/

create table NODE_STATUS ( 
   ID char(36) NOT NULL,
   FROM_ID char(36) NOT NULL, 
   TO_ID char(36) NOT NULL, 
   SERVICE_ID char(36) DEFAULT NULL,
   CAN_COMMUNICATE smallint default 0, 
   STATUS_CODE smallint, 
   MESSAGE varchar(1000), 
   SINCE timestamp DEFAULT CURRENT_TIMESTAMP,
   LAST_MODIFIED timestamp DEFAULT CURRENT_TIMESTAMP, 
   constraint PK_NODE_STATUS primary key(ID)
)
/

alter table NODE_STATUS add constraint FK_FROM_ID_NODE_STATUS foreign key(FROM_ID) references NODES(ID) on delete cascade
/

alter table NODE_STATUS add constraint FK_TO_ID_NODE_STATUS foreign key(TO_ID) references NODES(ID) on delete cascade
/

alter table NODE_STATUS add constraint FK_SERVICE_ID_NODE_STATUS foreign key(SERVICE_ID) references NODE_SERVICES(ID) on delete cascade
/

CREATE INDEX NODE_STATUS_INDEX_TO_ID on NODE_STATUS (TO_ID)
/

CREATE INDEX NODE_STATUS_INDEX_FROM_ID on NODE_STATUS (FROM_ID)
/

CREATE INDEX NODE_STATUS_TO_SERVICE ON NODE_STATUS(TO_ID, SERVICE_ID)
/

CREATE INDEX NODE_STATUS_TO_FROM ON NODE_STATUS(TO_ID, FROM_ID)
/

CREATE INDEX NODE_STATUS_INDEX_SERVICE_ID on NODE_STATUS (SERVICE_ID)
/

CREATE INDEX NODE_STATUS_IDX_TO_FROM_SRVC on NODE_STATUS (TO_ID,FROM_ID,SERVICE_ID)
/

CREATE UNIQUE INDEX NODE_STATUS_ITEM ON NODE_STATUS(FROM_ID, TO_ID, SERVICE_ID)
/

create table CERTIFICATES (
  SERIAL_NUMBER VARCHAR2(40) not null,
  NODE_ID CHAR(36) null,
  SUBJECT_DN VARCHAR2(400) not null,
  STATUS VARCHAR2(10) not null,
  EXPIRATION_DATE TIMESTAMP null,
  REVOCATION_DATE TIMESTAMP null,
  KEYSTORE BLOB null,
  constraint CERTIFICATES_PK primary key (SERIAL_NUMBER) )
/

alter table CERTIFICATES add constraint FK_CERTIFICATES_NODE_ID_NODES foreign key(NODE_ID) references NODES(ID) on delete set null
/

CREATE INDEX CERTIFICATES_STATUS ON CERTIFICATES(NODE_ID,STATUS)
/

/* ------------------ Code Trust ------------------ */

create table "KEYSTORE_PASSWORDS" (
  "KEYSTORE" varchar2(40) not null,
  "PASSWORD" varchar2(400) not null,
  constraint "KEYSTORE_PASSWORDS_PK" primary key ("KEYSTORE")
)
/

create table "CT_CERTS" (
  "USER_ID" char(36) null,
  "SERIAL_NUMBER" varchar2(40) not null,
  "SUBJECT_DN" nvarchar2(400) not null,
  "STATUS" varchar2(10) not null,
  "VALID_FROM" timestamp null,
  "EXPIRATION_DATE" timestamp null,
  "REVOCATION_DATE" timestamp null,
  "KEYSTORE" blob null,
  constraint "CT_CERTS_PK" primary key ("SERIAL_NUMBER"),
  constraint "FK_CT_CERTS_USER" foreign key ("USER_ID")
    references "USERS" ("USER_ID") on delete set null)
/

create index "CT_CERTS_USER_IDX"
  on "CT_CERTS" ("USER_ID")
/

create table "CT_EXTCERTS" (
  "ISSUER" nvarchar2(400) not null,
  "SERIAL_NUMBER" varchar2(40) not null,
  "SUBJECT_DN" nvarchar2(400) not null,
  "STATUS" varchar2(10) not null,
  "ADDED_DATE" timestamp null,
  "KEYSTORE" blob null,
  constraint "CT_EXTCERTS_PK" primary key ("ISSUER", "SERIAL_NUMBER"))
/

create table "CT_CODE_ENTITIES" (
  "TYPE" varchar2(60) not null,
  "HASH" varchar2(180) not null,
  "STATUS" varchar2(10) not null,
  "ADDED_DATE" timestamp null,
  "METADATA_JSON" blob not null,
  constraint CT_CODE_ENTITIES_PK primary key ("TYPE", "HASH"))
/

create table "TRUSTED_CODE_ENTITIES" (
  "TRUSTED_TYPE" varchar2(60) not null,
  "TRUSTED_HASH" varchar2(180) not null,
  "TRUSTING_USER_ID" char(36) null,
  "TRUSTING_GROUP_ID" char(36) null,
  "ADDED_DATE" timestamp null,
  "USED_DATE" timestamp null,
  constraint "FK_TRUSTED_CODE_ENTITIES1" foreign key ("TRUSTED_TYPE", "TRUSTED_HASH")
    references "CT_CODE_ENTITIES" ("TYPE", "HASH") on delete cascade,
  constraint "FK_TRUSTED_CODE_ENTITIES2" foreign key ("TRUSTING_USER_ID")
    references "USERS" ("USER_ID") on delete cascade,
  constraint "FK_TRUSTED_CODE_ENTITIES3" foreign key ("TRUSTING_GROUP_ID")
    references "GROUPS" ("GROUP_ID") on delete cascade)
/

create unique index "TRUSTED_CODE_ENTITIES_IX" on "TRUSTED_CODE_ENTITIES" (
  "TRUSTED_TYPE",
  "TRUSTED_HASH",
  "TRUSTING_USER_ID",
  "TRUSTING_GROUP_ID")
/

create index "TRUSTED_CODE_ENTITIES_IDX1"
  on "TRUSTED_CODE_ENTITIES" ("TRUSTING_USER_ID")
/

create index "TRUSTED_CODE_ENTITIES_IDX2"
  on "TRUSTED_CODE_ENTITIES" ("TRUSTING_GROUP_ID")
/

alter table "TRUSTED_CODE_ENTITIES" add constraint "TRUSTED_CODE_ENTITIES_XOR" check (
  ("TRUSTING_USER_ID" is null and "TRUSTING_GROUP_ID" is not null)
  or
  ("TRUSTING_USER_ID" is not null and "TRUSTING_GROUP_ID" is null))
/

create table TRUSTED_CERTS (
  "TRUSTED_ISSUER" nvarchar2(400) not null,
  "TRUSTED_SERIAL_NUMBER" varchar2(40) not null,
  "TRUSTING_USER_ID" char(36) null,
  "TRUSTING_GROUP_ID" char(36) null,
  "ADDED_DATE" timestamp null,
  "USED_DATE" timestamp null,
  constraint "FK_TRUSTED_CERTS1" foreign key ("TRUSTED_ISSUER", "TRUSTED_SERIAL_NUMBER")
    references "CT_EXTCERTS" ("ISSUER", "SERIAL_NUMBER") on delete cascade,
  constraint "FK_TRUSTED_CERTS2" foreign key ("TRUSTING_USER_ID")
    references "USERS" ("USER_ID") on delete cascade,
  constraint "FK_TRUSTED_CERTS3" foreign key ("TRUSTING_GROUP_ID")
    references "GROUPS" ("GROUP_ID") on delete cascade)
/

create unique index "TRUSTED_CERTS_IX" on "TRUSTED_CERTS" (
  "TRUSTED_ISSUER",
  "TRUSTED_SERIAL_NUMBER",
  "TRUSTING_USER_ID",
  "TRUSTING_GROUP_ID")
/

alter table "TRUSTED_CERTS" add constraint "TRUSTED_CERTS_XOR" check (
  ("TRUSTING_USER_ID" is null and "TRUSTING_GROUP_ID" is not null)
  or
  ("TRUSTING_USER_ID" is not null and "TRUSTING_GROUP_ID" is null))
/

create table TRUSTED_USERS (
  "TRUSTED_USER_ID" char(36) not null,
  "TRUSTING_USER_ID" char(36) null,
  "TRUSTING_GROUP_ID" char(36) null,
  constraint "FK_TRUSTED_USERS1" foreign key ("TRUSTED_USER_ID")
    references "USERS" ("USER_ID") on delete cascade,
  constraint "FK_TRUSTED_USERS2" foreign key ("TRUSTING_USER_ID")
    references "USERS" ("USER_ID") on delete cascade,
  constraint "FK_TRUSTED_USERS3" foreign key ("TRUSTING_GROUP_ID")
    references "GROUPS" ("GROUP_ID") on delete cascade)
/

alter table "TRUSTED_USERS" add constraint "TRUSTED_USERS_XOR" check (
  ("TRUSTING_USER_ID" is null and "TRUSTING_GROUP_ID" is not null)
  or
  ("TRUSTING_USER_ID" is not null and "TRUSTING_GROUP_ID" is null))
/

create unique index "TRUSTED_USERS_IX" on "TRUSTED_USERS" (
  "TRUSTED_USER_ID",
  "TRUSTING_USER_ID",
  "TRUSTING_GROUP_ID")
/

create table "CT_THIRD_PARTY_ROOTCERTS" (
  "ISSUER" nvarchar2(400) not null,
  "SERIAL_NUMBER" varchar2(40) not null,
  "SUBJECT_DN" nvarchar2(400) not null,
  "ADDED_DATE" timestamp null,
  "KEYSTORE" blob null,
  constraint "THIRD_PARTY_ROOTCERTS_PK" primary key ("ISSUER", "SERIAL_NUMBER"))
/

create index "TRUSTED_USERS_IX1" on "TRUSTED_USERS" ("TRUSTING_GROUP_ID")
/

create index "TRUSTED_USERS_IX2" on "TRUSTED_USERS" ("TRUSTING_USER_ID")
/

create index "TRUSTED_CERTS_IX1" on "TRUSTED_CERTS" ("TRUSTING_GROUP_ID")
/

create index "TRUSTED_CERTS_IX2" on "TRUSTED_CERTS" ("TRUSTING_USER_ID")
/

create table "CT_BLOCKED_USERS" (
  "USER_ID" char(36) not null,
  "BLOCKED_DATE" timestamp not null,
  constraint "CT_BLOCKED_USERS_PK" primary key ("USER_ID"),
  constraint "FK_CT_BLOCKED_USERS" foreign key ("USER_ID")
    references "USERS" ("USER_ID") on delete cascade
)
/

/* ------------------ OAuth2 Authorization Server ------------------ */

create table OAUTH2_CLIENTS (
  CLIENT_ID varchar2(100 char) not null,
  JSON blob not null,
  constraint OAUTH2_CLIENTS_PK primary key (CLIENT_ID) )
/

create table OAUTH2_AUTH_CODES (
  CODE varchar2(200 char) not null,
  EXPIRES_AT timestamp(0) not null,
  JSON blob not null,
  constraint OAUTH2_AUTH_CODES_PK primary key (CODE) )
/

create table OAUTH2_ACCESS_TOKENS (
  ACCESS_TOKEN varchar2(200 char) not null,
  ACCESS_TOKEN_EXP_AT timestamp(0) not null,
  JSON blob not null,
  constraint OAUTH2_ACCESS_TOKENS_PK primary key (ACCESS_TOKEN) )
/

create table OAUTH2_REFRESH_TOKENS (
  REFRESH_TOKEN varchar2(200 char) not null,
  REFRESH_TOKEN_EXP_AT timestamp(0) not null,
  USER_ID char(36) not null,
  CLIENT_ID varchar2(100 char) not null,
  JSON blob not null,
  constraint OAUTH2_REFRESH_TOKENS_PK primary key (REFRESH_TOKEN),
  constraint OAUTH2_REFRESH_TOKENS_FK1 foreign key (USER_ID) references USERS (USER_ID) on delete cascade,
  constraint OAUTH2_REFRESH_TOKENS_FK2 foreign key (CLIENT_ID) references OAUTH2_CLIENTS (CLIENT_ID) on delete cascade )
/
create index REFRESH_TOKENS_IX1 on OAUTH2_REFRESH_TOKENS (USER_ID)
/
create index REFRESH_TOKENS_IX2 on OAUTH2_REFRESH_TOKENS (CLIENT_ID)
/

create table OAUTH2_CONSENT (
  USER_ID char(36) not null,
  CLIENT_ID varchar2(100 char) not null,
  JSON blob not null,
  constraint OAUTH2_CONSENT_PK primary key (USER_ID, CLIENT_ID),
  constraint OAUTH2_CONSENT_FK1 foreign key (USER_ID) references USERS (USER_ID) on delete cascade,
  constraint OAUTH2_CONSENT_FK2 foreign key (CLIENT_ID) references OAUTH2_CLIENTS (CLIENT_ID) on delete cascade )
/
create index OAUTH2_CONSENT_IX1 on OAUTH2_CONSENT (USER_ID)
/
create index OAUTH2_CONSENT_IX2 on OAUTH2_CONSENT (CLIENT_ID)
/

create table OAUTH2_KEYS (
  KEY_ID varchar2(200 char) not null,
  EXP_AT timestamp(0) not null,
  REV_AT timestamp(0) null,
  JSON blob not null,
  constraint OAUTH2_KEYS_PK primary key (KEY_ID) )
/

/* ------------------ static routing tables ------------------ */
create table ROUTING_RULES(
	ID char(36) NOT NULL,
	NAME nvarchar2(256) NOT NULL,
	ENTITY_VALUE nclob NULL,
    ENTITY_TYPE smallint NULL,
	LIB_ITEM_ID char(36) NULL,
	GROUP_ID char(36) NULL,
	USER_ID char(36) NULL,
	RESOURCE_POOL_ID char(36) NULL,
	SITE_ID char(36) NULL,
	PRIORITY integer NOT NULL,
	STATUS smallint NOT NULL,
	TYPE char(1) DEFAULT('R') NOT NULL,
	LAST_MODIFIED timestamp NULL,
	LAST_MODIFIED_BY char(36) NULL,	
	SCHEDULING_STATUS smallint NULL,
	SCHEDULED_BY_NODE char(36) NULL,
	CAPABILITY varchar2(200) NOT NULL,
    constraint PK_ROUTING_RULES primary key (ID),
	constraint ROUTING_RULES_UC1 unique(PRIORITY, SITE_ID))
/
 
CREATE INDEX ROUTING_RULES_SITES ON ROUTING_RULES(SITE_ID)
/

create index IX_RR_RESOURCE_POOL_ID on ROUTING_RULES(RESOURCE_POOL_ID) 
/

CREATE INDEX IX_ROUTING_RULES_TYPE ON ROUTING_RULES(TYPE)
/

CREATE INDEX IX_RR_TYPE_SITE ON ROUTING_RULES(TYPE, SITE_ID)
/

CREATE INDEX IX_RR_TYPE_SITE_STATUS ON ROUTING_RULES(TYPE, SITE_ID, STATUS)
/

CREATE INDEX IX_RR_SITE_CAPABILITY ON ROUTING_RULES(SITE_ID, CAPABILITY)
/

CREATE INDEX IX_RR_TYPE_CA ON ROUTING_RULES(TYPE, CAPABILITY)
/

CREATE INDEX IX_RR_TYPE_SITE_CA ON ROUTING_RULES(TYPE, SITE_ID, CAPABILITY)
/

CREATE INDEX IX_RR_TYPE_SITE_ENTITY_CA ON ROUTING_RULES(TYPE, SITE_ID, ENTITY_TYPE, CAPABILITY)
/

CREATE INDEX IX_RR_TYPE_SITE_STATUS_CA ON ROUTING_RULES(TYPE, SITE_ID, STATUS, CAPABILITY)
/

CREATE INDEX IX_ROUTING_RULES_ITEM_CA ON ROUTING_RULES(TYPE, SITE_ID, ENTITY_TYPE, STATUS, CAPABILITY)
/

create table SERVICE_ATTRIBUTES(
	ID char(36) NOT NULL,
	ATTRIBUTE_TYPE varchar(64) NOT NULL,
	ATTRIBUTE_KEY varchar(32),
	VALUE nvarchar2(256) NOT NULL,
    constraint PK_SERVICE_ATTRIBUTES primary key (ID)
	)
/

CREATE INDEX SERVICE_ATTRIBUTES_TYPE_IDX ON SERVICE_ATTRIBUTES (ATTRIBUTE_TYPE)
/

CREATE INDEX SERVICE_ATTRIBUTES_T_VAL_IDX ON SERVICE_ATTRIBUTES (ATTRIBUTE_TYPE, VALUE)
/

create table NODE_SERVICES_ATTRIBUTES(
	ATTRIBUTE_ID char(36) NOT NULL,
	SERVICE_ID char(36) NOT NULL,	
    constraint PK_NODE_SERVICES_ATTRIBUTES primary key (ATTRIBUTE_ID, SERVICE_ID)	
	)
/

create table RESOURCE_POOLS(
	ID char(36) NOT NULL,
	NAME nvarchar2(256) NOT NULL,
	SITE_ID char(36) NOT NULL,
	constraint PK_RESOURCE_POOLS primary key (ID),
	constraint RESOURCE_POOLS_UC1 unique (NAME, SITE_ID),
	constraint FK_RESOURCE_POOLS_SITES foreign key (SITE_ID) references SITES(SITE_ID))
/

create index RESOURCE_POOLS_SITES on RESOURCE_POOLS(SITE_ID)
/

create table NODE_SERVICES_RESOURCE_POOLS(
	SERVICE_ID char(36) NOT NULL,
	RESOURCE_POOL_ID char(36) NOT NULL,
 	constraint PK_NODES_RESOURCE_POOLS primary key (SERVICE_ID, RESOURCE_POOL_ID),
 	constraint FK_NSRP_NS foreign key (SERVICE_ID) references NODE_SERVICES (ID) on delete cascade,
 	constraint FK_NSRP_RP foreign key (RESOURCE_POOL_ID) references RESOURCE_POOLS (ID) on delete cascade)
/

create index IX_NSRP_SERVICE_ID on NODE_SERVICES_RESOURCE_POOLS(SERVICE_ID) 
/

create index IX_NSRP_RESOURCE_POOL_ID on NODE_SERVICES_RESOURCE_POOLS(RESOURCE_POOL_ID)
/

alter table ROUTING_RULES  add constraint FK_ROUT_RULES_LIB_ITEMS foreign key(LIB_ITEM_ID)references LIB_ITEMS(ITEM_ID)
on delete set null
/

alter table ROUTING_RULES  add constraint FK_ROUT_RULES_GROUPS foreign key(GROUP_ID)references GROUPS(GROUP_ID)
on delete set null
/

alter table ROUTING_RULES  add constraint FK_ROUT_RULES_USERS foreign key(USER_ID)references USERS(USER_ID)
on delete set null
/

alter table ROUTING_RULES  add constraint FK_ROUT_RULES_RES_POOLS foreign key(RESOURCE_POOL_ID)references RESOURCE_POOLS (ID)
/

ALTER TABLE ROUTING_RULES ADD CONSTRAINT FK_ROUTING_RULES_SITE_ID FOREIGN KEY (SITE_ID) REFERENCES SITES (SITE_ID)
/

alter table ROUTING_RULES add constraint ROUTING_RULES_STATUS check (			
	(STATUS = 0) 
	or 
	(STATUS = 1)	
	or 
	(STATUS = 2)
	or
	(STATUS = 3)
)
/
alter table ROUTING_RULES add constraint ROUTING_RULES_TYPES check (			
	(TYPE = 'R') 
	or 
	(TYPE = 'D')	
)
/

alter table NODE_SERVICES_ATTRIBUTES  add constraint FK_NSA_SA foreign key(ATTRIBUTE_ID)references SERVICE_ATTRIBUTES (ID)
on delete cascade
/

alter table NODE_SERVICES_ATTRIBUTES  add constraint FK_NSA_NS foreign key(SERVICE_ID)references NODE_SERVICES (ID)
on delete cascade
/

create or replace 
procedure routingRules_updatePriority (
   ruleId in ROUTING_RULES.ID%type,
   newPriority in integer) as
direction char(4);
siteId char(36);
begin       
 
 SELECT CASE WHEN newPriority > PRIORITY THEN 'DOWN' ELSE 'UP' END into direction FROM ROUTING_RULES WHERE ID = ruleId;
 SELECT SITE_ID into siteId FROM ROUTING_RULES WHERE ID = ruleId;
 
 update ROUTING_RULES R
 set PRIORITY = -1 + (select NEW_PRIORITY from (
            select ID, row_number() OVER(ORDER BY  
                                   CASE WHEN TYPE = 'R' THEN   
                                       CASE WHEN STATUS <> 2 THEN 'A'
                                       ELSE 'B' END
                                   ELSE 'C' END,
                                   CASE WHEN ID = ruleId THEN newPriority   
                                   WHEN PRIORITY < newPriority THEN PRIORITY - 1
                                   WHEN PRIORITY = newPriority AND direction = 'DOWN' THEN PRIORITY - 1
                                   WHEN PRIORITY = newPriority AND direction = 'UP' THEN PRIORITY + 1
                                   WHEN PRIORITY >= newPriority THEN PRIORITY + 1 END ASC) AS NEW_PRIORITY 
                                   FROM ROUTING_RULES
                                   WHERE SITE_ID = siteId) U
     					where U.ID = R.ID)
where R.SITE_ID = siteId;
   
end;
/

create or replace
procedure routingRules_deleteRule (
   ruleId in ROUTING_RULES.ID%type) as
siteId char(36);
begin
 
 SELECT SITE_ID into siteId FROM ROUTING_RULES WHERE ID = ruleId;

 -- delete
 delete from ROUTING_RULES where ID = ruleId;
 
 -- update priority
 update ROUTING_RULES R
 set PRIORITY = -1 + (select NEW_PRIORITY from (
            select ID, row_number() OVER(ORDER BY
            CASE WHEN TYPE = 'R' THEN   
                CASE WHEN STATUS <> 2 THEN 'A'
                ELSE 'B' END
            ELSE 'C' END,
            PRIORITY ) NEW_PRIORITY  
            from ROUTING_RULES
            where SITE_ID = siteId) U
     where U.ID = R.ID)
where R.SITE_ID = siteId;   
 
end;
/

create or replace 
procedure usp_findRoutingRules(
	current_user_id in USERS.USER_ID%type,
	library_item_id in LIB_ITEMS.ITEM_ID%type,
	site_id in SITES.SITE_ID%type,
  rulesCursor OUT SYS_REFCURSOR)
as
begin
	if (current_user_id is null or site_id is null) then
		raise_application_error(-20004, 'Invalid arguments: user_id and site_id can not be null.');
  end if;

  OPEN rulesCursor FOR
WITH ALL_USER_GROUPS AS
	 (
    select gm.GROUP_ID  
    from GROUP_MEMBERS_VIEW gm
    start with gm.MEMBER_USER_ID = COALESCE(current_user_id,'')
    connect by gm.MEMBER_GROUP_ID = prior gm.GROUP_ID
	 ),
	ALL_PARENTS as (
	SELECT PARENT_ID FROM LIB_ITEMS
	start with ITEM_ID = COALESCE(library_item_id,'')
  connect by ITEM_ID = prior PARENT_ID
)
SELECT rules.ID
      ,rules.NAME
      ,rules.LIB_ITEM_ID
      ,rules.GROUP_ID
      ,rules.USER_ID
      ,rules.RESOURCE_POOL_ID
      ,rules.PRIORITY
      ,rules.STATUS
      ,rules.TYPE
FROM ROUTING_RULES rules
LEFT JOIN ALL_PARENTS parents ON rules.LIB_ITEM_ID = parents.PARENT_ID
LEFT JOIN ALL_USER_GROUPS groups ON rules.GROUP_ID = groups.GROUP_ID
WHERE rules.STATUS = 1
AND rules.SITE_ID = site_id
AND ((rules.LIB_ITEM_ID IS NOT NULL AND rules.LIB_ITEM_ID = library_item_id) --direct match
  OR (rules.LIB_ITEM_ID IS NOT NULL and parents.PARENT_ID IS NOT NULL) --parent folder match
  OR (rules.GROUP_ID IS NOT NULL and groups.GROUP_ID IS NOT NULL) --group match
  OR (COALESCE(rules.USER_ID,'') = current_user_id) --user match
  OR rules."TYPE" = 'D'
)
ORDER BY rules.PRIORITY asc;

end usp_findRoutingRules;
/

create or replace procedure usp_recalculateRulePriorities(
   siteId in SITES.SITE_ID%type) as
begin

 -- update priorities: first scheduled updates, then everything else
 update ROUTING_RULES R
 set PRIORITY = -1 + (select NEW_PRIORITY from (
            select ID, row_number() OVER(ORDER BY
            CASE WHEN TYPE = 'R' THEN   
                CASE WHEN CAPABILITY='"WEB_PLAYER"' THEN 'A'
                ELSE 'B' END
            ELSE 'C' END,
            PRIORITY ) NEW_PRIORITY  
            from ROUTING_RULES) U
     where U.ID = R.ID);   
end;
/

/* ------------------ scheduler schema ------------------ */
create table JOB_SCHEDULES(
    ID char(36) NOT NULL,	
    NAME nvarchar2(32) NULL,
    START_TIME number(19) NULL,
    END_TIME number(19) NULL,
    WEEK_DAYS nvarchar2(200) NULL,
    LAST_MODIFIED timestamp NULL,
    LAST_MODIFIED_BY char(36) NULL,	
    IS_JOB_SPECIFIC smallint NULL,
    RELOAD_FREQUENCY smallint NULL,
    RELOAD_UNIT nvarchar2(16) NULL,
    TIMEZONE varchar(64) NULL,
    SITE_ID char(36) NULL,
    SCHEDULE_TYPE smallint default 0 NOT NULL,
    EXPRESSION VARCHAR2(128) NULL,
    constraint PK_JOB_SCHEDULES primary key (ID),
    constraint FK_JOB_SCHEDULES_SITE_ID foreign key (SITE_ID) references SITES(SITE_ID)
)
/

CREATE INDEX JOB_SCHEDULES_SITES ON JOB_SCHEDULES(SITE_ID)
/

CREATE TABLE SCHEDULED_UPDATES_SETTINGS(
	ROUTING_RULE_ID char(36) NOT NULL,
	INSTANCES_COUNT smallint NULL,
	CLIENT_UPDATE_MODE varchar(32) NULL,
	ALLOW_CACHED_DATA smallint NULL,
	PRECOMPUTE_RELATIONS smallint NULL,
	PRECOMPUTE_VISUALIZATIONS smallint NULL,
	PRECOMPUTE_ACTIVE_PAGE smallint NULL,
 CONSTRAINT PK_SCHEDULED_UPDATES_SETTINGS PRIMARY KEY(ROUTING_RULE_ID))
/
 
 CREATE TABLE RULES_SCHEDULES(
 	ROUTING_RULE_ID char(36) NOT NULL,
	SCHEDULE_ID char(36) NOT NULL,
 CONSTRAINT PK_RULES_SCHEDULES PRIMARY KEY(ROUTING_RULE_ID, SCHEDULE_ID))
/

create table JOB_INSTANCES(
	INSTANCE_ID char(36) NOT NULL,
	TYPE char(1) DEFAULT('S') NOT NULL, 
	STATUS smallint NULL,
	CREATED timestamp NULL,
	LAST_MODIFIED timestamp NULL,
	NEXT_FIRE_TIME number(19) NULL,
	ROUTING_RULE_ID char(36) NULL,
	LIB_ITEM_ID char(36) NULL,
	SCHEDULE_ID char(36) NULL,
	SITE_ID char(36) NULL,
	JOB_CONTENT nclob NULL,
	ERROR_MESSAGE nvarchar2(1024) NULL,
	EXECUTION_TYPE smallint NULL,
	EXECUTED_BY char(36) NULL,
    constraint PK_JOB_INSTANCES primary key (INSTANCE_ID),
    constraint "FK_JI_LI" foreign key ("LIB_ITEM_ID") 
    references "LIB_ITEMS" ("ITEM_ID") ON DELETE SET NULL,
    constraint "FK_JI_U" foreign key ("EXECUTED_BY") 
    references "USERS" ("USER_ID") ON DELETE SET NULL)
/
alter table JOB_INSTANCES add constraint JOB_INSTANCES_TYPES check (			
	(TYPE = 'S') 
	or 
	(TYPE = 'A')	
)
/

alter table JOB_INSTANCES add constraint FK_JOB_INSTANCES_SCHEDULES 
foreign key(SCHEDULE_ID)references JOB_SCHEDULES (ID)
/

CREATE INDEX JOB_INSTANCES_RULE_IDX
ON JOB_INSTANCES (ROUTING_RULE_ID)
/

CREATE INDEX JOB_INSTANCES_STATUS_IDX
ON JOB_INSTANCES (STATUS)
/

CREATE INDEX JOB_INSTANCES_TYPE_STATUS_IDX 
ON JOB_INSTANCES (TYPE, EXECUTION_TYPE, STATUS)
/

CREATE INDEX JOB_INSTANCES_TYPE_IDX ON JOB_INSTANCES (TYPE)
/

CREATE INDEX JOB_INSTANCES_TYPE_STAT_IDX ON JOB_INSTANCES (TYPE, STATUS)
/
 
CREATE INDEX JOB_INSTANCES_SITES ON JOB_INSTANCES(SITE_ID)
/

CREATE INDEX JOB_INSTANCES_LIB_IDX ON JOB_INSTANCES(LIB_ITEM_ID)
/

CREATE INDEX JOB_INSTANCES_USER_IDX ON JOB_INSTANCES(EXECUTED_BY)
/

create table JOBS_LATEST(
    INSTANCE_ID char(36) NOT NULL,
    LIB_ITEM_ID char(36) NOT NULL,
    constraint "PK_JOBS_LATEST" primary key ("LIB_ITEM_ID"),
    constraint "FK_JL_JI" foreign key ("INSTANCE_ID")
        references "JOB_INSTANCES" ("INSTANCE_ID") on delete cascade,
    constraint "FK_JL_LI" foreign key ("LIB_ITEM_ID")
        references "LIB_ITEMS" ("ITEM_ID") on delete cascade)
/

CREATE INDEX JOBS_LATEST_JOB_IDX ON JOBS_LATEST(INSTANCE_ID)
/

create table JOB_TASKS(
	TASK_ID char(36) NOT NULL,
	JOB_ID char(36) NOT NULL,
	STATUS smallint NULL,
	MESSAGE nvarchar2(1024) NULL,
	TASK_EXTERNAL_ID nvarchar2(36) NULL,
	SERVICE_ID char(36) NULL,
	DESTINATION nvarchar2(512) NULL,
	CREATED timestamp NULL,
	LAST_MODIFIED timestamp NULL,
    constraint PK_JOB_TASKS primary key (TASK_ID)
)
/

CREATE INDEX JOB_TASKS_JOB_ID_IDX
ON JOB_TASKS (JOB_ID)
/
 
alter table SCHEDULED_UPDATES_SETTINGS  ADD  CONSTRAINT FK_SUS_RR FOREIGN KEY(ROUTING_RULE_ID)
REFERENCES ROUTING_RULES (ID) on delete cascade
/

alter table RULES_SCHEDULES  ADD  CONSTRAINT FK_RS_RR FOREIGN KEY(ROUTING_RULE_ID) REFERENCES ROUTING_RULES (ID) on delete cascade
/

alter table RULES_SCHEDULES  ADD  CONSTRAINT FK_RS_JS FOREIGN KEY(SCHEDULE_ID) REFERENCES JOB_SCHEDULES (ID) on delete cascade
/

alter table JOB_INSTANCES  add  constraint FK_JOBS_ROUTING_RULES foreign key(ROUTING_RULE_ID) references ROUTING_RULES (ID) on delete set null
/

ALTER TABLE JOB_INSTANCES ADD CONSTRAINT FK_JOB_INSTANCES_SITE_ID FOREIGN KEY (SITE_ID) REFERENCES SITES (SITE_ID)
/

alter table JOB_TASKS  add  constraint FK_JOB_TASKS_JOBS foreign key(JOB_ID) references JOB_INSTANCES (INSTANCE_ID) 
on delete cascade
/

create view JOB_INSTANCES_DETAIL_VIEW AS 
SELECT JOB.INSTANCE_ID
,JOB.TYPE	
,JOB.STATUS
,JOB.CREATED
,JOB.LAST_MODIFIED
,JOB.ROUTING_RULE_ID
,JOB.JOB_CONTENT		
,JOB.ERROR_MESSAGE
,JOB.EXECUTION_TYPE
,JOB.SITE_ID
,ROUTING_RULES.NAME,
COALESCE(U.TOTAL_TASKS_COUNT,0) TOTAL_TASKS_COUNT, 
COALESCE(U.COMPLETED_TASKS_COUNT,0) COMPLETED_TASKS_COUNT,
COALESCE(U.FAILED_TASKS_COUNT,0) FAILED_TASKS_COUNT,
COALESCE(U.IN_PROGRESS_TASKS_COUNT,0) IN_PROGRESS_TASKS_COUNT
FROM JOB_INSTANCES JOB
LEFT JOIN ROUTING_RULES ON JOB.ROUTING_RULE_ID = ROUTING_RULES.ID
LEFT JOIN ( 
select JOB_ID, COUNT(*) AS TOTAL_TASKS_COUNT,
SUM(case when STATUS = 5 THEN 1 ELSE 0 END) AS COMPLETED_TASKS_COUNT,
SUM(case when STATUS = 3 OR STATUS = 2 THEN 1 ELSE 0 END) AS FAILED_TASKS_COUNT,
SUM(case when STATUS = 1 THEN 1 ELSE 0 END) AS IN_PROGRESS_TASKS_COUNT
FROM JOB_TASKS
GROUP BY JOB_ID
) U ON JOB.INSTANCE_ID = U.JOB_ID
/

create view RESOURCE_POOLS_SERVICES_VIEW as 
WITH A AS (
 SELECT NSRP.SERVICE_ID, RP.ID AS RESOURCE_POOL_ID, RP.NAME AS RESOURCE_POOL_NAME
        FROM NODE_SERVICES_RESOURCE_POOLS NSRP
        INNER JOIN RESOURCE_POOLS RP ON NSRP.RESOURCE_POOL_ID = RP.ID        
),
B AS (
    SELECT NS.ID, NS.SERVICE_TYPE, NS.NODE_ID, NS.WORKING_DIR, NS.URL, NS.CAPABILITIES,
    A.RESOURCE_POOL_ID, A.RESOURCE_POOL_NAME, NS.DEPLOYMENT_AREA, NS.STATUS
    FROM NODE_SERVICES NS
    LEFT JOIN A ON NS.ID = A.SERVICE_ID
    WHERE NS.CAPABILITIES LIKE '%WEB_PLAYER%'
)
SELECT B.ID, B.SERVICE_TYPE, B.NODE_ID, B.WORKING_DIR, B.URL, B.CAPABILITIES,
    B.RESOURCE_POOL_ID, B.RESOURCE_POOL_NAME, B.DEPLOYMENT_AREA, B.STATUS,
    DAD.DEP_AREA_NAME, NSI.SERVERNAME, N.SITE_ID
FROM B
LEFT JOIN DEP_AREAS_DEF DAD ON B.DEPLOYMENT_AREA = DAD.AREA_ID
INNER JOIN NODES N ON B.NODE_ID = N.ID
INNER JOIN NODE_SERVER_INFO NSI ON NSI.NODE_ID = N.ID AND NSI.PRIORITY = 1
/
/* ----------------- Persistent Sessions ("remember me") --------------------- */

create table PERSISTENT_SESSIONS (
  SESSION_ID VARCHAR2(100) not null,
  USER_ID CHAR(36) not null,
  TOKEN_HASH VARCHAR2(150) not null,
  VALID_UNTIL TIMESTAMP not null,
  constraint PERSISTENT_SESSIONS_PK primary key (SESSION_ID),
  constraint FK_USERS_USER_ID foreign key (USER_ID) references USERS (USER_ID) on delete cascade )
/

/* ----------------- Invitations  --------------------- */
create table INVITES (
  SENDER_ID char(36) not null,
  ITEM_ID char(36) not null,
  INVITE_TOKEN varchar2(200) not null,
  CREATED timestamp(0) not null,
  EMAIL varchar2(255) not null,
  constraint PK_INVITES primary key (SENDER_ID, ITEM_ID, EMAIL),
  constraint FK_INVITES_USERS foreign key (SENDER_ID) references USERS (USER_ID) on delete cascade, 
  constraint FK_INVITES_LIB_ITEMS foreign key (ITEM_ID) references LIB_ITEMS (ITEM_ID) on delete cascade)
/

/* ----------------- Additional indices on FK  constraints --------------------- */
create index INVITES_ITEM_ID_IDX on INVITES(ITEM_ID)
/
create index "ACTIVE_SERVICE_CFG_CFG_ID_IDX" on "ACTIVE_SERVICE_CONFIGS" ("CONFIG_ID") 
/
create index "CUSTOM_LIC_GROUP_ID_IDX" on "CUSTOMIZED_LICENSES" ("GROUP_ID") 
/
create index "CUSTOM_LIC_LIC_NAME_IDX" on "CUSTOMIZED_LICENSES" ("LICENSE_NAME") 
/
create index "DEP_AREAS_DISTRIBUTION_ID_IDX" on "DEP_AREAS" ("DISTRIBUTION_ID") 
/
create index "DEP_DISTR_CONT_DISTR_ID_IDX" on "DEP_DISTRIBUTION_CONTENTS" ("DISTRIBUTION_ID") 
/
create index "EXCLUDED_FUNC_LIC_FUNC_ID_IDX" on "EXCLUDED_FUNCTIONS" ("LICENSE_FUNCTION_ID") 
/
create index "JOB_INSTANCES_SCHEDULE_ID_IDX" on "JOB_INSTANCES" ("SCHEDULE_ID") 
/
create index "LIB_DATA_CHAR_ENCODING_IDX" on "LIB_DATA" ("CHARACTER_ENCODING") 
/
create index "LIB_DATA_CONTENT_TYPE_IDX" on "LIB_DATA" ("CONTENT_TYPE") 
/
create index "LIB_DATA_CONTENT_ENCODING_IDX" on "LIB_DATA" ("CONTENT_ENCODING") 
/
create index "LIB_VISIBLE_TYPES_APP_ID_IDX" on "LIB_VISIBLE_TYPES" ("APPLICATION_ID") 
/
create index "LIC_FUNC_LIC_NAME_IDX" on "LICENSE_FUNCTIONS" ("LICENSE_NAME") 
/
create index "LIC_ORIGIN_PACKAGE_ID_IDX" on "LICENSE_ORIGIN" ("PACKAGE_ID") 
/
create index "LIC_ORIGIN_LIC_FUNCTION_ID_IDX" on "LICENSE_ORIGIN" ("LICENSE_FUNCTION_ID") 
/
create index "NODE_EVENT_BUS_USER_ID_IDX" on "NODE_EVENT_BUS" ("USER_ID") 
/
create index "NODE_SERVICES_DEPL_AREA_IDX" on "NODE_SERVICES" ("DEPLOYMENT_AREA") 
/
create index "NODE_SERVICES_ATTR_SRV_ID_IDX" on "NODE_SERVICES_ATTRIBUTES" ("SERVICE_ID") 
/
create index "NODE_SERVICES_PKGS_SRV_ID_IDX" on "NODE_SERVICES_PKGS" ("SERVICE_ID") 
/
create index "NODES_DEPLOYMENT_AREA_IDX" on "NODES" ("DEPLOYMENT_AREA") 
/
create index "PRSTNT_SESSIONS_USER_ID_IDX" on "PERSISTENT_SESSIONS" ("USER_ID") 
/
create index "PREF_OBJECTS_GROUP_ID_IDX" on "PREFERENCE_OBJECTS" ("GROUP_ID") 
/
create index "PREF_OBJECTS_USER_ID_IDX" on "PREFERENCE_OBJECTS" ("USER_ID") 
/
create index "PREF_VALUES_PREFERENCE_ID_IDX" on "PREFERENCE_VALUES" ("PREFERENCE_ID") 
/
create index "PREF_VALUES_USER_ID_IDX" on "PREFERENCE_VALUES" ("USER_ID") 
/
create index "ROUTING_RULES_GROUP_ID_IDX" on "ROUTING_RULES" ("GROUP_ID") 
/
create index "ROUTING_RULES_LIB_ITEM_ID_IDX" on "ROUTING_RULES" ("LIB_ITEM_ID") 
/
create index "ROUTING_RULES_USER_ID_IDX" on "ROUTING_RULES" ("USER_ID") 
/
create index "RULES_SCHD_SCHEDULE_ID_IDX" on "RULES_SCHEDULES" ("SCHEDULE_ID") 
/
create index "SITE_SRV_CONF_CONFIG_ID_IDX" on "SITE_SERVICE_CONFIGS" ("CONFIG_ID") 
/
create index "SITE_SRV_CONF_SITE_ID_IDX" on "SITE_SERVICE_CONFIGS" ("SITE_ID") 
/

commit
/

exit
/
