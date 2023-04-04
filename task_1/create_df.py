import random
import string
import pandas as pd


# generate random lists of unique ints and push them to a dict
def random_list_of_int(low_set_val: int, high_set_val: int, length : int, sets: int) -> {}:
    keys = []
    values = []
    dict_ = {}

    # filling list with generated ints
    for i in range(sets):
        # generate the first item
        if i == 0:
            key_list = random.sample(range(low_set_val, high_set_val), length)
            keys.append(key_list)
            values_list = get_random_int(low_set_val * 1000, high_set_val * 10000, length)
            values.append(values_list)
        else:
            key_list = random.sample(range(low_set_val + (high_set_val - 1) * i, high_set_val + (high_set_val - 1) * i), length)
            keys.append(key_list)
            values_list = get_random_int(low_set_val * 1000, high_set_val * 10000, length)
            values.append(values_list)

    # adding list to the dict, there a keys are the names of columns
    for i in range(len(keys)):
        dict_.update({f'key_{i+1}': keys[i], f'val_{i+1}': values[i]})
    dict_.update({f'str_1': get_random_string(length)})

    # print(dict_)
    return dict_


# random int generator
def get_random_int(low_set_val, high_set_val, length) -> []:
    summary = []
    for i in range(length):
        summary.append(random.randint(low_set_val, high_set_val))
    return summary


# random liters generator
def get_random_string(length) ->[]:
    summary = []

    for i in range(length):
        result_str = ''.join(random.choice(string.ascii_letters) for i in range(length))
        summary.append(result_str)
    # print(summary)
    return summary


# create df from dict
def list_to_df(dict_: dict) -> pd.DataFrame:
    df = pd.DataFrame(dict_)
    print(df)
    return df


if __name__ == '__main__':
    # get_random_string(5)
    # random_list_of_int(low_set_val=1, high_set_val=10, length=5, sets=2)
    list_to_df(random_list_of_int(low_set_val=1, high_set_val=10, length=5, sets=2))