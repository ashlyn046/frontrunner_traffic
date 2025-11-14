# import packages
import sys
import os
import pandas as pd

# Run config file
current_dir = os.getcwd()
config_dir = os.path.join(current_dir, 'Config')
sys.path.insert(0, config_dir)

# Get paths
import config_python
path_ridership_data, path_traffic_data = config_python.config_python()

filepath = path_ridership_data + "rail_stop_ridership_table.csv"
df_ridership = pd.read_csv(filepath)
df_ridership = pd.read_csv("C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic/Data/Ridership/rail_stop_ridership_table.csv")