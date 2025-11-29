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

set 	scheme 	plotplain
graph set print fontface "Times New Roman"

* Read in data
use "$path_data/Traffic/clean/tti_stations_final_collapsed_weekly.dta", clear

* Smooth out results by doing a rolling average with a window of 7 days
tssmooth ma tti_smooth = tti, window($sm_window 1 $sm_window) 
local treatment_1_numeric = date("$treatment_1_date", "YMD")
local treatment_2_numeric = date("$treatment_2_date", "YMD")
local start_date_numeric = date("2010-04-10", "YMD")

display "`treatment_2_numeric'"
display "`start_date_numeric'"

if (${output_overleaf} == 1) {
    local texout = "$path_overleaf/Notes/figure_1_DD_note2.tex"
}
else {
    local texout = "$path_output/figures/figure_1_DD_note2.tex"
}

* Create Note
#delimit ;
file open myfile using "`texout'", write replace;
file write myfile "\begin{flushleft}" _n;
file write myfile "\small" _n;
file write myfile ///
\begin{minipage}[t]{1.0\textwidth} _n
\footnotesize _n
Average Travel Time Index (TTI) by corridor over time. Treatment corridor (Provo to Salt Lake City, green line) and control corridor (Payson to Provo, gray line) show similar pre-treatment trends through late 2012. Vertical dashed line indicates the December 10, 2012 opening of Frontrunner South. Data are collapsed to weekly averages and smoothed using an 8-week moving average to reduce noise. Sample includes weekday rush hour observations from I-15 monitoring stations. _n
\end{minipage} _n
_n;
file write myfile "\end{flushleft}" _n;
file close myfile;
#delimit cr


preserve
    keep if date_num > `start_date_numeric'
    * Plot
    * date_num goes from 17592 to 21916 which is 01mar2008 to 02jan2020. start labels on march 1 2010 and include treatment date as a label 2012-12-10
    graph twoway (line tti_smooth date_num if group == 0, color(gray) lpattern(solid)) ///
                (line tti_smooth date_num if group == 2, color(green) lpattern(solid)) , ///
                legend(label(1 "Payson to Provo (Control)") label(2 "Provo to SLC (Treatment)") pos(6) rows(1) size($graph_legend)) ///
                title("Figure 1: Trends in Travel Time Index by Treatment Group", size($graph_title)) ///
                xtitle("Date", size($graph_xtitle)) xlabel(18362 `"{fontface "Times New Roman": 10/4/2010}"' 19337 `"{fontface "Times New Roman": 10/12/2012}"' 20312 `"{fontface "Times New Roman": 10/8/2016}"' 21287 `"{fontface "Times New Roman": 10/4/2019}"' 21910 `"{fontface "Times New Roman": 01/01/2020}"', labsize($graph_label) angle($graph_angle) nogrid) ///
                ytitle("Time Travel Index", size($graph_ytitle)) ylabel(, labsize($graph_label)) ///
                xline(`treatment_2_numeric', lcolor(red) lpattern(dash))  
restore

graph 	export "$path_output/figures/figure_1_DD_sr2.png", replace width($graph_width) height($graph_height)
if (${output_overleaf} == 1) {
    graph export "$path_overleaf/Figures/figure_1_DD_sr2.png", replace width($graph_width) height($graph_height)
}



********************************************************************************
* Test for pre-treatment differential trends
********************************************************************************

* Test if all pre-treatment coefficients are jointly zero
test 1.group#time_2 1.group#time_3 1.group#time_4 /* ... list all pre-treatment dummies */

* Store p-value
local pretrend_pval = r(p)
display "Pre-trend test p-value: `pretrend_pval'"

* If p > 0.10, parallel trends holds!
if `pretrend_pval' > 0.10 {
    display "✓ Parallel trends assumption satisfied (p = `pretrend_pval')"
}
else {
    display "✗ Warning: Evidence of differential pre-trends (p = `pretrend_pval')"
}


* use "$path_data/Traffic/clean/tti_stations_final_collapsed_control.dta", clear

* * Smooth out results by doing a rolling average with a window of 7 days
* tssmooth ma tti_smooth = tti, window($sm_window 1 $sm_window) 

* local treatment_1_numeric = date("$treatment_1_date", "YMD")
* local treatment_2_numeric = date("$treatment_2_date", "YMD")

* * Plot
* graph twoway (line tti_smooth date_num if group == 0, color(black) lwidth(medium)) ///
*              (line tti_smooth date_num if group == 2, color(blue) lwidth(medium)) , ///
*              legend(label(1 "Control") label(2 "Frontrunner South")) ///
*              xtitle("Date") ytitle("Traffic Congestion Index") ///
*              xline(`treatment_1_numeric', lcolor(green) lpattern(dash))  ///
*              xline(`treatment_2_numeric', lcolor(green) lpattern(dash)) 

* * Save fig to output folder
* graph export "$path_output/figures/DD_fig_2.png", replace


* * use estab and booktabs in tables