* ====================================================================
* This script creates the balance table for the control and treatment groups.
* ====================================================================

* Run config file
if "`c(username)'" == "asd890"{
    do "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic/Config/config_stata.do"
}
else{
    error "Username not found"
}

log using "$path_logs/balance_table.log", replace

* Read in data
use "$path_data/Traffic/clean/tti_stations_final.dta", clear
drop if group == 1
replace group = 1 if group == 2

local treatment_2_numeric = date("$treatment_2_date", "YMD")

preserve

* Keep only pre-treatment period (before Dec 10, 2012)
keep if date_num < `treatment_2_numeric'

* Collapse to station-level averages
collapse (mean) tti, by(group station postmile)

* Store results matrix
matrix balance = J(10, 5, .)  // rows, columns
local row = 1


** CREATE BALANCE TABLE
preserve

keep if date_num < `=date("10dec2012", "DMY")'
collapse (mean) tti, by(group station)

* Create output file
file open balance using "$path_overleaf/Tables/balance_table_manual.tex", write replace

* Write header
file write balance "\begin{table}[H]" _n
file write balance "\centering" _n
file write balance "\caption{Balance Table: Pre-Treatment Characteristics (2010-2012)}" _n
file write balance "\begin{adjustbox}{width=0.95\textwidth}" _n
file write balance "\begin{tabular}{lcccc}" _n
file write balance "\toprule" _n
file write balance " & \multicolumn{2}{c}{Mean (SD)} & & \\" _n
file write balance " \cmidrule(lr){2-3}" _n
file write balance "Variable & Treatment & Control & Difference & p-value \\" _n
file write balance " & (Provo-SLC) & (Payson-Provo) & (1)-(2) & \\" _n
file write balance "\midrule" _n
file write balance "\multicolumn{5}{l}{\textit{Panel A: Traffic Characteristics}} \\" _n

* TTI row
quietly summarize tti if group == 1
local mean_t = r(mean)
local sd_t = r(sd)
quietly summarize tti if group == 0
local mean_c = r(mean)
local sd_c = r(sd)
quietly ttest tti, by(group)
local diff = r(mu_1) - r(mu_2)
local se = r(se)
local pval = r(p)

* Determine significance stars
local stars = ""
if `pval' < 0.001 {
    local stars = "***"
}
else if `pval' < 0.05 {
    local stars = "**"
}
else if `pval' < 0.10 {
    local stars = "*"
}

file write balance "Travel Time Index (TTI) & " %9.2f (`mean_t') " & " %9.2f (`mean_c') " & " %9.2f (`diff') " & " %9.2f (`pval') "`stars' \\" _n
file write balance " & (" %9.2f (`sd_t') ") & (" %9.2f (`sd_c') ") & (" %9.3f (`se') ") & \\" _n

* Add more variables here...

file write balance "\midrule" _n
file write balance "Number of Stations & 45 & 28 & & \\" _n
file write balance "\bottomrule" _n
file write balance "\end{tabular}" _n
file write balance "\end{adjustbox}" _n
file write balance "\begin{minipage}[t]{0.95\textwidth}" _n
file write balance "\footnotesize" _n
file write balance "\textit{Notes:} Standard deviations in parentheses under means. " ///
    "Difference column shows treatment minus control with standard error in parentheses. " ///
    "P-values from two-sample t-tests. * p\$<\$0.10, ** p\$<\$0.05, *** p\$<\$0.001." _n
file write balance "\end{minipage}" _n
file write balance "\end{table}" _n

file close balance

restore

preserve

keep if date_num < `=date("10dec2012", "DMY")'
collapse (mean) tti, by(group station)

* Create summary statistics by group
estpost tabstat tti, by(group) statistics(mean sd) columns(statistics) nototal
esttab using "$path_output/Tables/balance_means.tex", ///
    cells("mean(fmt(2)) sd(fmt(2) par)") ///
    noobs nonumber replace

* T-test for differences
estpost ttest tti, by(group) unequal
esttab using "$path_output/Tables/balance_tests.tex", ///
    cells("mu_1(fmt(2)) mu_2(fmt(2)) b(fmt(3) star) se(fmt(3) par)") ///
    star(* 0.10 ** 0.05 *** 0.001) ///
    noobs nonumber replace

restore


* Count number of stations by group
preserve
keep if date_num < `=date("10dec2012", "DMY")'
collapse (mean) tti, by(group station)

tab group
* Or
bysort group: gen n_stations = _N
bysort group: keep if _n == 1
list group n_stations

restore