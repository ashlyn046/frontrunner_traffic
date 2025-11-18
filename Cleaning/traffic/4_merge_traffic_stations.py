# ====================================================================
# This script merges the traffic station data with the TTI data
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
path_git, path_data, path_output, path_logs, postmile_params, treatment_dates = config_python.config_python()
path_traffic_data = path_data + "/Traffic/"

# Read in TTI data
tti_df_long = pd.read_csv(path_traffic_data + "importables/tti_df_long.csv")

# Read in station data
stations_df = pd.read_csv(path_traffic_data + "importables/stations_df.csv")

# Merge TTI data with station data on station and direction 
tti_merged_df = tti_df_long.merge(stations_df, on=['station', 'direction'], how='left')
tti_merged_df = tti_merged_df.dropna(subset=['postmile'])

# Drop if missing postmile
tti_merged_df = tti_merged_df.dropna(subset=['postmile'])

# Save to importables folder
save_path = path_traffic_data + "importables/tti_df_long_stations.csv"
tti_merged_df.to_csv(save_path, index=False)

# Create var for which section of the freeway the count station is on
# Group 1 (Ogden -> SLC): Southbound between 307.9 and 343.39 postmiles during morning rush hours and 
    # Northbound between 307.92 and 343.38 postmiles during evening rush hours
grp1_mask = (
    ((tti_merged_df['direction'] == 'South') & 
     (tti_merged_df['postmile'] >= 307.9) & 
     (tti_merged_df['postmile'] <= 343.39)) |
    ((tti_merged_df['direction'] == 'North') & 
     (tti_merged_df['postmile'] >= 307.92) & 
     (tti_merged_df['postmile'] <= 343.38))
)

# Group 2 (Provo -> SLC): Northbound between 265.05 and 307.92 postmiles during morning rush hours and 
    # Southbound between 265.05 and 307.9 postmiles during evening rush hours
grp2_mask = (
    ((tti_merged_df['direction'] == 'North') & 
     (tti_merged_df['postmile'] >= 265.05) & 
     (tti_merged_df['postmile'] <= 307.92)) |
    ((tti_merged_df['direction'] == 'South') & 
     (tti_merged_df['postmile'] >= 265.05) & 
     (tti_merged_df['postmile'] <= 307.9))
)

# Assign groups
tti_merged_df['group'] = 0  # default
tti_merged_df.loc[grp1_mask, 'group'] = 1
tti_merged_df.loc[grp2_mask, 'group'] = 2

# drop if group is 0
tti_merged_df = tti_merged_df.drop(tti_merged_df[tti_merged_df['group'] == 0].index)

# Save to importables folder
save_path = path_traffic_data + "importables/tti_stations_merged.csv"
tti_merged_df.to_csv(save_path, index=False)
