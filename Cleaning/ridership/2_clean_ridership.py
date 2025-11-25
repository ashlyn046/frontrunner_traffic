# ====================================================================
# This script cleans the ridership data
# ====================================================================

# Import packages
import sys
import os
import pandas as pd

# Run config file
current_dir = os.getcwd()
config_dir = os.path.join(current_dir, 'Config')
sys.path.insert(0, config_dir)
cleaning_dir = os.path.join(current_dir, 'Cleaning', 'ridership')
sys.path.insert(0, cleaning_dir)

# Get paths
import config_python
path_git, path_data, path_output, path_logs, postmile_params, treatment_dates = config_python.config_python()
path_ridership_data = path_data + "/Ridership/"

# Read in ridership data
df_ridership = pd.read_csv(path_ridership_data + "importables/ridership_data.csv")
