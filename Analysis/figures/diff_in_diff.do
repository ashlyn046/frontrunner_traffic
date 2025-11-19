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

* We will interact with each month and then get a plot of coeffs on tti interacted with each month
preserve
    keep if date_num <= date("01jan2014", "DMY") & date_num >= date("01jan2011", "DMY")
    reghdfe tti i.direction_f ib1.group##i.month_year, absorb(station day_of_week rush_time_f) cluster(group)
restore

* Plot the results
graph twoway (line _b_i.direction_f#c.month_year date_num if group == 1, color(red) lwidth(medium)) ///
             (line _b_i.direction_f#c.month_year date_num if group == 2, color(blue) lwidth(medium)) , ///
             legend(label(1 "Frontrunner North") label(2 "Frontrunner South")) ///
             xtitle("Date") ytitle("Coefficient on TTI") ///
             xline(`treatment_2_numeric', lcolor(green) lpattern(dash)) 
