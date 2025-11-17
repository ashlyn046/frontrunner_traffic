import pandas as pd

# READ_TTI_DATA:This function reads in TTI data from excel files of the form 
# tti_file_str_x_y where x is from 8 to 14 in steps of 2 and y is from 10 to 
# 16 in steps of 2 and returns a dataframe with the TTI data
def read_tti_data(file_str, path_str):
    df = pd.DataFrame()
    for x,y in zip(range(8, 20, 2), range(10, 22, 2)):
        #print(x, y)
        
        file_name = f"tti_{file_str}_{x}_{y}.xlsx"
        file_path = path_str + 'raw/' + file_name
        
        curr_df = pd.read_excel(file_path, sheet_name='Report Data')
        curr_df = curr_df[sorted(curr_df.columns)]
        
        df = pd.concat([df, curr_df], axis=0, ignore_index=True) 
        # print(df)
        #list(df.columns)

    # Split date/time var into date and hour
    df['date'] = df['Hour'].dt.date
    df['hour'] = df['Hour'].dt.hour
    df = df.drop('Hour', axis=1)

    return df

# GET_RUSH_HOUR_DATA: This function creates dataframes of rush hour data
# for morning and evening rush hours. We count hours 7-9 as morning rush hours
# and hours 4-7 as evening rush hours.
def get_rush_hour_data(df):
    df_m = df[df['hour'].isin([7,8,9])]
    df_e = df[df['hour'].isin([16,17,18,19])]
    return df_m, df_e