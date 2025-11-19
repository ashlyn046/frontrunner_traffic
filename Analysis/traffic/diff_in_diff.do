*# ====================================================================
* This script performs a difference-in-differences analysis of the impact 
* of the second section of the Frontrunner train on traffic volumes. This
* section is located between *** and *** postmiles, Provo and SLC and the 
* treatment occurs on December 10, 2012.
* ====================================================================

* Run config file
if "`c(username)'" == "asd890"{
    do "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic/Config/config_stata.do"
}
else{
    error "Username not found"
}

* Read in data
use "$path_data/Traffic/clean/tti_stations_final.dta", clear

* Short run for both treatments, making group 2 the control group
preserve 
    keep if date_num <= `=date("26apr2009", "DMY")'
    reghdfe tti i.direction_f ib2.group##post_treatment_1, absorb(station month day_of_week rush_time_f) cluster(group)
restore

preserve 
    keep if date_num >= `=date("10dec2010", "DMY")' & date_num <= `=date("10dec2013", "DMY")'
    reghdfe tti i.direction_f ib1.group##post_treatment_2, absorb(station month day_of_week rush_time_f) cluster(group)
restore

* Long run for both treatments
preserve 
    keep if date_num <= date("$treatment_2_date", "YMD")
    reghdfe tti i.direction_f ib2.group##post_treatment_1, absorb(station month day_of_week rush_time_f) cluster(group)
restore
    
preserve 
    keep if date_num >= `=date("01jan2010", "DMY")' 
    reghdfe tti i.direction_f ib1.group##post_treatment_2, absorb(station month day_of_week rush_time_f) cluster(group)
restore