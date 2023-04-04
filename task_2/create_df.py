import datetime
import random
import pandas as pd
from read_from_mysql import read_table_to_df


# creating dict with list of random dict values
# the values into list could duplicate each other
def random_list_of_int(low_set_val: int, high_set_val: int, length : int, field_num: int) -> {}:
    keys = [random.sample(range(low_set_val, high_set_val), length)]
    dict_ = {}

    for i in range(len(keys)):
        dict_.update({f'id_hub_{field_num}': keys[i]})

    # print(dict_)
    return dict_

# turns dict with random generated values into dataframe
def list_to_df(dict_: dict) -> pd.DataFrame:
    df = pd.DataFrame(dict_)
    # print(df)
    return df


def hub_link_df(df_hub1, df_hub2):
    df1 = df_hub1
    df2 = df_hub2

    # concat columns from two df into one
    df_hub = pd.concat([df1, df2], axis=1)
    # print(df_hub)

    # get the count of repeatable pairs into two columns
    # pair with count value > 1 is not unique
    df_hub = df_hub.groupby([df1.columns[0], df2.columns[0]]).size().reset_index().rename(columns={0:'count'})
    # print(df_hub)

    # filtering df by condition to get only unique pairs into df
    df_link = df_hub[df_hub['count'] == 1].drop('count', axis=1)

    df_link['pair_of_id'] = '[' + df_link[df_link.columns[0]].astype(str) + ' : ' + df_link[df_link.columns[1]].astype(str) + ']'
    df_link['timestamp'] = pd.Timestamp('now').strftime("%Y/%m/%d %H:%M")
    # print(df_link)
    return df_link



if __name__ == '__main__':
    hub_link_df(list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=7, field_num=1)),
                list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=7, field_num=2)))
    hub_link_df(read_table_to_df('hub1'), read_table_to_df('hub2'))