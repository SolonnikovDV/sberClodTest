from import_data_to_mysql import insert_data_hub, insert_data_link
from read_from_mysql import read_table_to_df
from create_df import list_to_df, random_list_of_int, hub_link_df


# create two table in db:
insert_data_hub(df=list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=7, field_num=1)),
                hub_table_name='hub1')
insert_data_hub(df=list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=7, field_num=2)),
                hub_table_name='hub2')

# create table of hub_link into db
# -- DROP TABLE IF EXISTS l_hub1__hub2;
# -- CREATE TABLE l_hub1__hub2
# -- (
# --     id_hub_1   BIGINT,
# --     id_hub_2   BIGINT,
# --     pair_of_id VARCHAR(20),
# --     timestamp  TIMESTAMP
# -- );

# the tables could be changing (replacing, appending, etc), so we should read value from db to df
# and append extracting data to hub_link with check for duplicates
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

# suppose that data uploaded every minute, and send to a user with batches collected by a minute
# if link will be lost in a minute, sql query will return data set without lasted link row:
# -- with cte as (SELECT timestamp, count(timestamp)
# --              from l_hub1__hub2
# --              group by timestamp
# --              order by timestamp desc
# --              limit 1)
# -- select l_hub1__hub2.id_hub_1, l_hub1__hub2.id_hub_2, l_hub1__hub2.pair_of_id, l_hub1__hub2.timestamp
# -- from l_hub1__hub2
# -- where l_hub1__hub2.timestamp = (select cte.timestamp from cte);

