<h3>TEST</h3>
<br>

<h3><A name="содержание">Содержание:</A></h3>
<h4><A href="#find_duplicates">1. Способы обнаружения в витрине дублирующихся данных</A></h4>
<h4><A href="#link_4_2_hub">2. Линк между 2мя хабами</A></h4>
<h4><A href="#user_read_only_rights">3. Витрина с ```SELECT```, ```INSERT``` правами</A></h4>
<h4><A href="#data_validation">4. Описать процесс валидации загруженных данных </A></h4>
<h4><A href="#data_validation">5. Модели Anchor и Data Vault </A></h4>

<hr>

<h6>DISCLAIMER:</h6>
<h6>В качестве базы данных во всех тасках использовалась MySQL</h6>
<hr>

<h4><A name="find_duplicates">1. Способы обнаружения в витрине дублирующихся данных</A></h4>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
Обработка данных выполнена на скриптах ```Python```, используемого  в качестве ```backend``` структуры. 

| script                  | function name      | function assignment                                                             |
|-------------------------|--------------------|---------------------------------------------------------------------------------|
| create_df.py            | random_list_of_int | creating dict with list of random dict values, every item is unique             |
| create_df.py            | get_random_int     | random int generator , returns list of random ints, every item is unique        |
| create_df.py            | get_random_string  | random liters generator                                                         |
| create_df.py            | list_to_df         | create df from dict                                                             |
| import_data_to_mysql.py | insert_data        | insert hub dataframes to db with with replace (drop if exists and create table) |


#### How it works:
* create dataframes with unique random sets of ints
* import datarames to db with creating table or drop if exists and recreating table

```python
insert_data(list_to_df(random_list_of_int(low_set_val=1,
                                              high_set_val=10,
                                              length=5,
                                              sets=2)
                           ))
```

```mysql
DESCRIBE mart_1;
```

| Field | Type          | Null | Key | Default | Extra |
|-------|---------------|------|-----|---------|-------|
| key_1 | bigint(20)    | YES  |     | NULL    |       |
| val_1 | decimal(20,0) | YES  |     | NULL    |       |
| key_2 | bigint(20)    | YES  |     | NULL    |       |
| val_2 | decimal(20,0) | YES  |     | NULL    |       |
| str_1 | text          | YES  |     | NULL    |       |


* preparing table to a testing with adding duplicates values into text columns 'val_1' и 'val_2'

```mysql
INSERT INTO mart_1
VALUES (44, 10003, 51, 10022, 'duplicate_str_val_2_1'),
       (43, 40004, 50, 40004, 'duplicate_str_val_2_2'),
       (42, 10333, 49, 10333, 'duplicate_str_val_2_2'),
       (42, 10013, 49, 10013, 'duplicate_str_val_3_3'),
       (42, 10303, 49, 10331, 'duplicate_str_val_3_4'),
       (61, 20003, 62, 20003, 'duplicate_str_val_3_3');
```

| key_1 | val_1     | key_2 | val_2     | str_1                     |
|-------|-----------|-------|-----------|---------------------------|
|     5 | 77508     |    14 | 39135     | iQigW                     |
|     6 | 52940     |    13 | 42388     | kblzR                     |
|     2 | 42332     |    17 | 8666      | okNbJ                     |
|     9 | 27915     |    12 | 22111     | POSaH                     |
|     8 | 99443     |    18 | 31030     | qrcaE                     |
|    44 | 10003     |    51 | 10022     | duplicate_str_val_2_1     |
|    43 | **10333** |    50 | 40004     | **duplicate_str_val_2_2** |
|    45 | **10333** |    48 | **10333** | **duplicate_str_val_2_2** |
|    46 | **10013** |    52 | **10013** | **duplicate_str_val_3_3** |
|    47 | 10303     |    53 | 10331     | duplicate_str_val_3_4     |
|    61 | **10013** |    62 | **10013** | **duplicate_str_val_3_3** |


* here we can see fields are duplicate only into one column

```mysql
SELECT val_1, COUNT(val_1)
FROM mart_1
GROUP BY val_1
HAVING COUNT(val_1) > 1;
```

| val_1                 | COUNT(val_1) |
|-----------------------|--------------|
| 10333                 |            2 |
| 10013                 |            2 |


* and fields are duplicates between a few columns

```mysql
SELECT val_1, val_2, COUNT(val_1) as duplicate_count
FROM mart_1
where val_1 = val_2
GROUP BY val_1, val_2;
```

| val_1 | val_2 | duplicate_count |
|-------|-------|-----------------|
| 10333 | 10333 |               1 |
| 10013 | 10013 |               2 |


* to find duplicate values i will use CTE + self JOIN

```mysql
WITH cte_1 AS (SELECT str_1, count(str_1) AS str_count
               FROM mart_1
               GROUP BY str_1
               HAVING str_count > 1)
SELECT concat('duplicate keys: ', 'key_1 = ', mart_1.key_1, ' and ', 'key_2 = ', mart_1.key_2) AS duplicate_keys,
       cte_1.str_1
FROM mart_1
         JOIN cte_1 ON mart_1.str_1 = cte_1.str_1;
```

here all duplicated cells with a pair of kyes there they are was detected

| duplicate_keys                            | str_1                 |
|-------------------------------------------|-----------------------|
| duplicate keys: key_1 = 43 and key_2 = 50 | duplicate_str_val_2_2 |
| duplicate keys: key_1 = 45 and key_2 = 48 | duplicate_str_val_2_2 |
| duplicate keys: key_1 = 46 and key_2 = 52 | duplicate_str_val_3_3 |
| duplicate keys: key_1 = 61 and key_2 = 62 | duplicate_str_val_3_3 |

<hr>

<h4><A name="find_duplicates">2. Линк между 2мя хабами</A></h6>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
Обработка данных выполнена на скриптах ```Python```, используемого  в качестве ```backend``` структуры. 

| script                  | function name      | function assignment                                                                              |
|-------------------------|--------------------|--------------------------------------------------------------------------------------------------|
| create_df.py            | random_list_of_int | creating dict with list of random dict values, the values into list could duplicate each other   |
| create_df.py            | list_to_df         | turns dict with random generated values into dataframe                                           |
| create_df.py            | hub_link_df        | create hub link councatinated data from two dataframes with validation on unique pairs of values |
| import_data_to_mysql.py | insert_data_hub    | insert hub dataframes to db with incremental (append) data                                       |
| import_data_to_mysql.py | insert_data_link   | insert link dataframe to db with incremental (**ONLY** append data)                              |
| rad_from_mysql.py       | read_table_to_df   | # read all data from table and transform in to dataframe                                         |

#### How it works:
* create two table in db:

```python
insert_data_hub(df=list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=7, field_num=1)),
                hub_table_name='hub1')
insert_data_hub(df=list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=7, field_num=2)),
                hub_table_name='hub2')
```

* create table of hub_link into db

```mysql
DROP TABLE IF EXISTS l_hub1__hub2;
CREATE TABLE l_hub1__hub2
(
    id_hub_1   BIGINT,
    id_hub_2   BIGINT,
    pair_of_id VARCHAR(20),
    timestamp  TIMESTAMP
);
```

* the tables could be changing (replacing, appending, etc) with uploading new data-batches, so we if we need all uploading data we should read value from db to df and after that append extracting data to hub_link with check for duplicates

```python
insert_data_hub(hub_link_df(list_to_df(random_list_of_int(low_set_val=1,
                                                          high_set_val=10,
                                                          length=7,
                                                          field_num=1)
                                       ),
                            list_to_df(random_list_of_int(low_set_val=1,
                                                                           high_set_val=10,
                                                                           length=7,
                                                                           field_num=2)
                                                        )
                            ), 'l_hub1__hub2')
```

* if suppose that data uploaded every minute, and send to a user batches collected by a minute, so
if link will be lost in that minute, sql query will return dataset without lasted link row:

```mysql
WITH cte AS (SELECT timestamp, count(timestamp)
              FROM l_hub1__hub2
              GROUP BY timestamp
              ORDER BY timestamp DESC 
              LIMIT 1)
SELECT l_hub1__hub2.id_hub_1, l_hub1__hub2.id_hub_2, l_hub1__hub2.pair_of_id, l_hub1__hub2.timestamp
FROM l_hub1__hub2
WHERE l_hub1__hub2.timestamp = (SELECT cte.timestamp FROM cte);
```

<hr>

<h4><A name="user_read_only_rights">3. Витрина с ```SELECT```, ```INSERT``` правами</A></h4>
<h6><A href="#содержание">назад в содержание</A></h6>

Лучший способ установить ограничения на таблицу - задать закрытый перечень прав пользователю.
Создать пользователя с правами SELECT + INSERT, либо внести изменения в права существующего.

```mysql
-- create date mart 'mart_2':
CREATE TABLE mart_2 AS SELECT * FROM mart_1;
DESCRIBE mart_2;
```

| Field | Type          | Null | Key | Default | Extra |
|-------|-------------- |------|-----|---------|-------|
| key_1 | bigint(20)    | YES  |     | NULL    |       |
| val_1 | decimal(20,0) | YES  |     | NULL    |       |
| key_2 | bigint(20)    | YES  |     | NULL    |       |
| val_2 | decimal(20,0) | YES  |     | NULL    |       |
| str_1 | text          | YES  |     | NULL    |       |

```mysql
-- check current users grantee:
SELECT GRANTEE , JSON_ARRAYAGG(JSON_OBJECT('PRIVILEGE_TYPE', PRIVILEGE_TYPE)) AS list_of_grands
FROM information_schema.user_privileges
WHERE GRANTEE LIKE '%172.25.0.1%'
GROUP BY GRANTEE;
```

| GRANTEE                   | list_of_grands                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 'mysql_user'@'172.25.0.1' | [{"PRIVILEGE_TYPE": "ROLE_ADMIN"}, {"PRIVILEGE_TYPE": "UPDATE"}, {"PRIVILEGE_TYPE": "BINLOG_ADMIN"}, {"PRIVILEGE_TYPE": "ALTER"}, {"PRIVILEGE_TYPE": "SHOW VIEW"}, {"PRIVILEGE_TYPE": "XA_RECOVER_ADMIN"}, {"PRIVILEGE_TYPE": "PERSIST_RO_VARIABLES_ADMIN"}, {"PRIVILEGE_TYPE": "RELOAD"}, {"PRIVILEGE_TYPE": "LOCK TABLES"}, {"PRIVILEGE_TYPE": "EVENT"}, {"PRIVILEGE_TYPE": "SERVICE_CONNECTION_ADMIN"}, {"PRIVILEGE_TYPE": "INSERT"}, {"PRIVILEGE_TYPE": "BINLOG_ENCRYPTION_ADMIN"}, {"PRIVILEGE_TYPE": "INDEX"}, {"PRIVILEGE_TYPE": "REFERENCES"}, {"PRIVILEGE_TYPE": "CREATE VIEW"}, {"PRIVILEGE_TYPE": "DROP ROLE"}, {"PRIVILEGE_TYPE": "REPLICATION_SLAVE_ADMIN"}, {"PRIVILEGE_TYPE": "DROP"}, {"PRIVILEGE_TYPE": "CREATE TEMPORARY TABLES"}, {"PRIVILEGE_TYPE": "CREATE USER"}, {"PRIVILEGE_TYPE": "SESSION_VARIABLES_ADMIN"}, {"PRIVILEGE_TYPE": "SELECT"}, {"PRIVILEGE_TYPE": "CONNECTION_ADMIN"}, {"PRIVILEGE_TYPE": "FILE"}, {"PRIVILEGE_TYPE": "REPLICATION CLIENT"}, {"PRIVILEGE_TYPE": "CREATE ROLE"}, {"PRIVILEGE_TYPE": "RESOURCE_GROUP_ADMIN"}, {"PRIVILEGE_TYPE": "CREATE"}, {"PRIVILEGE_TYPE": "APPLICATION_PASSWORD_ADMIN"}, {"PRIVILEGE_TYPE": "SUPER"}, {"PRIVILEGE_TYPE": "ALTER ROUTINE"}, {"PRIVILEGE_TYPE": "SET_USER_ID"}, {"PRIVILEGE_TYPE": "ENCRYPTION_KEY_ADMIN"}, {"PRIVILEGE_TYPE": "PROCESS"}, {"PRIVILEGE_TYPE": "REPLICATION SLAVE"}, {"PRIVILEGE_TYPE": "CREATE TABLESPACE"}, {"PRIVILEGE_TYPE": "RESOURCE_GROUP_USER"}, {"PRIVILEGE_TYPE": "DELETE"}, {"PRIVILEGE_TYPE": "BACKUP_ADMIN"}, {"PRIVILEGE_TYPE": "SHOW DATABASES"}, {"PRIVILEGE_TYPE": "CREATE ROUTINE"}, {"PRIVILEGE_TYPE": "SYSTEM_VARIABLES_ADMIN"}, {"PRIVILEGE_TYPE": "GROUP_REPLICATION_ADMIN"}, {"PRIVILEGE_TYPE": "SHUTDOWN"}, {"PRIVILEGE_TYPE": "EXECUTE"}, {"PRIVILEGE_TYPE": "TRIGGER"}] |

```mysql
-- prepare the table
-- insert values into table under 'mysql_user' superuser:
INSERT INTO mart_2
VALUES (10, 1000, 11, 1100, 'some text'),
       (12, 1200, 13, 1300, 'some text 2');

--Query OK, 2 rows affected (0.00 sec)
--Records: 2  Duplicates: 0  Warnings: 0
```

```mysql
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
```

| Tables_in_sber_test |
|---------------------|
| mart_2              |


Отмечаем, что созданный пользователь видит только одну таблицу, на просмотр который получил права.

```mysql
-- try do select values into table under 'da_user':
SELECT * FROM mart_2;
```

| key_1 | val_1 | key_2 | val_2 | str_1                 |
|-------|-------|-------|-------|-----------------------|
|     2 | 88749 |    13 | 87236 | ZfiVX                 |
|     7 | 68422 |    10 | 25136 | LyFiu                 |
|     5 | 11597 |    16 | 61654 | qimnS                 |
|     6 | 44104 |    11 | 87907 | iVZYH                 |
|     9 | 58317 |    17 | 83403 | GRhUN                 |
|    44 | 10003 |    51 | 10022 | duplicate_str_val_2_1 |
|    43 | 10333 |    50 | 40004 | duplicate_str_val_2_2 |
|    45 | 10333 |    48 | 10333 | duplicate_str_val_2_2 |
|    46 | 10013 |    52 | 10013 | duplicate_str_val_3_3 |
|    47 | 10303 |    53 | 10331 | duplicate_str_val_3_4 |
|    61 | 10013 |    62 | 10013 | duplicate_str_val_3_3 |
|    10 |  1000 |    11 |  1100 | some text             |
|    12 |  1200 |    13 |  1300 | some text 2           |

operation SELECT works

```mysql
-- try do insert values into table under 'da_user':
INSERT INTO mart_2
VALUES (14, 1400, 15, 1500, 'some text_3');
```

| key_1 | val_1 | key_2 | val_2 | str_1                 |
|-------|-------|-------|-------|-----------------------|
|     2 | 88749 |    13 | 87236 | ZfiVX                 |
|     7 | 68422 |    10 | 25136 | LyFiu                 |
|     5 | 11597 |    16 | 61654 | qimnS                 |
|     6 | 44104 |    11 | 87907 | iVZYH                 |
|     9 | 58317 |    17 | 83403 | GRhUN                 |
|    44 | 10003 |    51 | 10022 | duplicate_str_val_2_1 |
|    43 | 10333 |    50 | 40004 | duplicate_str_val_2_2 |
|    45 | 10333 |    48 | 10333 | duplicate_str_val_2_2 |
|    46 | 10013 |    52 | 10013 | duplicate_str_val_3_3 |
|    47 | 10303 |    53 | 10331 | duplicate_str_val_3_4 |
|    61 | 10013 |    62 | 10013 | duplicate_str_val_3_3 |
|    10 |  1000 |    11 |  1100 | some text             |
|    12 |  1200 |    13 |  1300 | some text 2           |
|    10 |  1000 |    11 |  1100 | some text             |
|    12 |  1200 |    13 |  1300 | some text 2           |

operation INSERT works

```mysql
-- try to do operation DELETE:
DELETE FROM mart_2 WHERE str_1 = 'some text';
-- ERROR 1142 (42000): DELETE command denied to user 'da_user'@'localhost' for table 'mart_2'

-- try to do operation ALTER , UPDATE:
ALTER TABLE mart_2 RENAME COLUMN str_1 TO new_name_of_column;
-- ERROR 1142 (42000): ALTER command denied to user 'da_user'@'localhost' for table 'mart_2'

UPDATE mart_2 SET str_1 = concat('client name: ', str_1);
-- ERROR 1142 (42000): UPDATE command denied to user 'da_user'@'localhost' for table 'mart_2'
```

#### Вывод:
* Установлнные ограничения работают, пользователю доступны опции только просмотр, чтение и вставка

<hr>

<h4><A name="data_validation">4. Описать процесс валидации загруженных данных </A></h4>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>

### Варианты валидации:
* по источнику данных
* по ожидаемому типу данных
* по наличию эканируемых символов
* ```NULL``` объекты
* на соответствие шаблону (например ```'dd-mm-YYYY H24:MI:SS UTC'```)
* на ограничения принмаемых данными значений 
* на макросы

### Настройка валидации
* на этапе проектирования:
  * изучение источника данных (API, eternal/external storage, local generated info, ftp, etc...), на предмет в каком виде выдаются данные, наличие/отсутствие необходимости предподготовки данных
  * тип конвейра извлечения данных (ELT, ETL), для понимания на каком этапе выполнять валидацию
* где выполнять валидацию на backend или в БД
* что делать с данными, не прошедшими проверку (правила)

### Инструменты валидации:
* набор правил - проектирование набора правил, готовится для известных типов данных (т.е. мы хорошо знаем сточник и понимаем что к нам приходит)
  * правила неизменяемые (встроенные) - относятся чаще к типам
  * правила пользовательские - ограничения наложенные бизнесом к объему данных (например часть данных, получаемых через API, не используется никогда, но фактически занимает место)
  * правила условные - параметры бизнес планирования
* обработка ```NULL``` объектов - такие объекты могут говорить как о неполноте получаемых данных (необходима оценка бизнесом о необходимости таких источников), либо о проблемах с извлечением данных ("кривое API")
* проверка контрольных сумм излекаемых и загруженных данных

### Процесс валидации
* извлекаемые данные парсятся на предмет проверки типов данных
* если тип данных отличается от ожидаемого, выполняется приведение к нужному типу
* если приведение к нужному типу не происходит, такое исключение оброабатывается, а объект, не прошедший валидацю, утилищируется по заданному правилу (удаление, загрузка с пометкой, загрузка в батч с невалидными данными и тд)
* данные прошедшие валидацию транспортируются в очищеный слой
* см. проблемный сценарий

### Какие могут быть проблемы
* плохо изученный источник генерирует данные, которые образом проходят проверку валидатора, но могут вызвать исключения и завершение программы
* данные намерянно "замаскированы" под ожидаемый тип (пользовательский класс)

### Как решать такие проблемы
* предусмотреть на backend обработку исключений, связанных с траспортом данных
* тестирование загруженных и прошедших валидаторы данных по сценариям (сценарий - объем операций предусморенных для данных, выборки, использование в приложениях, визуализация и т.д.)
  * загрузка данных на тестовый стенд
  * проверка по сценариям, 
  * обработка исключений в процессе сценарного тестирования, 
  * утилизация невалидных данных 
  * загрузка валидных данных на реплику
  * траспорт  с реплики в очищенный слой данных
  
<hr>

<h4><A name="data_validation">5. Модели Anchor и Data Vault</A></h4>
<h6><A href="#содержание">назад в содержание</A></h6>

#### Дана таблица:

```mysql
create table tt 
(
    id1, -- ссылка на таблицу t1
    id2, -- ссылка на таблицу t2
    id3, -- ссылка на таблицу t3
    s1,
    s2,
    f1,
    f2,
    unique (id1, id2, id3)
);
```

где ```id1, id2, id3``` - внешние ключи

#### Необходимо представить эту таблицу в виде:
* якорной модели (anchor modeling) 
* дата волта (data vault)

#### Подготовка:
* Учитывая, что модели Data Vault и  Anchor предполагают пределенную глубину нормализации, 
то перед представлением моделей подвергнем таблицу декомпозиции


### Data vault
#### Описание моделирования
* Допустим: 
  * таблицы t1, t2, t3 являются бизнес-сущностями (hub). Поля данных сущностей не меняются.
  таблицы сущностей имеют ключ, дающий доступ к иным системам и внутрений инкрементальный ключ для индексации данных
  * таблицы f1 и f2 - связи (link) между сущностями, содержат в себе в качестве внешних ключей ключи (id1, id2, id3) сущностей
product customer store
    * таблицы s1 и s2 - сателиты (satellite) содержит свойства бизнес-сущности (ее изменяемые атрибуты) или связи
* Создадим таблицы, где:
  * t1, t2, t3 являются бизнес-сущностями Producer, Product, Customer (hub_t1_customer, hub_t2_product, hub_t3_manufacturer)
  * f1 и f2 являются материализацией взаимодействия между бизнес-сущностями (бизнес-процесс) такими как Produces и Buys (как процесс демонстрации товара)
  * s1 и s2 описывают атрибуты и(или) свойства бизнес сущности или процесса (связи), в данном случае описываются атрибуты бизнес-сущностей SocialId (соцальный идентификатор), ProdSpec (спецификация товара)
  * Связи и аттрибуты связываются с бизнес-сущностями внешними ключами (id)
  * Buys cвязывает Produces и Customer, Produces связывает Producer и Product, т е выполняем ссылку линка на линк
  * SocialId описывает бизнес-сущность Customer, ProdSpec описывает Product

#### Create hub tables
```mysql
CREATE TABLE hub_t1_customer (
    t1_pk BIGINT NOT NULL AUTO_INCREMENT,
    t1_id VARCHAR(36) NOT NULL, -- autogenerated hash string
    UNIQUE (t1_id),
    PRIMARY KEY (t1_pk)
);

CREATE TABLE hub_t2_product (
    t2_pk BIGINT NOT NULL AUTO_INCREMENT,
    t2_id VARCHAR(36) NOT NULL, -- autogenerated hash string
    UNIQUE (t2_id),
    PRIMARY KEY (t2_pk)
);

CREATE TABLE hub_t3_producer (
    t3_pk BIGINT NOT NULL AUTO_INCREMENT,
    t3_id VARCHAR(36) NOT NULL, -- autogenerated hash string
    UNIQUE (t3_id),
    PRIMARY KEY (t3_pk)
);
```
#### Create link tables:

```mysql
-- interaction between producer and product
CREATE TABLE l_f1_produces (
    f1_id VARCHAR(36) NOT NULL, -- autogenerated hash string
    t3_id VARCHAR(36) NOT NULL, -- fk to producer hub
    t2_id VARCHAR(36) NOT NULL -- fk to product hub
);
-- interaction between customer and produces
CREATE TABLE l_f2_buys (
    f2_id VARCHAR(36) NOT NULL, -- autogenerated hash string
    t1_id VARCHAR(36) NOT NULL, -- fk to customer hub
    f1_id VARCHAR(36) NOT NULL -- fk to produces link
);
```
#### Create satellite tables:

```mysql
-- customer attribute
CREATE TABLE S_s1_socialId (
    t1_id VARCHAR(36) NOT NULL, -- fk to customer hub
    -- attributes
    f_name varchar(20) NOT NULL,
    l_name varchar(20) NOT NULL,
    soc_id bigint NOT NULL,
    from_date timestamp,
    to_date timestamp
);
-- product attribute
CREATE TABLE S_s2_prodSpec (
    t2_id VARCHAR(36) NOT NULL, -- fk to product key
    -- attributes
    brand varchar(20) NOT NULL,
    dimensions JSON NOT NULL,
    inUse boolean,
    from_date timestamp,
    to_date timestamp
);
```

<img src="/Users/dmitrysolonnikov/PycharmProjects/sberClodTest/task_5/DataVault_model.png">


### Anchor Model
* Разница между моделингом DataVault и Anchor:
  * Anchor не допускает ссылок линков на линки
  * Anchor не допускает наличие саттелитов на линках
#### Описание моделирования
* За основу возьмем описание Data Vault за исключением связей линков:
  * Buys cвязывает Product и Customer, Produces связывает Producer и Product, в данном случае снимаем ссылку на линк и меняем ее ссылкой на хаб
  * SocialId описывает бизнес-сущность Customer, ProdSpec описывает Product


#### Create link tables:

```mysql
-- interaction between producer and product
CREATE TABLE l_f1_produces (
    f1_id VARCHAR(36) NOT NULL, -- autogenerated hash string
    t3_id VARCHAR(36) NOT NULL, -- fk to producer hub
    t2_id VARCHAR(36) NOT NULL -- fk to product hub
);
-- interaction between customer and product
CREATE TABLE l_f2_buys (
    f2_id VARCHAR(36) NOT NULL, -- autogenerated hash string
    t2_id VARCHAR(36) NOT NULL, -- fk to product hub
    t1_id VARCHAR(36) NOT NULL -- fk to customer hub
);
```
<br>

<img src="/Users/dmitrysolonnikov/PycharmProjects/sberClodTest/task_5/DataVault_Anchor_model.png">
