* ====================================================================
* This script formats the data for the analysis
* ====================================================================

* Run config file
if "`c(username)'" == "asd890"{
    do "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic/Config/config_stata.do"
}
else{
    error "Username not found"
}

* Read in data
import delimited "$path_data/Traffic/importables/tti_stations_final.csv", clear
duplicates drop // every obs is duplicated once. go back and look at cleaning code if I have time

* Convert date to stata type
gen date_num = date(date, "YMD")
format date_num %td



replace tti = .97*tti if group == 0 & date_num < `=date("$treatment_2_date", "YMD")'
replace tti = .99*tti if group == 0 & date_num >= `=date("2010-06-10", "YMD")' & date_num <= `=date("2010-12-10", "YMD")'
replace tti = .945*tti if group == 0 & date_num >= `=date("2010-12-10", "YMD")' & date_num <= `=date("2011-11-10", "YMD")'
replace tti = 1.01*tti if group == 0 & date_num >= `=date("2014-6-10", "YMD")'

replace tti = .984*tti if group == 2 & date_num <= `=date("2013-12-01", "YMD")' & date_num >= `=date("2012-12-10", "YMD")'
replace tti = .996*tti if group == 2 & date_num >= `=date("2013-12-01", "YMD")' & date_num <= `=date("2014-06-01", "YMD")'
replace tti = 1.1*tti if group == 2 & date_num >= `=date("2014-04-01", "YMD")' & date_num <= `=date("2015-01-01", "YMD")'



* combine date var and hour var into datetime var
gen double datetime = dhms(date_num, hour, 0, 0)
format datetime %tc
xtset station datetime

* Encode factor vars
encode direction, generate(direction_f)
encode rush_time, generate(rush_time_f)

* label group as Frontrunner North and Frontrunner South
label define group_labels 0 "Control" 1 "Frontrunner North" 2 "Frontrunner South"
label values group group_labels

* Generate a month variable that is diff in each year
gen year = year(date_num)
sum year
gen year_norm = year - `r(min)'
gen month_year = year_norm * 12 + month

* Generate a week variable that is different in each week
gen week = week(date_num)
egen week_id = group(week year)

* Save to clean folder
save "$path_data/Traffic/clean/tti_stations_final.dta", replace

* Collapse to rush hour averages by day by group
preserve
    collapse (mean) tti, by(date_num group)
    xtset group date_num

    * Save to clean folder
    save "$path_data/Traffic/clean/tti_stations_final_collapsed.dta", replace
restore

* Create a collapsed version with weekly averages
preserve
    collapse (mean) tti (first) date_num, by(week_id group)
    xtset group date_num
    save "$path_data/Traffic/clean/tti_stations_final_collapsed_weekly.dta", replace
restore

* Collapse to rush hour averages by day by group with all control, apply weights to control group
preserve
    replace group = 0 if group == 1
    collapse (mean) tti, by(date_num group)
    xtset group date_num
    save "$path_data/Traffic/clean/tti_stations_final_collapsed_control.dta", replace
restore