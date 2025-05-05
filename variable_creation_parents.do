/*==============================================================================
                      2.2: Variable creation - Parents
==============================================================================*/

*_____________________2.2.1 Retreive main characteristics_______________________
		
// deploy parenst IDs
use `parents_id', clear 


// restore data on oldest child -- year of birth and age

preserve 
	keep if mother ==1 
	duplicates drop hhid pid, force
	drop child_id 
	rename pid mother_id 
	
	// merge with master dataset to retrieve data on mother`s oldest child
	merge 1:m hhid mother_id using `master', keepusing (pid birth_month birth_year birth_day age completed_months imputed_agemonths)
	keep if _merge==3 // keep only merged 
	
	
	// define year of birth and age -- oldest child 
	sort hhid mother_id 
	egen birth_year_oldest = min(birth_year), by(hhid mother_id) 
	label var birth_year_oldest "Year of birth - mother`s oldest child"
	
	egen birth_year_youngest = max(birth_year), by(hhid mother_id) 
	label var birth_year_youngest "Year of birth - mother`s youngest child"
	
	egen age_oldest = max(completed_months), by(hhid mother_id)
		label var age_oldest "Age of mother's oldest child (in months)"
	
	egen age_youngest = min(completed_months), by(hhid mother_id) 
		label var age_youngest "Age of mother's youngest child (in months)"
		
		// cross check 
		assert birth_year_oldest==birth_year if age_oldest==completed_months
		assert birth_year_youngest==birth_year if age_youngest==completed_months

	// track cases with corrected age in months 	
	gen flag_imp_youngest =  (age_youngest==completed_months & imputed_agemonths==1)
		egen corrected_youngest = max (flag_imp_youngest), by(hhid mother_id)
		label var corrected_youngest "corrected age of youngest child"
		 
    // keep only one record for each mother
	duplicates drop hhid mother_id, force 
	keep hhid mother_id birth_year_oldest birth_year_youngest age_oldest age_youngest corrected_youngest
	gen one_child =(age_oldest==age_youngest)
		label var  one_child "mother has only one child"
		
	
	save `age_children', replace 
restore 


// merge with master dataset to retrieve parental characteristics
	merge m:1 hhid pid using `master', keepusing (gender birth_month birth_year birth_day age imputed_agemonths education completion_status employment_status school_stat literacy_status)
	drop if _merge==2 
	drop _merge 
   
	// rename 
	order child_id, before(pid)
	
	// reshape long to wide 
	reshape wide pid  gender birth_month birth_year birth_day age imputed_agemonths  education completion_status  employment_status school_stat literacy_status, i(hhid child_id) j(mother)

	// rename variables 
	rename *1 *_mother
    rename *0 *_father
    
	// drop unnecessary variables 
	assert gender_father ==1 if !mi(gender_father) 
	assert gender_mother ==2 if !mi(gender_mother) 
	drop gender*

// merge with data on mother`s oldest child 
	rename pid_father father_id
	rename pid_mother mother_id 

    merge  m:1 hhid mother_id using `age_children' 
	
	gen ageyr_oldest = floor(age_oldest / 12)
		lab var ageyr_oldest "Age of the mother's oldest child (in years)"
		assert !mi(ageyr_oldest) if !mi(mother_id)
		
	gen ageyr_youngest = floor(age_youngest / 12)
		lab var ageyr_youngest "Age of the mother's youngest child (in years)"
		assert !mi(ageyr_youngest) if !mi(mother_id)
		
	
// define the gap between mothers and fathers to detect implausible age for mothers

	gen parent_age_gap = age_father - age_mother  if !mi(age_father)
		sum parent_age_gap, d // check median age gap between parents 
	   
	    // create a variable to flag imputed/ winsorized cases 
	    gen implausible_motherage=0
			replace implausible_motherage =1 if parent_age_gap <=-15 & !mi(parent_age_gap)  & age_father >= 15+ageyr_oldest
			label var implausible_motherage "mother`s age is implausible"
			
			*Note:  when age_father <= 15+ageyr_oldest then it is more likely that the father`s age is implausible!
			
	    // impute  mother's age if she is older than the father by 15 years or more. (data error)
		qui sum parent_age_gap, d
		replace age_mother = age_father -`r(p50)' if implausible_motherage==1
		
		// impute mothers` year of birth --> correspondingly (data error)
		replace birth_year_mother = birth_year_father +`r(p50)' if implausible_motherage==1
	 
	 
	    //browse age_mother age_father if  implausible_motherage==1
	
	
// check age at last birth to detect implausible age for mothers

	gen age_at_lastbirth = age_mother - (ageyr_youngest)
		lab var age_at_lastbirth "Maternal age at last birth"
		assert !mi(age_at_lastbirth) if !mi(mother_id)
		
		*Note: one observation with implausible age at last birth 
		//browse if age_at_lastbirth>54
		
		replace implausible_motherage=1 if age_at_lastbirth>54 & !mi(age_at_lastbirth) // flag
		replace age_at_lastbirth=54 if age_at_lastbirth>54 & !mi(age_at_lastbirth)     // winsorize as 54
		replace age_mother=age_at_lastbirth+ageyr_youngest if  age_at_lastbirth==54 & implausible_motherage==1 // recode current age
		replace birth_year_mother= 2022 - age_mother if age_at_lastbirth==54 & implausible_motherage==1 // recode birth year
		
// age at first birth 
gen age_atbirth = age_mother - (ageyr_oldest)
		lab var age_atbirth "Maternal age at first birth"
		assert !mi(age_atbirth) if !mi(mother_id)
		
		//browse one_child age_at_lastbirth age_atbirth age_years_mother birth_year_mother age_years_youngest age_years_oldest if age_at_lastbirth==54 & implausible_motherage==1
		
		
*_____________________________2.2.2 Employment _________________________________	


label define lfs_lab 1 "Employed"  21 "Job seeker" 22 "Continuing education" 23 "Retired-leaving working (age related)" 24"Disabled -unable to work" 25 "Busy with household chores" 27 "Elderly (65+)" 98 "Other"

foreach var in employment_status_mother employment_status_father {
	label values `var' lfs_lab
}
    label var employment_status_mother "Maternal work status - detailed"
    label var employment_status_father "Paternal work status - detailed"

// maternal
gen mother_employed = (employment_status_mother==1) if  !mi(mother_id) & !mi(employment_status_mother)
	label var mother_employed "Maternal work"
	label values mother_employed yesno
	assert !mi(mother_employed) if !mi(mother_id)

 
// paternal
gen father_employed = (employment_status_father==1) if  !mi(father_id) & !mi(employment_status_father)
    label var father_employed "Paternal work"
	label values father_employed yesno
	
	// one missing values 
	gen imputed_fatheremp= 0
		replace imputed_fatheremp = 1 if mi(father_employed) & !mi(father_id)
		label var imputed_fatheremp "paternal work is imputed"
	
	*browse if mi(father_employed) & !mi(father_id)
		 
		tab father_employed // more than 90% of fathers in our sample is employed
		replace father_employed=1 if mi(father_employed) & !mi(father_id)
	
		assert !mi(father_employed) if !mi(father_id)
		
*_____________________________2.2.3 Education___________________________________	


// define label
label define  educ_att_lab 1 "Never attended school"  2 "Primary or less"  3 "Upper secondary" 4 "Tertiary" 99 "Unknown"
label define  educ_comp_lab 1 "Less than primary"  2 "Primary"  3 "Upper secondary" 4 "Tertiary" 99 "Unknown"
label define  educ_comp_labm 1 "Maternal education: Less than primary"  2 "Maternal education: Primary"  3 "Maternal education: Upper secondary" 4 "Maternal education: Tertiary" 99 "Unknown"
foreach x in mother father {
	
	// educational attainment 
	clonevar educ_attend_`x' = education_`x'
		recode educ_attend_`x' (0 2 3 =2) (4=3) (511 512 521 522 53=4) (99=99) // attended school
		replace  educ_attend_`x'= 1 if school_stat_`x'==2  // never attended school
		label values educ_attend_`x'  educ_att_lab
		
	// highest completed education
	clonevar educ_comp_`x' = educ_attend_`x'
		recode educ_comp_`x' (2=1) (3=2) (4=3) if completion_status_`x'==2
		label values educ_comp_`x'  educ_comp_lab
}
	label var educ_attend_mother "Maternal education - attend"
	label var educ_attend_father "Paternal education - attend"

	label var educ_comp_mother "Maternal education"
		label values educ_comp_mother  educ_comp_labm
	label var educ_comp_father "Paternal education"
	
	
		 assert !mi(educ_attend_mother) if !mi(mother_id) // not missing if mother in the hh roster
		 assert !mi(educ_comp_mother) if !mi(mother_id) // not missing if mother in the hh roster
		 
		
*_____________________________2.2.4 Save________________________________________	

// rename (important for the matching)
rename child_id pid
 

// keep relavant variables
keep hhid pid father_id age_father birth_year_father employment_status_father mother_id birth_year_mother age_mother employment_status_mother mother_employed father_employed educ_attend_mother educ_comp_mother educ_attend_father educ_comp_father  age_atbirth birth_year_youngest age_youngest  one_child  corrected_youngest implausible_motherage imputed_fatheremp

// order 
order mother_id birth_year_mother age_mother employment_status_mother mother_employed educ_attend_mother educ_comp_mother implausible_motherage age_atbirth birth_year_youngest age_youngest  corrected_youngest one_child, before(father_id)

// label variables and save

label var hhid "Household id"
label var pid "Personal id"
label var father_id "Father id"
label var mother_id "Mother id"
label var birth_year_father "Father - year of birth"
label var birth_year_mother "Mother - year of birth"
label var age_father "Paternal age"
label var age_mother "Maternal age"

save `parents', replace 

/*==============================================================================
                             END OF DO FILE
==============================================================================*/

