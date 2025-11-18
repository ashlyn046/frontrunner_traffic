# ====================================================================
# This script cleans the TTI traffic data and prepares it for analysis
#
# ====================================================================

# Import packages
import sys
import os
import pandas as pd

# Run config file
current_dir = os.getcwd()
config_dir = os.path.join(current_dir, 'Config')
sys.path.insert(0, config_dir)
cleaning_dir = os.path.join(current_dir, 'Cleaning', 'traffic')
sys.path.insert(0, cleaning_dir)

# Get paths
import config_python
import aux_functions
path_git, path_data, path_output, path_logs, postmile_params = config_python.config_python()
path_traffic_data = path_data + "/Traffic/"

# Read in TTI data
tti_n_df = pd.read_csv(path_traffic_data + "importables/tti_n_df.csv")
tti_s_df = pd.read_csv(path_traffic_data + "importables/tti_s_df.csv")

# Restrict to rush hour data
tti_n_rush_df = aux_functions.get_rush_hour_data(tti_n_df)
tti_s_rush_df = aux_functions.get_rush_hour_data(tti_s_df)

# Add direction 
for df, direction in [
    (tti_n_rush_df, 'North'),
    (tti_s_rush_df, 'South')
]:
    df['direction'] = direction

# Combine into one dataframe and sort
tti_df = pd.concat([tti_n_rush_df, tti_s_rush_df], axis=0)
tti_df = tti_df[sorted(tti_df.columns)]
tti_df = tti_df.drop(columns=['# Lane Points', '% Observed'])

# Rename postmile columns (all columns except date, hour, direction, rush_time) and take the -ML off the end of the column name
tti_df.rename(columns={col: f'pm_{col.replace("-ML", "")}' for col in tti_df.columns if col not in ['date', 'hour', 'direction', 'rush_time']}, inplace=True)

# Save to importables folder
save_path_wide = path_traffic_data + "importables/tti_df_wide.csv"
tti_df.to_csv(save_path_wide, index=False)

# read in saved dataframe
tti_df = pd.read_csv(save_path_wide)

# Reshape to long format, dropping lane points and % observed cols
tti_df_long = tti_df.melt(id_vars=['date', 'hour', 'direction', 'rush_time'], var_name='station', value_name='tti')
tti_df_long = tti_df_long.dropna(subset=['tti'])

# take pm out of station values and convert it to integer
tti_df_long['station'] = tti_df_long['station'].str.replace('pm_', '').astype(int)

# Save to importables folder
save_path_long = path_traffic_data + "importables/tti_df_long.csv"
tti_df_long.to_csv(save_path_long, index=False)