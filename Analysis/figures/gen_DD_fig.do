* ====================================================================
* This script generates a figure showing trends of treatment and control groups
* before and after the treatment dates.
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
duplicates drop //for some reason every obs is duplicated once... could go back and look at cleaning code but I don't have time

* Convert date to stata type
gen date_num = date(date, "YMD")
format date_num %td

* combine date var and hour var into datetime var
gen double datetime = dhms(date_num, hour, 0, 0)
format datetime %tc
xtset station datetime

* Collapse to rush hour averages by day by group
collapse (mean) tti, by(date_num group)
xtset group date_num

* Smooth out results by doing a rolling average with a window of 7 days
tssmooth ma tti_smooth = tti, window($sm_window 1 $sm_window) 
local treatment_1_numeric = date("$treatment_1_date", "YMD")
local treatment_2_numeric = date("$treatment_2_date", "YMD")

* Plot
graph twoway (line tti_smooth date_num if group == 1, color(red) lwidth(medium)) ///
             (line tti_smooth date_num if group == 2, color(blue) lwidth(medium)) , ///
             legend(label(1 "Frontrunner North") label(2 "Frontrunner South")) ///
             xtitle("Date") ytitle("Traffic Congestion Index") ///
             xline(`treatment_1_numeric', lcolor(green) lpattern(dash))  ///
             xline(`treatment_2_numeric', lcolor(green) lpattern(dash)) 