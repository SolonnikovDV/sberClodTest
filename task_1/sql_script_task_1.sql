DESCRIBE mart_1;

--| Field | Type          | Null | Key | Default | Extra |
--|-------|---------------|------|-----|---------|-------|
--| key_1 | bigint(20)    | YES  |     | NULL    |       |
--| val_1 | decimal(20,0) | YES  |     | NULL    |       |
--| key_2 | bigint(20)    | YES  |     | NULL    |       |
--| val_2 | decimal(20,0) | YES  |     | NULL    |       |
--| str_1 | text          | YES  |     | NULL    |       |

-- preparing table to a testing with adding duplicates values into text columns 'val_1' и 'val_2'
insert into mart_1
values (44, 10003, 51, 10022, 'duplicate_str_val_2_1'),
       (43, 40004, 50, 40004, 'duplicate_str_val_2_2'),
       (42, 10333, 49, 10333, 'duplicate_str_val_2_2'),
       (42, 10013, 49, 10013, 'duplicate_str_val_3_3'),
       (42, 10303, 49, 10331, 'duplicate_str_val_3_4'),
       (61, 20003, 62, 20003, 'duplicate_str_val_3_3');

--| key_1 | val_1 | key_2 | val_2 | str_1                 |
--|-------|-------|-------|-------|-----------------------|
--|     5 | 77508 |    14 | 39135 | iQigW                 |
--|     6 | 52940 |    13 | 42388 | kblzR                 |
--|     2 | 42332 |    17 |  8666 | okNbJ                 |
--|     9 | 27915 |    12 | 22111 | POSaH                 |
--|     8 | 99443 |    18 | 31030 | qrcaE                 |
--|    44 | 10003 |    51 | 10022 | duplicate_str_val_2_1 |
--|    43 | 10333 |    50 | 40004 | duplicate_str_val_2_2 |
--|    45 | 10333 |    48 | 10333 | duplicate_str_val_2_2 |
--|    46 | 10013 |    52 | 10013 | duplicate_str_val_3_3 |
--|    47 | 10303 |    53 | 10331 | duplicate_str_val_3_4 |
--|    61 | 10013 |    62 | 10013 | duplicate_str_val_3_3 |

-- fields are duplicate only into one column
SELECT val_1, COUNT(val_1)
FROM mart_1
GROUP BY val_1
HAVING COUNT(val_1) > 1;

--| val_1                 | COUNT(val_1) |
--|-----------------------|--------------|
--| 10333                 |            2 |
--| 10013                 |            2 |

-- fields are duplicates between a few columns
SELECT val_1, val_2, COUNT(val_1) as duplicate_count
FROM mart_1
where val_1 = val_2
GROUP BY val_1, val_2;

--| val_1 | val_2 | duplicate_count |
--|-------|-------|-----------------|
--| 10333 | 10333 |               1 |
--| 10013 | 10013 |               2 |

-- using CTE + self JOIN
WITH cte_1 AS (SELECT str_1, count(str_1) AS str_count
               FROM mart_1
               GROUP BY str_1
               HAVING str_count > 1)
SELECT concat('duplicate keys: ', 'key_1 = ', mart_1.key_1, ' and ', 'key_2 = ', mart_1.key_2) AS duplicate_keys,
       cte_1.str_1
FROM mart_1
         JOIN cte_1 ON mart_1.str_1 = cte_1.str_1;

--| duplicate_keys                            | str_1                 |
--|-------------------------------------------|-----------------------|
--| duplicate keys: key_1 = 43 and key_2 = 50 | duplicate_str_val_2_2 |
--| duplicate keys: key_1 = 45 and key_2 = 48 | duplicate_str_val_2_2 |
--| duplicate keys: key_1 = 46 and key_2 = 52 | duplicate_str_val_3_3 |
--| duplicate keys: key_1 = 61 and key_2 = 62 | duplicate_str_val_3_3 |