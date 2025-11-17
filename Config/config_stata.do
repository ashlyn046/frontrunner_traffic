* ====================================================================
* This file configures the Stata environment for the project.
* ====================================================================

* Set file paths based on username
if "`c(username)'" == "asd890" {
    global path_base "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner"
} else {
    error "Username not found"
}

* Set file paths
global path_git "$path_base/frontrunner_traffic"
global path_data "$path_base/Data"
global path_output "$path_base/Output"
global path_logs "$path_base/Logs"
