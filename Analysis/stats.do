* ====================================================================
* Calculate stats for control and trx like avg TTI
* ====================================================================

* Run config file
if "`c(username)'" == "asd890"{
    do "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic/Config/config_stata.do"
}
else{
    error "Username not found"
}

log using "$path_logs/stats.log", replace

* Read in data
use "$path_data/Traffic/clean/tti_stations_final.dta", clear

local treatment_2_numeric = date("$treatment_2_date", "YMD")

* Calculate avg TTI for control and trx
sum tti if group == 0 & date_num <= `treatment_2_numeric' & date_num >= `=date("2010-04-10", "YMD")'
sum tti if group == 2 & date_num <= `treatment_2_numeric' & date_num >= `=date("2010-04-10", "YMD")'

collapse (first) group, by(station)

* Close log file
cap log close