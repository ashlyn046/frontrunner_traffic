********************************************************************************
* Event Study / Dynamic DiD
********************************************************************************

* Run config file
if "`c(username)'" == "asd890"{
    do "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic/Config/config_stata.do"
}
else{
    error "Username not found"
}

set 	scheme 	plotplain
graph set print fontface "Times New Roman"

* Read in data
use "$path_data/Traffic/clean/tti_stations_final.dta", clear
drop if group == 1
replace group = 1 if group == 2

* Create relative time variable (months relative to treatment)
gen treatment_date = date("10dec2012", "DMY")
gen months_to_treatment = mofd(date_num) - mofd(treatment_date)

* Create event time dummies (12 months before to 12 months after)
* Omit month -1 as reference period
forvalues i = 12(-1)2 {
    gen lead`i' = (months_to_treatment == -`i' & group == 1)
}

forvalues i = 0/12 {
    gen lag`i' = (months_to_treatment == `i' & group == 1)
}

* Run event study regression
reghdfe tti lead12-lead2 lag0-lag12, ///
    absorb(station month year day_of_week rush_time_f) ///
    cluster(station)

* Test joint significance of all leads (pre-treatment periods)
test lead12 lead11 lead10 lead9 lead8 lead7 lead6 lead5 lead4 lead3 lead2

local pretrend_p = r(p)
display "Pre-trend test p-value: `pretrend_p'"

* Store coefficients for plotting
estimates store event_study

* Plot event study
coefplot event_study, ///
    keep(lead* lag*) ///
    vertical ///
    xline(12, lcolor(red) lpattern(dash)) ///
    xlabel(0 "-12" 4 "-8" 8 "-4" 12 "0" 16 "4" 20 "8" 24 "12", nogrid) ///
	ylabel( , nogrid) ///
    ytitle("Effect on TTI", size($graph_ytitle)) ///
    xtitle("Months Relative to Treatment", size($graph_xtitle)) ///
    title("Event Study: Frontrunner South Opening", size($graph_title)) ///
	grid(none) ///
    ciopts(recast(rcap)) ///
    scheme(plotplainblind)
    
	
graph export "$path_output/Figures/event_study.png", replace