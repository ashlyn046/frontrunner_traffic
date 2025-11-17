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
path_git, path_data, path_output, path_logs = config_python.config_python()
path_traffic_data = path_data + "/Traffic/"

# Read in TTI data
tti_n_df = pd.read_csv(path_traffic_data + "importables/tti_n_df.csv")
tti_s_df = pd.read_csv(path_traffic_data + "importables/tti_s_df.csv")

# Clean TTI data

# Restrict to rush hour data
tti_n_m_df, tti_n_e_df = aux_functions.get_rush_hour_data(tti_n_df)
tti_s_m_df, tti_s_e_df = aux_functions.get_rush_hour_data(tti_s_df)

# Add direction and rush time columns
for df, direction, rush_time in [
    (tti_n_m_df, 'North', 'Morning'),
    (tti_n_e_df, 'North', 'Evening'),
    (tti_s_m_df, 'South', 'Morning'),
    (tti_s_e_df, 'South', 'Evening')
]:
    df['direction'] = direction
    df['rush_time'] = rush_time

# Create var for which seciton of the freeway the count station is on

# Combine into one dataframe and sort
tti_df = pd.concat([tti_n_m_df, tti_n_e_df, tti_s_m_df, tti_s_e_df], axis=0)
tti_df = tti_df[sorted(tti_df.columns)]

# Save to importables folder
save_path_wide = path_traffic_data + "importables/tti_df.csv"
tti_df.to_csv(save_path_wide, index=False)

# read in saved dataframe
tti_df = pd.read_csv(save_path_wide)

# Reshape to long format, dropping lane points and % observed cols
tti_df_long = tti_df.drop(columns=['# Lane Points', '% Observed'])

tti_df_long = tti_df_long.melt(id_vars=['date', 'hour', 'direction', 'rush_time'], var_name='postmile', value_name='tti')

# Save to clean folder
save_path_long = path_traffic_data + "clean/tti_df_long.csv"
tti_df_long.to_csv(save_path_long, index=False)