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

log using "$path_logs/placebo.log", replace

* Read in data
use "$path_data/Traffic/clean/tti_stations_final.dta", clear
drop if group == 1
replace group = 1 if group == 2

* Set random seed
set seed 12345

* Generate placebo treatment variables if date is greater than a randomely selected date
sum date_num
local min_date = `r(min)'
local max_date = `r(max)'

forvalues i = 1/ $num_placebo_tests {
    * randomly select a date between min_date and max_date
    local random_date = floor(uniform() * (`max_date' - `min_date' + 1) + `min_date')
    gen treatment_placebo_`i' = 0
    replace treatment_placebo_`i' = 1 if date_num >= `random_date'


    * Very short run
    preserve 
        keep if date_num >= `=date("10dec2010", "DMY")' & date_num <= `=date("10apr2013", "DMY")'
        eststo reg_vsr_`i': reghdfe tti ib0.group##treatment_placebo_`i', absorb(station month day_of_week rush_time_f) cluster(group)
        qui sum tti	if _est_reg_vsr_`i' == 1
        estadd  local dv_mean 	= string(round(r(mean),0.01),"%9.2f")	: reg_vsr_`i'
    restore

    * Short run
    preserve 
        keep if date_num >= `=date("10dec2010", "DMY")' & date_num <= `=date("10dec2013", "DMY")'
        eststo reg_sr_`i': reghdfe tti ib0.group##treatment_placebo_`i', absorb(station month day_of_week rush_time_f) cluster(group)
        qui sum tti	if _est_reg_sr_`i' == 1
        estadd  local dv_mean 	= string(round(r(mean),0.01),"%9.2f")	: reg_sr_`i'
    restore

    * Long run
    preserve 
        keep if date_num >= `=date("01jan2010", "DMY")' 
        eststo reg_lr_`i': reghdfe tti ib0.group##treatment_placebo_`i', absorb(station month day_of_week rush_time_f) cluster(group)
        qui sum tti	if _est_reg_lr_`i' == 1
        estadd  local dv_mean 	= string(round(r(mean),0.01),"%9.2f")	: reg_lr_`i'
    restore
}


* Extract all coefficients and p-values
local num_coefs = $num_placebo_tests * 3

matrix coefs = J(`num_coefs', 4, .)  // coefficient, p-value, period indicator, placebo number
local row = 1

foreach period in vsr sr lr {
    local period_num = cond("`period'"=="vsr", 1, cond("`period'"=="sr", 2, 3))
    
    forvalues i = 1/ $num_placebo_tests {
        capture {
            qui est restore reg_`period'_`i'
            matrix coefs[`row', 1] = _b[1.group#1.treatment_placebo_`i']
            test 1.group#1.treatment_placebo_`i' = 0
            matrix coefs[`row', 2] = r(p)
            matrix coefs[`row', 3] = `period_num'
            matrix coefs[`row', 4] = `i'
            local row = `row' + 1
        }
    }
}

* Create dataset and plot
preserve
    
clear

svmat coefs, names(col)
rename c1 coef
rename c2 pval
rename c3 period
rename c4 placebo_round

* Dropping all regs for each placebo test with any missing vals
* drop if missing(coef) | missing(pval)
* duplicates tag placebo_round, gen(dup)
* drop if dup != 2

* Dropping only placebo tests with missing vals
drop if missing(coef) | missing(pval)

gen sig = pval < 0.01

save "$path_data/Traffic/clean/placebo_coefs.dta", replace
restore

cap log close