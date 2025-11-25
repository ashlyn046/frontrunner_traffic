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

set 	scheme 	plotplain
graph set print fontface "Times New Roman"

* Load placebo coefficients
use "$path_data/Traffic/clean/placebo_coefs_pre_final.dta", clear

* Label periods
label define period_lbl 1 "Very Short Run" 2 "Short Run" 3 "Long Run"
label values period period_lbl

* Generate period labels for graphs
gen period_str = ""
replace period_str = "Very Short Run" if period == 1
replace period_str = "Short Run" if period == 2
replace period_str = "Long Run" if period == 3

********************************************************************************
* Plot each distribution as histogram
********************************************************************************

forvalues i = 1/3 {
    preserve
        keep if period == `i'
        twoway (histogram coef, frequency bin(40) color(green)), ///
                xline(${out_`i'}, lcolor(gray) lpattern(dash)) ///
                xtitle("Placebo Treatment Effect", size($graph_xtitle)) ///
                title("Distribution of Placebo Treatment Effects in the `period_str'", size($graph_title))
        graph export "$path_output/figures/placebo_hist_`i'.png", replace width($graph_width) height($graph_height)
        if (${output_overleaf} == 1) {
            graph export "$path_overleaf/Figures/placebo_hist_`i'.png", replace width($graph_width) height($graph_height)
        }
    restore
}


********************************************************************************
* Create a table with percent of placebo tests that are significant at each significance level
********************************************************************************

* Gen sig level dumies from pval
gen sig1 = pval < 0.001
gen sig2 = pval < 0.01 & pval >= 0.001
gen sig3 = pval < 0.05 & pval >= 0.01

* Sort by period and take mean of sig 1 sig 2 and sig 3 to get percent sig levels for each period and make a table
tabstat sig1 sig2 sig3, by(period) statistics(mean) save

* Store results
matrix pct_sig = r(StatTotal)'

* Convert to percentages
matrix pct_sig = pct_sig * 100

* Display
matrix list pct_sig

********************************************************************************
* Create table
********************************************************************************
preserve
    collapse (mean) sig1 sig2 sig3, by(period)
    
    * Convert to percentages
    replace sig1 = sig1 * 100
    replace sig2 = sig2 * 100
    replace sig3 = sig3 * 100
    
    * Export
    listtex period sig1 sig2 sig3 using "$path_overleaf/Tables/sig_levels.tex", ///
        replace rstyle(tabular) ///
        head("\begin{table}[H]\centering" ///
             "\caption{Significance Levels of Placebo Tests by Period}" ///
             "\begin{tabular}{lccc}" ///
             "\toprule" ///
             "Period & p$<$0.10 (\%) & p$<$0.05 (\%) & p$<$0.01 (\%) \\ \midrule") ///
        foot("\bottomrule" ///
             "\end{tabular}" ///
             "\begin{minipage}[t]{0.8\textwidth}" ///
             "\footnotesize Notes: Percentage of placebo tests significant at each level. " ///
             "Under random assignment, we expect approximately 10\%, 5\%, and 1\% respectively." ///
             "\end{minipage}" ///
             "\end{table}")
restore

cap log close