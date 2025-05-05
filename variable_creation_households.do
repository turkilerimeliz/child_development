/*==============================================================================
                      2.3: Variable creation - Households
==============================================================================*/

// deploy household-level data
use `hh_master', clear

	//merge with household IDs from child dataset 
	merge 1:1 hhid using `household_id'
	assert _merge!=2
	keep if _merge==3 // only keep households where the children in our dataset belong
	drop _merge
	
	// clean the household weights 
	gen weight_hh = subinstr(hh_weight, ",", ".", .)
		destring weight_hh, replace
		format weight_hh %12.6f
		label var weight_hh "Household weight"
	

*_____________________2.3.1 Household Income ___________________________________

// cross check for missing  hh income and negative values 
assert !mi(hh_income)
assert hh_income >0 

// per capita hh income 
gen pcincome = hh_income/hh_size 

// monthly household income -log scale 
gen ln_hh_income=ln(hh_income)
label var ln_hh_income "Monthly household income (log)"
 
// per capita hh income 
local icp2021 = 3.02327227592468
local cpi2021 = 1.723088359891210


	gen pcincome_2021ppp = pcincome/ `icp2021' / `cpi2021'   // convert 2021ppp USD
		replace pcincome_2021ppp = pcincome_2021ppp/30.4167 // convert daily income
		
		assert !mi(pcincome_2021ppp)
		label var pcincome_2021ppp "Per capita per day household income (2021ppp USD)"

		*browse hh_income hh_size pcincome pcincome_2021ppp 

*_____________________2.3.2 Government Transfers________________________________

// transfers 

foreach v in family_aid housing_aid health_aid {
	assert !mi(`v') // no missing values 
}

egen hh_social_support = rowmin(housing_aid health_aid)
	
	* check cases reported as unknown 
	gen imputed_hhsupport = 0
		replace imputed_hhsupport=1 if hh_social_support == 99
		label var imputed_hhsupport "HH support is imputed"
	
	replace hh_social_support= 2 if hh_social_support==99 // more than 67 percent not receiving transfers-- assume not-receiving tranfers
		
		recode hh_social_support (1=1) (2=0)
		label define yesno 0 "No" 1 "Yes"
		label values hh_social_support yesno
		label var hh_social_support "HH received aid for housing or health"
		assert !mi(hh_social_support)
	
	
// other transfers in the last 12 months 
egen other_support = rowmin(housing_aid_12m health_aid_12m )
	recode other_support (1=1) (2=0)
		replace other_support = 0 if hh_social_support==0
		assert !mi(other_support)
		label values other_support yesno
		label var other_support "Household received aid for housing or health in last 12 months "
		label values hh_social_support yesno	
		
// family aid 
	recode family_aid (2=0) (1=1)
	
	    *check cases reported as unknown
		gen imputed_familysupport = 0
			replace imputed_familysupport=1 if family_aid == 99
			label var imputed_familysupport "family aid is imputed"
	
		
		replace family_aid= 0 if family_aid==99 //more than 72 percent not receiving family aid--> assume not-receiving family_aid
			label var family_aid "Household received family aid" 
			rename family_aid family_support
			label values family_support yesno
		
		//family aid in last 12 months 
		recode family_aid_12m (1=1) (2=0)
			label values family_aid_12m yesno
			label var family_aid_12m "Household received aid for family in last 12 months" 
		    rename family_aid_12m family_support_12m
			
	
*_____________________2.3.3 Multidimensional poverty____________________________

// monetary poverty 
gen deprived_monetary = pcincome_2021ppp<8.30 
	label var deprived_monetary "Deprived household: Monetary" 
	

// deprivation in living standards 

foreach var in sanitary_inside_hh sanitary_outside_hh leaking_roof damping_wall_floor rot_window_floor{
	recode `var' (1=1) (2=0)
	assert !inlist(`var', ., 99)
}
    * assumption: unimproved saniation facility if the toilet is only outside the hh
    gen inadequate_sanitation = (sanitary_outside_hh==1 & sanitary_inside_hh ==0)
		label var inadequate_sanitation "HH has unimproved sanitation facility" 
		label values inadequate_sanitation yesno
		
	gen inadequate_housing = (leaking_roof + damping_wall_floor + rot_window_floor)>=1
		label var inadequate_housing "HH has inadequate housing materials in any of three components: floor, roof or walls" 
		label values inadequate_housing yesno
		
	gen deprived_living = (inadequate_housing+inadequate_sanitation)>=1
		label var deprived_living "Deprived household: Living standards" 
		label values deprived_living yesno
		
		
// deprivation in education 

 preserve
	use `master', replace 
	
	/// deprivation based on education level:
		
		 // highest educational attainment - among hh adults 
		 * hh adults: (18+ or between 15-17 but no-one is responsible from them)
		 
		 assert !mi(school_stat) if age_years>=18  // no missing values for 18+
		 assert !mi(education) if school_stat==1  & age_years>=18 // no missing values for 18+ if ever attending school
		 
		 clonevar educ_attainment = education
			replace educ_attainment = 0 if school_stat==2 
			recode educ_attainment (0 2 =1) (3=2) (4=3) (511 512 521 522 53=4) (99=.) // attended school 
			
		 // highest completed education - among hh adults 
		 clonevar educ_comp = educ_attainment
			recode educ_comp (2=1) (3=2) (4=3) if completion_status==2
		 
		 // highest completed education among hh adults  
		 egen hh_highest_educ = max(educ_comp), by(hhid)
				 assert !mi(hh_highest_educ)
				 
		 // check whether there exist 15-17 years old child completed more than primary education
		 
		     // attendance and education -- current year 
			 assert !mi(current_school_year_attendance) if inrange(age_years, 15, 17) & merge_017==3 // no missing values for child ages 15 and 17 who part of the survey sample
			 assert !mi(current_education_level) if inrange(age_years, 15, 17) & merge_017==3 & current_school_year_attendance ==1 // no missin values 
				 
				gen highschool_1517 = (inlist(current_education_level, 4, 511, 512)) if inrange(age_years, 15, 17) & !mi(current_education_level) // current academic year 
			 
			 // attendance and education -- previous year 
			 assert !mi(previous_school_year_attendance) if inrange(age_years, 15, 17) & merge_017==3 // no missing values for child ages 15 and 17 who part of the survey sample
			 assert !mi(previous_education_level) if inrange(age_years, 15, 17) & merge_017==3 & previous_school_year_attendance ==1 // no missin values 
		
				replace highschool_1517 = 1 if previous_education_level==4 & highschool_1517==. // previous academic year 
		
		  // there exist at least one child (15-17 years old) who completed primary education or more 
		  egen hh_highschool_1517 = max(highschool_1517), by(hhid)
			
			  // flag households which deprived in education based on education level 
			  gen deprived_educ_level = hh_highest_educ<2 // no hh adults completed primary education 
			  
					replace deprived_educ_level=0 if hh_highschool_1517==1 // replace if there is at least one child aged 15-17 who completed primary education 
					label var deprived_educ_level "Household is deprived based on education level"
					assert !mi(deprived_educ_level)
	
	
	/// deprivation based on school attendance:
	
          // check school attendance for child ages 6 to 14
		  assert  !mi(current_school_year_attendance) if inrange(age_years, 6, 14) & merge_017==3 // no missing values for child ages 6 and 14 who part of the survey sample
		  
		  recode current_school_year_attendance (1=1) (2=0)
			clonevar schooling_age_atten = current_school_year_attendance  if inrange(age_years, 6, 14)
				// hh level indicator --> whether all school age children are attending a school
				egen attended_all = min(schooling_age_atten), by(hhid)
					assert !mi(attended_all) if merge_017==3 & inrange(age_years, 6, 14)
					label var attended_all "All school age chidren in the hh are attending a school"
	 
				// flag households which deprived in education based on school attendance 
				gen deprived_educ_attend = (attended_all==0) 
				label var deprived_educ_attend "Household is deprived based on school attendance"
				assert !mi(deprived_educ_attend)
				
	/// deprived based on education 
		gen deprived_educ = (deprived_educ_attend==1 | deprived_educ_level==1)
			label var deprived_educ "Deprived household: Education"
				assert !mi(deprived_educ)
					
	// keep relevant variables and save
	keep hhid deprived_educ_attend deprived_educ_level deprived_educ
	duplicates drop hhid, force
	save `hh_educ', replace 
	
restore 


// merge with hh-educational deprivation 
merge 1:1 hhid using `hh_educ'
	assert _merge!=1
	keep if _merge==3 
	drop _merge 

*_____________________2.3.4 Grandparents presence______________________________

preserve 
	// keep relevant variables to re-store grandparents presence 
	keep hhid respondent_id 

	// merge with children`s relationship status to household respondent 
	merge 1:m hhid using `relationship'
		assert _merge==3
		drop _merge 
		
	/* 
		Child`s relationship with household respondent 
		3 -- son daughter  
		5 -- grandchild 
		10 -- nephew  
		19-- spouse`s sibling child  
		96 -- other relative 
		*/ 
		
	// generate a key variable to match with grandparents presence 
	gen relation_check = 67 if relationship ==3         // parents or parents in law of household respondent
		replace relation_check = 1 if relationship ==5  // household respondent itself 
		replace relation_check = 6 if relationship ==10 // mother/father of household respondent
		replace relation_check = 7 if relationship ==19 // mother/father in law of household respondent
		replace relation_check = 0 if relationship ==96 // not possible to match
		
		*Check cases where the relationship is 10 or 19 to see if the respondent also has their own child in the household.
		egen own_child = min(relationship), by(hhid respondent_id)
			foreach x in 10 19{
				replace relation_check=67 if own_child==3 & relationship==`x'
			}
			drop own_child  


	// keep relavant variables 
	keep hhid respondent_id relation_check
	duplicates drop hhid, force 


	// merge with master dataset to restore IDs of family members 
	merge 1:m hhid using `master', keepusing(pid relationship)
		assert _merge!=1
		keep if _merge==3 // keep only household roster of the households in our sample
		drop _merge 
		
	// identify grandparents in the roster 
	gen grandparent_check= (relation_check ==67 & inlist(relationship, 6, 7))
		replace grandparent_check =1 if relation_check==relationship
		assert grandparent_check==0 if relation_check==0

	// create household level indicator for the existence of grandparents 
	sort hhid pid 
	egen grandparent_exist = max(grandparent_check), by (hhid)
		label var grandparent_exist "Presence of grandparents in household"
		label values grandparent_exist yesno
		
		// keep unique obs for each household
		duplicates drop hhid, force 
		keep hhid grandparent_exist 

	// save 
	save `grandparent', replace 

restore 


*_________________________________2.3.5 Merge______+____________________________

// merge with grandparent dataset 
merge 1:1 hhid using `grandparent'
	assert _merge!=1
	assert _merge==3
	drop _merge 
	
	
// drop and order
	drop *aid *aid_12m sanitary_inside_hh sanitary_outside_hh leaking_roof damping_wall_floor rot_window_floor pcincome hh_weight
    order family_support - grandparent_exist, after(hhid)
	
	
// keep relevant variables and save 
save `household', replace 


/*==============================================================================
                             END OF DO FILE
==============================================================================*/


