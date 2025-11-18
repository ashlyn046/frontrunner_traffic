# ====================================================================
# This script reads in, compiles, and cleanshourly travel time index 
# (TTI) data for I15 North and South. 
#
# The data can be found at https://udot.iteris-pems.com/ but users must 
# request an account to access the data. Navigate to Performance/Spacial 
# Analysis/Multistation and select TTI as the "Quantity" and "Hour" for 
# granularity. We use Postmile range of 265 to 344 for both north and south
#
# We exclude weekends and hilodays from the data (using the GUI filters)
# We use mainline indicators (not HOV lanes)
# ====================================================================

# Import packages
import sys
import os
import pandas as pd

# Run config file
current_dir = os.getcwd()
config_dir = os.path.join(current_dir, 'Config')
cleaning_dir = os.path.join(current_dir, 'Cleaning', 'traffic')
sys.path.insert(0, config_dir)
sys.path.insert(0, cleaning_dir)

# Get paths
import config_python
import aux_functions
path_git, path_data, path_output, path_logs, postmile_params, treatment_dates = config_python.config_python()
path_traffic_data = path_data + "/Traffic/"

# Read in and append TTI data for North and South
tti_n_df = aux_functions.read_tti_data("n", path_traffic_data)
tti_s_df = aux_functions.read_tti_data("s", path_traffic_data)

# Save to importables folder
save_path_n = path_traffic_data + "importables/tti_n_df.csv"
tti_n_df.to_csv(save_path_n, index=False)
save_path_s = path_traffic_data + "importables/tti_s_df.csv"
tti_s_df.to_csv(save_path_s, index=False)
