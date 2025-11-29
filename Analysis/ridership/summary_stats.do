* ====================================================================
* Calculate summary stats for ridership data
* ====================================================================

* Run config file
if "`c(username)'" == "asd890"{
    do "C:/Users/asd890/OneDrive - Harvard University/Desktop/Grad_School/Frontrunner/frontrunner_traffic/Config/config_stata.do"
}
else{
    error "Username not found"
}

log using "$path_logs/summary_stats.log", replace

* Read in data
import delimited using "$path_data/Ridership/importables/ridership_data.csv", clear

* Calculate summary stats
keep if route == "FrontRunner"
keep if year >= 2010
keep if year <= 2020

keep if stopname == "Provo Central Station" | stopname == "Lehi Station" | stopname == "Orem Central Station" | stopname == "American Fork Station" | stopname == "Draper Station" | stopname == "South Jordan Station" | stopname == "Murray Central Station" | stopname == "Salt Lake Central Station" 

sum avgboardings

* Close log file
cap log close