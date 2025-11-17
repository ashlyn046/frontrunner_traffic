import os

def config_python():
    # Getting Username
    username = os.environ.get('USERNAME') or os.environ.get('USER')

    # Setting Paths
    if username == "asd890":
        path_base = "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner"
    else:
        error_message = "Username not found"
        raise ValueError(error_message)

    path_git = path_base + "/frontrunner_traffic"
    path_data = path_base + "/Data"
    path_output = path_base + "/Output"
    path_logs = path_base + "/Logs"

    # Set postmile params as dict
    postmile_params = {
        "ogden_nb": 343.38,
        "ogden_sb": 343.39,
        "slc_nb": 307.92,
        "slc_sb": 307.9,
        "provo_nb": 265.05,
        "provo_sb": 265.05
    }

    return path_git, path_data, path_output, path_logs, postmile_params