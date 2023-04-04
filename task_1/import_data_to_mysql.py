from sqlalchemy import create_engine, TEXT, NUMERIC, BIGINT
from sqlalchemy.pool import NullPool
import pandas as pd

# local import
import utils.config as cfg
from task_1.create_df import list_to_df, random_list_of_int

DB_NAME = cfg.DB_NAME
USER = cfg.USER
PASSWORD = cfg.PASSWORD
HOST = cfg.HOST
PORT = cfg.PORT
TABLE = 'mart_1'


def insert_data(df: pd.DataFrame):
    # create connection to mysql db with 'poolclass=NullPool' to closed connection
    engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}',
                           pool_recycle=3600,
                           poolclass=NullPool)
    # import df to mysql
    df.to_sql(name=TABLE,
              con=engine,
              if_exists='replace',
              index=False,
              dtype={df.columns[0]: BIGINT, df.columns[1]: NUMERIC(20), df.columns[2]: BIGINT,
                     df.columns[3]: NUMERIC(20), df.columns[4]: TEXT})


if __name__ == '__main__':
    insert_data(list_to_df(random_list_of_int(low_set_val=1,
                                              high_set_val=10,
                                              length=5,
                                              sets=2)
                           ))


