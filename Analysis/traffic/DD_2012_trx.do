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
import delimited "$path_data/Traffic/clean/tti_stations_final.csv", clear

* Encode factor vars
encode direction, generate(direction_f)
encode rush_time, generate(rush_time_f)

* Run difference-in-differences analysis full
reg tti i.direction_f group##post_treatment_1 group##post_treatment_2 i.month i.day_of_week i.rush_time_f

* Short run for both treatments

* Long run for both treatments