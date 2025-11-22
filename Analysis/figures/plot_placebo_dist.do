*# ====================================================================
* This script plots the distribution of placebo treatment effects for each period.
* ====================================================================

* Run config file
if "`c(username)'" == "asd890"{
    do "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic/Config/config_stata.do"
}
else{
    error "Username not found"
}

log using "$path_logs/plot_placebo_dist.log", replace

* Load placebo coefficients
use "$path_data/Traffic/clean/placebo_coefs.dta", clear

* Label periods
label define period_lbl 1 "Very Short Run" 2 "Short Run" 3 "Long Run"
label values period period_lbl

* Generate period labels for graphs
gen period_str = ""
replace period_str = "Very Short Run" if period == 1
replace period_str = "Short Run" if period == 2


********************************************************************************
* Plot 3: Combined histogram (all periods)
********************************************************************************
histogram coef, by(period, note("") legend(off)) ///
    xline(0, lcolor(red) lpattern(dash)) ///
    frequency ///
    xtitle("Placebo Treatment Effect") ///
    ytitle("Frequency") ///
    title("Distribution of Placebo Treatment Effects") ///
    scheme(plotplainblind)
graph export "$path_output/Figures/placebo_hist_combined.png", replace

********************************************************************************
* Plot 4: Scatter plot with confidence intervals
********************************************************************************
* Sort by coefficient value for cleaner plot
sort period coef

* Generate observation number within period
by period: gen obs_num = _n

* Generate 95% CI (approximate using 1.96 * SE, if you stored SEs)
* If you don't have SEs, skip this part

twoway (scatter coef obs_num if period == 1, mcolor(navy) msize(small)) ///
       (scatter coef obs_num if period == 2, mcolor(cranberry) msize(small)) ///
       (scatter coef obs_num if period == 3, mcolor(forest_green) msize(small)), ///
       yline(0, lcolor(black) lpattern(dash)) ///
       ytitle("Placebo Treatment Effect") ///
       xtitle("") xlabel(none) ///
       title("Placebo Treatment Effects Across All Tests") ///
       legend(order(1 "Very Short Run" 2 "Short Run" 3 "Long Run") rows(1)) ///
       note("Each point represents one placebo test. Dashed line at zero.") ///
       scheme(plotplainblind)
graph export "$path_output/Figures/placebo_scatter.png", replace

********************************************************************************
* Plot 5: Coefficient plot style (stacked dots)
********************************************************************************
preserve
    * Create bins for similar coefficient values
    gen coef_bin = round(coef, 0.01)
    
    * Count observations in each bin by period
    collapse (count) n=coef, by(coef_bin period)
    
    separate n, by(period)
    
    twoway (scatter coef_bin n1, msymbol(o) mcolor(navy%70)) ///
           (scatter coef_bin n2, msymbol(o) mcolor(cranberry%70)) ///
           (scatter coef_bin n3, msymbol(o) mcolor(forest_green%70)), ///
           yline(0, lcolor(black) lpattern(dash)) ///
           ytitle("Placebo Treatment Effect") ///
           xtitle("Frequency") ///
           title("Distribution of Placebo Treatment Effects") ///
           legend(order(1 "Very Short Run" 2 "Short Run" 3 "Long Run") rows(1)) ///
           scheme(plotplainblind)
    graph export "$path_output/Figures/placebo_dotplot.png", replace
restore

********************************************************************************
* Summary statistics table
********************************************************************************
* Calculate summary stats
bysort period: egen mean_coef = mean(coef)
bysort period: egen sd_coef = sd(coef)
bysort period: egen min_coef = min(coef)
bysort period: egen max_coef = max(coef)
bysort period: egen pct_sig = mean(sig)

* Keep one obs per period
keep period mean_coef sd_coef min_coef max_coef pct_sig
duplicates drop

* Format
format mean_coef sd_coef min_coef max_coef %9.3f
f