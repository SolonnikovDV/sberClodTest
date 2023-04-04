from sqlalchemy import create_engine, TEXT, NUMERIC, BIGINT, VARCHAR, TIMESTAMP
from sqlalchemy.pool import NullPool
import pandas as pd

# local import
import utils.config as cfg
from task_2.create_df import list_to_df, random_list_of_int, hub_link_df


DB_NAME = cfg.DB_NAME
USER = cfg.USER
PASSWORD = cfg.PASSWORD
HOST = cfg.HOST
PORT = cfg.PORT


# insert hub dataframes to db with incremental (append) data
def insert_data_hub(df: pd.DataFrame, hub_table_name: str):
    # create connection to mysql db with 'poolclass=NullPool' to closed connection
    engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}',
                           pool_recycle=3600,
                           poolclass=NullPool)
    # import df to mysql
    df.to_sql(name=hub_table_name,
              con=engine,
              if_exists='append',
              index=False,
              dtype={df.columns[0]: BIGINT})


# insert link dataframe to db with incremental (append) data
def insert_data_link(df: pd.DataFrame, table_name: str):
    # create connection to mysql db with 'poolclass=NullPool' to closed connection
    engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}',
                           pool_recycle=3600,
                           poolclass=NullPool)
    # import df to mysql
    df.to_sql(name=table_name,
              con=engine,
              if_exists='append',
              index=False,
              dtype={df.columns[0]: BIGINT,
                     df.columns[1]: BIGINT,
                     df.columns[2]: VARCHAR(20),
                     df.columns[3]: TIMESTAMP})


if __name__ == '__main__':
    # insert_data_with_replace_tab(df=list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=7, field_num=1)),
    #                              hub_table_name='hub1')
    # insert_data_with_replace_tab(df=list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=7, field_num=2)),
    #                              hub_table_name='hub2')
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
