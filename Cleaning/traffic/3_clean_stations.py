# ====================================================================
# This script cleans the traffic station data and prepares it for analysis
# ====================================================================

# Import packages
import sys
import os
import pandas as pd
import numpy as np

# Run config file
current_dir = os.getcwd()
config_dir = os.path.join(current_dir, 'Config')
sys.path.insert(0, config_dir)
cleaning_dir = os.path.join(current_dir, 'Cleaning', 'traffic')
sys.path.insert(0, cleaning_dir)

# Get paths
import config_python
path_git, path_data, path_output, path_logs, postmile_params, treatment_dates = config_python.config_python()
path_traffic_data = path_data + "/Traffic/"

# Read in station data excel file
stations_n = pd.read_excel(path_traffic_data + "raw/stations_n.xlsx")
stations_s = pd.read_excel(path_traffic_data + "raw/stations_s.xlsx")

# Combine into one dataframe
stations_df = pd.concat([stations_n, stations_s], axis=0)

# Rename vars
stations_df.rename(columns={'Fwy': 'direction' , 'State PM': 'postmile', 'ID': 'station'}, inplace=True)
stations_df['direction'] = np.where(stations_df['direction'] == 'I15-N', 'North', 'South')

# Keep only necessary vars
stations_df = stations_df[['station', 'direction', 'postmile']]

# Save to importables folder
save_path = path_traffic_data + "importables/stations_df.csv"
stations_df.to_csv(save_path, index=False)