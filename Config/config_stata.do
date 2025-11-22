* ====================================================================
* This file configures the Stata environment for the project.
* ====================================================================

* Set file paths based on username
if "`c(username)'" == "asd890" {
    global path_base "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner"
    global path_overleaf "C:/Users/asd890/Dropbox (Harvard University)/Applications/Overleaf/Utah Traffic and the Frontrunner Train"
} 
else {
    error "Username not found"
}

* Set file paths
global path_git "$path_base/frontrunner_traffic"
global path_data "$path_base/Data"
global path_output "$path_base/Output"
global path_logs "$path_base/Logs"

* Run settings
global output_overleaf 1
global num_placebo_tests = 300
global table_scale = .7

* Set global params
global treatment_1_date 2008-04-26
global treatment_2_date 2012-12-10

global ogden_nb_pm 343.38
global ogden_sb_pm 343.39
global slc_nb_pm 307.92
global slc_sb_pm 307.9
global provo_nb_pm 265.05
global provo_sb_pm 265.05

global sm_window 100

* Set graph params
global graph_width 1500
global graph_height 1000
global graph_angle 0
global graph_msize 1.5
global graph_text 1.5
global graph_note 1.5
global graph_title 3
global graph_xtitle 3
global graph_ytitle 3
global graph_label 2.5
global graph_legend 3
