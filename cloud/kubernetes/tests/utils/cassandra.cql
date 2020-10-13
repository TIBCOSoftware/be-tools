#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#
DROP ROLE IF EXISTS BE_USER;

CREATE ROLE BE_USER with SUPERUSER = true AND LOGIN = true and PASSWORD = 'BE_USER';


CREATE KEYSPACE testdb
  WITH REPLICATION = {
   'class' : 'SimpleStrategy',
   'replication_factor' : 1
  };



use testdb;
DROP TABLE IF EXISTS ClassToTable;
CREATE TABLE IF NOT EXISTS ClassToTable (className varchar PRIMARY KEY, fieldName varchar, tableName varchar );

/** This table persists the EAR wide next cache Id */
DROP TABLE IF EXISTS CacheIds;
CREATE TABLE IF NOT EXISTS CacheIds (cacheIdGeneratorName text PRIMARY KEY, nextCacheId BIGINT);

DROP TABLE IF EXISTS BEAliases;
CREATE TABLE IF NOT EXISTS BEAliases (id uuid PRIMARY KEY, beName varchar, alias varchar);

DROP TABLE IF EXISTS ClassRegistry;
CREATE TABLE IF NOT EXISTS ClassRegistry (id uuid PRIMARY KEY, className varchar, typeId int);

DROP TABLE IF EXISTS StateMachineTimeout;
CREATE TABLE IF NOT EXISTS StateMachineTimeout (st_id uuid PRIMARY KEY, CACHEID int, smid BIGINT, propertyName varchar, currentTime BIGINT, nextTime BIGINT, closure varchar, ttl BIGINT, fired BIGINT, time_created timestamp, id BIGINT, extId varchar, state varchar);

DROP TABLE IF EXISTS WorkItems;
CREATE TABLE IF NOT EXISTS WorkItems (id uuid PRIMARY KEY, workKey varchar, workQueue varchar, workStatus BIGINT, scheduledTime BIGINT, work blob);

DROP TABLE IF EXISTS ObjectTable;
CREATE TABLE IF NOT EXISTS ObjectTable ( GLOBALID BIGINT PRIMARY KEY, SITEID BIGINT, ID BIGINT, EXTID varchar, CLASSNAME varchar, ISDELETED int, TIMEDELETED BIGINT);

DROP TABLE IF EXISTS ProcessLoopState;
CREATE TABLE IF NOT EXISTS ProcessLoopState (loopKey varchar PRIMARY KEY, jobKey varchar, taskName varchar, counter int, maxCounter int, isComplete int);

DROP TABLE IF EXISTS ProcessMergeState;
CREATE TABLE IF NOT EXISTS ProcessMergeState (id uuid PRIMARY KEY, mergeKey varchar, tokenCount int, expectedTokenCount int, isComplete int, processId BIGINT, processTime BIGINT, transitionName varchar, isError int);

DROP INDEX IF EXISTS i_WorkItems_1;
CREATE INDEX IF NOT EXISTS i_WorkItems_1 on WorkItems (workQueue);

DROP INDEX IF EXISTS i_WorkItems_2;
CREATE INDEX IF NOT EXISTS i_WorkItems_2 on WorkItems (scheduledTime);

DROP INDEX IF EXISTS i_ObjectTable1;
CREATE INDEX IF NOT EXISTS i_ObjectTable1 ON ObjectTable (EXTID);

DROP INDEX IF EXISTS i_ProcessMergeState1;
CREATE INDEX IF NOT EXISTS i_ProcessMergeState1 on ProcessMergeState(mergeKey);

DROP TABLE D_Debit;
CREATE TABLE IF NOT EXISTS D_Debit(cacheid INT, id_ BIGINT, extid_ TEXT, accountid TEXT, amount DOUBLE, payload_ BLOB, time_ack_ TIMESTAMP, time_sent_ TIMESTAMP, time_created_ TIMESTAMP, state_ TEXT,  PRIMARY KEY (id_));
 DROP TABLE D_AccountOperations;
CREATE TABLE IF NOT EXISTS D_AccountOperations(cacheid INT, id_ BIGINT, extid_ TEXT, accountid TEXT, payload_ BLOB, time_ack_ TIMESTAMP, time_sent_ TIMESTAMP, time_created_ TIMESTAMP, state_ TEXT,  PRIMARY KEY (id_));
 DROP TABLE D_CreateAccount;
CREATE TABLE IF NOT EXISTS D_CreateAccount(cacheid INT, id_ BIGINT, extid_ TEXT, accountid TEXT, avgmonthlybalance DOUBLE, balance DOUBLE, payload_ BLOB, time_ack_ TIMESTAMP, time_sent_ TIMESTAMP, time_created_ TIMESTAMP, state_ TEXT,  PRIMARY KEY (id_));
 DROP TABLE D_Unsuspend;
CREATE TABLE IF NOT EXISTS D_Unsuspend(cacheid INT, id_ BIGINT, extid_ TEXT, accountid TEXT, payload_ BLOB, time_ack_ TIMESTAMP, time_sent_ TIMESTAMP, time_created_ TIMESTAMP, state_ TEXT,  PRIMARY KEY (id_));
 DROP TABLE D_FraudCriteria;
CREATE TABLE IF NOT EXISTS D_FraudCriteria(cacheid INT, id_ BIGINT, extid_ TEXT, interval BIGINT, numtransactions INT, debitspercent DOUBLE, rrfs_ids TEXT, rrfs_props TEXT, rrfs_parent TEXT, created_ TIMESTAMP, updated_ TIMESTAMP,  PRIMARY KEY (id_));
 DROP TABLE D_Account;
CREATE TABLE IF NOT EXISTS D_Account(cacheid INT, id_ BIGINT, extid_ TEXT, balance BLOB, debits BLOB, status BLOB, avgmonthlybalance DOUBLE, rrfs_ids TEXT, rrfs_props TEXT, rrfs_parent TEXT, created_ TIMESTAMP, updated_ TIMESTAMP,  PRIMARY KEY (id_));
TRUNCATE ClassToTable;
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Events.Debit','D_Debit');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Events.AccountOperations','D_AccountOperations');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Events.CreateAccount','D_CreateAccount');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Events.Unsuspend','D_Unsuspend');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.FraudCriteria','D_FraudCriteria');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Concepts.Account','D_Account');
