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

    return path_git, path_data, path_output, path_logs