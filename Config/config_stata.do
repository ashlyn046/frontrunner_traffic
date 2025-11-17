* ====================================================================
* This file configures the Stata environment for the project.
* ====================================================================

* Set file paths based on username
if "`c(username)'" == "asd890" {
    global path_base "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner"
} 
else {
    error "Username not found"
}

* Set file paths
global path_git "$path_base/frontrunner_traffic"
global path_data "$path_base/Data"
global path_output "$path_base/Output"
global path_logs "$path_base/Logs"

* Set global params
global treatment_1_date 2008-04-26
global treatment_2_date 2012-12-10

global ogden_nb_pm 343.38
global ogden_sb_pm 343.39
global slc_nb_pm 307.92
global slc_sb_pm 307.9
global provo_nb_pm 265.05
global provo_sb_pm 265.05
