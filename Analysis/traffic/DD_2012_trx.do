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

* Run difference-in-differences analysis
reg tti i.direction i.rush_time i.direction#i.rush_time i.group