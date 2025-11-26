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

* Create event time dummies (24 months before to 12 months after)
* Omit month -1 as reference period
forvalues i = 24(-1)2 {
    gen lead`i' = (months_to_treatment == -`i' & group == 1)
}

forvalues i = 0/12 {
    gen lag`i' = (months_to_treatment == `i' & group == 1)
}

* Run event study regression
reghdfe tti lead24-lead2 lag0-lag12, ///
    absorb(station month year day_of_week rush_time_f) ///
    cluster(station)

* Test joint significance of all leads (pre-treatment periods)
test lead24 lead23 lead22 lead21 lead20 lead19 lead18 lead17 lead16 ///
     lead15 lead14 lead13 lead12 lead11 lead10 lead9 lead8 lead7 ///
     lead6 lead5 lead4 lead3 lead2

local pretrend_p = r(p)
display "Pre-trend test p-value: `pretrend_p'"

* Store coefficients for plotting
estimates store event_study

* Plot event study
coefplot event_study, ///
    keep(lead* lag*) ///
    vertical ///
    yline(0, lcolor(red) lpattern(dash)) ///
    xline(23.5, lcolor(black) lpattern(solid)) ///
    ytitle("Effect on TTI") ///
    xtitle("Months Relative to Treatment") ///
    title("Event Study: Frontrunner South Opening") ///
    note("Reference period: Month -1. Treatment occurs at vertical line.") ///
    ciopts(recast(rcap)) ///
    scheme(plotplainblind)
    
graph export "$path_output/Figures/event_study.png", replace