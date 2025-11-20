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
drop if group == 1
replace group = 1 if group == 2

* Very short run
* preserve 
*     keep if date_num >= `=date("10dec2010", "DMY")' & date_num <= `=date("10apr2013", "DMY")'
*     eststo reg_vsr:reghdfe tti ib0.group##post_treatment_2, absorb(station month day_of_week rush_time_f) cluster(group)
*     qui sum tti	if _est_reg_vsr == 1
* 	estadd  local dv_mean 	= string(round(r(mean),0.01),"%9.2f")	: reg_vsr
* restore

* Short run
preserve 
    keep if date_num >= `=date("10dec2010", "DMY")' & date_num <= `=date("10dec2013", "DMY")'
    eststo reg_sr: reghdfe tti ib0.group##post_treatment_2, absorb(station month day_of_week rush_time_f) cluster(group)
    qui sum tti	if _est_reg_sr == 1
	estadd  local dv_mean 	= string(round(r(mean),0.01),"%9.2f")	: reg_sr
restore

* Long run
preserve 
    keep if date_num >= `=date("01jan2010", "DMY")' 
    eststo reg_lr: reghdfe tti ib0.group##post_treatment_2, absorb(station month day_of_week rush_time_f) cluster(group)
    qui sum tti	if _est_reg_lr == 1
	estadd  local dv_mean 	= string(round(r(mean),0.01),"%9.2f")	: reg_lr
restore


******************************** Export Table ********************************** 

	* Export table (Latex) 

	loc numbers	= "& (1) & (2) \\ \midrule"
	
    #delimit ;
	loc note "This table reports results from regressions of a travel time index (TTI) on highway section and period indicators. 
    The control group is the Payson to Provo section of I15, and the treatment group is the Provo to SLC section of I15. We include 
    station, month, day of week, and rush time fixed effects. Standard errors are clustered at the highway section level." ;
    #delimit cr

	loc table_path =  "$path_output/Table/table_1_DD.tex"
	if (${output_overleaf} == 1) {
		loc table_path =  "$path_overleaf/Tables/table_1_DD.tex"
	}
	
	esttab 	reg_sr reg_lr  ///
  	using 	"`table_path'", ///
  			style(tex) cells(b(fmt(3) star) se(par fmt(3)) p(par([ ]) fmt(3))) collabels(none) booktabs ///
            keep(1.post_treatment_2 1.group#1.post_treatment_2) ///
  			varlabels(1.post_treatment_2 "Post Treatment" 1.group#1.post_treatment_2 "Section $\times$ Post Treatment") ///
  			mgroups("Short Run" "Long Run", pattern(1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
  			prehead(`"\begin{table}[H]\centering"' `"\caption{@title}"' `"\begin{adjustbox}{width=1.0\textwidth}"' `"\begin{tabular}{l*{@E}{c}}"' `"\toprule"') ///
  			title("Difference-in-Differences") mlabels(none) nonum posthead("`numbers'") ///
  			postfoot(`"\bottomrule"' `"\end{tabular}"' `"\end{adjustbox}"' `"\begin{minipage}[c][-3ex][t]{\textwidth}"'`"`note' "' `"\end{minipage}"' `"\end{table}"') ///
  			stats(N dv_mean, label("Observations" "DV mean") fmt(%15.0fc %4.2f 0 0)) ///
            replace
			