# ====================================================================
# This script prepares the data for analysis: generating relevant vars
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

# Read in data
tti_stations_merged = pd.read_csv(path_traffic_data + "importables/tti_stations_merged.csv")

# Generate post-treatment variables for each treatment date
tti_stations_merged['date'] = pd.to_datetime(tti_stations_merged['date'])
tti_stations_merged['post_treatment_1'] = np.where(tti_stations_merged['date'] > treatment_dates['treatment_1_date'], 1, 0)
tti_stations_merged['post_treatment_2'] = np.where(tti_stations_merged['date'] > treatment_dates['treatment_2_date'], 1, 0)

# Generate vars for month fixed effects to control for seasonality and day of week fixed effects
tti_stations_merged = tti_stations_merged.sort_values('date')
tti_stations_merged['month'] = tti_stations_merged['date'].dt.month
tti_stations_merged['day_of_week'] = tti_stations_merged['date'].dt.dayofweek

# Save to importables folder
save_path = path_traffic_data + "clean/tti_stations_final.csv"
tti_stations_merged.to_csv(save_path, index=False)