-- #
-- # Copyright (c) 2019-2020. TIBCO Software Inc.
-- # This file is subject to the license terms contained in the license file that is distributed with this file.
-- #
use be_database;
DROP TABLE IF EXISTS ClassToTable;
CREATE TABLE ClassToTable (className varchar(4000), fieldName varchar(4000), tableName varchar(4000) );

DROP TABLE IF EXISTS CacheIds;
CREATE TABLE CacheIds (cacheIdGeneratorName varchar (4000), nextCacheId integer);

DROP TABLE IF EXISTS BEAliases;
CREATE TABLE BEAliases (beName varchar(4000), alias varchar(4000));

DROP TABLE IF EXISTS ClassRegistry;
CREATE TABLE ClassRegistry (className varchar(4000), typeId integer);


DROP TABLE IF EXISTS StateMachineTimeout$$;
CREATE TABLE StateMachineTimeout$$ (CACHEID integer, smid BIGINT, propertyName varchar(4000), currentTime BIGINT, nextTime BIGINT, closure varchar(4000), ttl BIGINT, fired BIGINT, time_created$ timestamp, id$ BIGINT, extId$ varchar(2000), state$ char(1));

DROP TABLE IF EXISTS WorkItems;
CREATE TABLE WorkItems (workKey varchar(2000), workQueue varchar(255), workStatus BIGINT, scheduledTime BIGINT, work blob);

CREATE INDEX i_WorkItems on WorkItems (workQueue, scheduledTime);


DROP TABLE IF EXISTS ObjectTable;
CREATE TABLE ObjectTable (GLOBALID BIGINT, SITEID BIGINT, ID BIGINT, EXTID varchar(255), CLASSNAME varchar(255), ISDELETED integer, TIMEDELETED BIGINT);

CREATE UNIQUE INDEX i_ObjectTable1 on ObjectTable(GLOBALID);
CREATE INDEX i_ObjectTable2 on ObjectTable(EXTID);

DROP TABLE IF EXISTS ProcessLoopState;
CREATE TABLE ProcessLoopState (loopKey varchar(256) not null, jobKey varchar(256), taskName varchar(256), counter integer, maxCounter integer, isComplete integer,  primary key (loopKey));

DROP TABLE IF EXISTS ProcessMergeState;
CREATE TABLE ProcessMergeState (mergeKey varchar(256), tokenCount integer, expectedTokenCount integer, isComplete integer, processId BIGINT, processTime BIGINT, transitionName varchar(256), isError integer);
CREATE INDEX i_ProcessMergeState1 on ProcessMergeState(mergeKey);

DROP TABLE IF EXISTS D_AccountOperations;
CREATE TABLE D_AccountOperations (cacheId int, payload__p blob, AccountId char varying(255), time_acknowledged$ timestamp, time_sent$ timestamp, time_created$ timestamp, id$ bigint not null, extId$ char varying(255), state$ char(1));
DROP TABLE IF EXISTS D_CreateAccount;
CREATE TABLE D_CreateAccount (cacheId int, AvgMonthlyBalance double precision, Balance double precision, payload__p blob, AccountId char varying(255), time_acknowledged$ timestamp, time_sent$ timestamp, time_created$ timestamp, id$ bigint not null, extId$ char varying(255), state$ char(1));
DROP TABLE IF EXISTS D_Debit;
CREATE TABLE D_Debit (cacheId int, Amount double precision, payload__p blob, AccountId char varying(255), time_acknowledged$ timestamp, time_sent$ timestamp, time_created$ timestamp, id$ bigint not null, extId$ char varying(255), state$ char(1));
DROP TABLE IF EXISTS D_Unsuspend;
CREATE TABLE D_Unsuspend (cacheId int, payload__p blob, AccountId char varying(255), time_acknowledged$ timestamp, time_sent$ timestamp, time_created$ timestamp, id$ bigint not null, extId$ char varying(255), state$ char(1));
DROP TABLE IF EXISTS D_Account;
CREATE TABLE D_Account (cacheId int, AvgMonthlyBalance double precision, time_created$ timestamp, time_last_modified$ timestamp, parent$_id$ bigint, id$ bigint not null, extId$ char varying(255), state$ char(1));
DROP TABLE IF EXISTS D_Account_Balance;
CREATE TABLE D_Account_Balance (pid$ bigint, howMany int, timeIdx timestamp, val double precision);
DROP TABLE IF EXISTS D_Account_Debits;
CREATE TABLE D_Account_Debits (pid$ bigint, howMany int, timeIdx timestamp, val double precision);
DROP TABLE IF EXISTS D_Account_Status;
CREATE TABLE D_Account_Status (pid$ bigint, howMany int, timeIdx timestamp, val char varying(255));
DROP TABLE IF EXISTS D_Account_rrf$;
CREATE TABLE D_Account_rrf$ (pid$ bigint, propertyName$ char varying(255), id$ bigint not null);
DROP TABLE IF EXISTS D_FraudCriteria;
CREATE TABLE D_FraudCriteria (cacheId int, interval_ bigint, numTransactions int, debitsPercent double precision, time_created$ timestamp, time_last_modified$ timestamp, parent$_id$ bigint, id$ bigint not null, extId$ char varying(255), state$ char(1));
DROP TABLE IF EXISTS D_FraudCriteria_rrf$;
CREATE TABLE D_FraudCriteria_rrf$ (pid$ bigint, propertyName$ char varying(255), id$ bigint not null);
ALTER TABLE D_AccountOperations ADD PRIMARY KEY (ID$);
ALTER TABLE D_CreateAccount ADD PRIMARY KEY (ID$);
ALTER TABLE D_Debit ADD PRIMARY KEY (ID$);
ALTER TABLE D_Unsuspend ADD PRIMARY KEY (ID$);
CREATE INDEX i_D_Account_Balance ON D_Account_Balance(PID$);
CREATE INDEX i_D_Account_Debits ON D_Account_Debits(PID$);
CREATE INDEX i_D_Account_Status ON D_Account_Status(PID$);
CREATE INDEX i_D_Account_rrf$ ON D_Account_rrf$(PID$);
ALTER TABLE D_Account ADD PRIMARY KEY (ID$);
CREATE INDEX i_D_FraudCriteria_rrf$ ON D_FraudCriteria_rrf$(PID$);
ALTER TABLE D_FraudCriteria ADD PRIMARY KEY (ID$);
DELETE FROM ClassToTable;
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Concepts.Account', 'D_Account');
INSERT INTO ClassToTable(classname, fieldName, tablename) VALUES ('be.gen.Concepts.Account', 'Balance', 'D_Account_Balance');
INSERT INTO ClassToTable(classname, fieldName, tablename) VALUES ('be.gen.Concepts.Account', 'Debits', 'D_Account_Debits');
INSERT INTO ClassToTable(classname, fieldName, tablename) VALUES ('be.gen.Concepts.Account', 'Status', 'D_Account_Status');
INSERT INTO ClassToTable(classname, fieldName, tablename) VALUES ('be.gen.Concepts.Account', 'rrf$', 'D_Account_rrf$');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Events.AccountOperations', 'D_AccountOperations');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Events.CreateAccount', 'D_CreateAccount');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Events.Debit', 'D_Debit');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.Events.Unsuspend', 'D_Unsuspend');
INSERT INTO ClassToTable(classname, tablename) VALUES ('be.gen.FraudCriteria', 'D_FraudCriteria');
INSERT INTO ClassToTable(classname, fieldName, tablename) VALUES ('be.gen.FraudCriteria', 'rrf$', 'D_FraudCriteria_rrf$');
DELETE FROM BEAliases;
INSERT INTO BEAliases VALUES ('COLUMN.interval.alias', 'interval_');
