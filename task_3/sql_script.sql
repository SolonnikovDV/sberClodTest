-- the best way is create 'read-only' + insert user

-- create date mart 'mart_2':
CREATE TABLE mart_2 AS SELECT * FROM mart_1;
DESCRIBE mart_2;

--| Field | Type          | Null | Key | Default | Extra |
--|-------|-------------- |------|-----|---------|-------|
--| key_1 | bigint(20)    | YES  |     | NULL    |       |
--| val_1 | decimal(20,0) | YES  |     | NULL    |       |
--| key_2 | bigint(20)    | YES  |     | NULL    |       |
--| val_2 | decimal(20,0) | YES  |     | NULL    |       |
--| str_1 | text          | YES  |     | NULL    |       |

-- check current users grantee:
SELECT GRANTEE , JSON_ARRAYAGG(JSON_OBJECT('PRIVILEGE_TYPE', PRIVILEGE_TYPE)) AS list_of_grands
FROM information_schema.user_privileges
WHERE GRANTEE LIKE '%172.25.0.1%'
GROUP BY GRANTEE;

--| GRANTEE                   | list_of_grands                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
--|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
--| 'mysql_user'@'172.25.0.1' | [{"PRIVILEGE_TYPE": "ROLE_ADMIN"}, {"PRIVILEGE_TYPE": "UPDATE"}, {"PRIVILEGE_TYPE": "BINLOG_ADMIN"}, {"PRIVILEGE_TYPE": "ALTER"}, {"PRIVILEGE_TYPE": "SHOW VIEW"}, {"PRIVILEGE_TYPE": "XA_RECOVER_ADMIN"}, {"PRIVILEGE_TYPE": "PERSIST_RO_VARIABLES_ADMIN"}, {"PRIVILEGE_TYPE": "RELOAD"}, {"PRIVILEGE_TYPE": "LOCK TABLES"}, {"PRIVILEGE_TYPE": "EVENT"}, {"PRIVILEGE_TYPE": "SERVICE_CONNECTION_ADMIN"}, {"PRIVILEGE_TYPE": "INSERT"}, {"PRIVILEGE_TYPE": "BINLOG_ENCRYPTION_ADMIN"}, {"PRIVILEGE_TYPE": "INDEX"}, {"PRIVILEGE_TYPE": "REFERENCES"}, {"PRIVILEGE_TYPE": "CREATE VIEW"}, {"PRIVILEGE_TYPE": "DROP ROLE"}, {"PRIVILEGE_TYPE": "REPLICATION_SLAVE_ADMIN"}, {"PRIVILEGE_TYPE": "DROP"}, {"PRIVILEGE_TYPE": "CREATE TEMPORARY TABLES"}, {"PRIVILEGE_TYPE": "CREATE USER"}, {"PRIVILEGE_TYPE": "SESSION_VARIABLES_ADMIN"}, {"PRIVILEGE_TYPE": "SELECT"}, {"PRIVILEGE_TYPE": "CONNECTION_ADMIN"}, {"PRIVILEGE_TYPE": "FILE"}, {"PRIVILEGE_TYPE": "REPLICATION CLIENT"}, {"PRIVILEGE_TYPE": "CREATE ROLE"}, {"PRIVILEGE_TYPE": "RESOURCE_GROUP_ADMIN"}, {"PRIVILEGE_TYPE": "CREATE"}, {"PRIVILEGE_TYPE": "APPLICATION_PASSWORD_ADMIN"}, {"PRIVILEGE_TYPE": "SUPER"}, {"PRIVILEGE_TYPE": "ALTER ROUTINE"}, {"PRIVILEGE_TYPE": "SET_USER_ID"}, {"PRIVILEGE_TYPE": "ENCRYPTION_KEY_ADMIN"}, {"PRIVILEGE_TYPE": "PROCESS"}, {"PRIVILEGE_TYPE": "REPLICATION SLAVE"}, {"PRIVILEGE_TYPE": "CREATE TABLESPACE"}, {"PRIVILEGE_TYPE": "RESOURCE_GROUP_USER"}, {"PRIVILEGE_TYPE": "DELETE"}, {"PRIVILEGE_TYPE": "BACKUP_ADMIN"}, {"PRIVILEGE_TYPE": "SHOW DATABASES"}, {"PRIVILEGE_TYPE": "CREATE ROUTINE"}, {"PRIVILEGE_TYPE": "SYSTEM_VARIABLES_ADMIN"}, {"PRIVILEGE_TYPE": "GROUP_REPLICATION_ADMIN"}, {"PRIVILEGE_TYPE": "SHUTDOWN"}, {"PRIVILEGE_TYPE": "EXECUTE"}, {"PRIVILEGE_TYPE": "TRIGGER"}] |

-- insert values into table under 'mysql_user' superuser:
INSERT INTO mart_2
VALUES (10, 1000, 11, 1100, 'some text'),
       (12, 1200, 13, 1300, 'some text 2');

--Query OK, 2 rows affected (0.00 sec)
--Records: 2  Duplicates: 0  Warnings: 0

-- create user with only 'select' grands:
CREATE USER 'da_user'@'localhost' IDENTIFIED BY 'da_pass';
GRANT SELECT, SHOW VIEW, insert ON sber_test.mart_2 TO 'da_user'@'localhost';
FLUSH PRIVILEGES;

-- check grantee of 'da_user':
SELECT GRANTEE , JSON_ARRAYAGG(JSON_OBJECT('PRIVILEGE_TYPE', PRIVILEGE_TYPE)) AS list_of_grands
FROM information_schema.user_privileges
WHERE GRANTEE LIKE '%da_user%'
GROUP BY GRANTEE;

--| GRANTEE                 | list_of_grands                   |
--|------------------------ |--------------------------------- |
--| 'da_user'@'localhost'   | [{"PRIVILEGE_TYPE": "USAGE"}]    |

SHOW TABLES;

--| Tables_in_sber_test |
--|---------------------|
--| mart_2              |

-- try do select values into table under 'da_user':
SELECT * FROM mart_2;

--| key_1 | val_1 | key_2 | val_2 | str_1                 |
--|-------|-------|-------|-------|-----------------------|
--|     2 | 88749 |    13 | 87236 | ZfiVX                 |
--|     7 | 68422 |    10 | 25136 | LyFiu                 |
--|     5 | 11597 |    16 | 61654 | qimnS                 |
--|     6 | 44104 |    11 | 87907 | iVZYH                 |
--|     9 | 58317 |    17 | 83403 | GRhUN                 |
--|    44 | 10003 |    51 | 10022 | duplicate_str_val_2_1 |
--|    43 | 10333 |    50 | 40004 | duplicate_str_val_2_2 |
--|    45 | 10333 |    48 | 10333 | duplicate_str_val_2_2 |
--|    46 | 10013 |    52 | 10013 | duplicate_str_val_3_3 |
--|    47 | 10303 |    53 | 10331 | duplicate_str_val_3_4 |
--|    61 | 10013 |    62 | 10013 | duplicate_str_val_3_3 |
--|    10 |  1000 |    11 |  1100 | some text             |
--|    12 |  1200 |    13 |  1300 | some text 2           |

-- operation SELECT works

-- try do insert values into table under 'da_user':
INSERT INTO mart_2
VALUES (14, 1400, 15, 1500, 'some text_3');

--| key_1 | val_1 | key_2 | val_2 | str_1                 |
--|-------|-------|-------|-------|-----------------------|
--|     2 | 88749 |    13 | 87236 | ZfiVX                 |
--|     7 | 68422 |    10 | 25136 | LyFiu                 |
--|     5 | 11597 |    16 | 61654 | qimnS                 |
--|     6 | 44104 |    11 | 87907 | iVZYH                 |
--|     9 | 58317 |    17 | 83403 | GRhUN                 |
--|    44 | 10003 |    51 | 10022 | duplicate_str_val_2_1 |
--|    43 | 10333 |    50 | 40004 | duplicate_str_val_2_2 |
--|    45 | 10333 |    48 | 10333 | duplicate_str_val_2_2 |
--|    46 | 10013 |    52 | 10013 | duplicate_str_val_3_3 |
--|    47 | 10303 |    53 | 10331 | duplicate_str_val_3_4 |
--|    61 | 10013 |    62 | 10013 | duplicate_str_val_3_3 |
--|    10 |  1000 |    11 |  1100 | some text             |
--|    12 |  1200 |    13 |  1300 | some text 2           |
--|    10 |  1000 |    11 |  1100 | some text             |
--|    12 |  1200 |    13 |  1300 | some text 2           |

-- operation INSERT works

--try to do operation DELETE:
mysql> DELETE FROM mart_2 WHERE str_1 = 'some text';
--ERROR 1142 (42000): DELETE command denied to user 'da_user'@'localhost' for table 'mart_2'

--try to do operation ALTER , UPDATE:
ALTER TABLE mart_2 RENAME COLUMN str_1 TO new_name_of_column;
--ERROR 1142 (42000): ALTER command denied to user 'da_user'@'localhost' for table 'mart_2'

UPDATE mart_2 SET str_1 = concat('client name: ', str_1);
--ERROR 1142 (42000): UPDATE command denied to user 'da_user'@'localhost' for table 'mart_2'