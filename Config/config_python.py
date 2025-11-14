import os

def config_python():
    # Getting Username
    username = os.environ.get('USERNAME') or os.environ.get('USER')

    # Setting Paths
    if username == "asd890":
        path_base = "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic"
    else:
        error_message = "Username not found"
        raise ValueError(error_message)

    path_ridership_data = path_base + "/Data/Ridership/"
    path_traffic_data = path_base + "/Data/Traffic/"

    return path_ridership_data, path_traffic_data