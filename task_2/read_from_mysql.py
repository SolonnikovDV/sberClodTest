import pandas as pd
from sqlalchemy import create_engine, TEXT, NUMERIC, BIGINT
from sqlalchemy.pool import NullPool

# local import
import utils.config as cfg


DB_NAME = cfg.DB_NAME
USER = cfg.USER
PASSWORD = cfg.PASSWORD
HOST = cfg.HOST
PORT = cfg.PORT


# read all data from table and transform in to dataframe
# not useful for a huge tables or need to cast into parquet and works with dataset in pyspark
def read_table_to_df(tab_name: str):
    engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}',
                           pool_recycle=3600,
                           poolclass=NullPool)

    con = engine.connect()
    df = pd.read_sql_table(tab_name, con, DB_NAME)

    pd.set_option('display.expand_frame_repr', False)

    return df


if __name__ == '__main__':
    read_table_to_df('hub1')