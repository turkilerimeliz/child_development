/*==============================================================================
                      2.1: Variable creation - Child
==============================================================================*/

// drop unneccessary variables 
drop marital_status spouse_id employment_status completed_age school_stat education completion_status literacy_status school_supplies_assistance conditional_education_assistance  primary_caregiver

// clean the personal weights 
gen ind_weight = subinstr(pers_weight, ",", ".", .)
	destring ind_weight, replace
	format ind_weight %12.6f
	label var ind_weight "Personal weight"

	
// keep only children within a specific age interval (use the original age variable without any correction)
assert age_years!=.
keep if age_years>=`lower' & age_years<=`upper' 
keep if merge_017==3

	// check cases with implausible reported age
	count if imputed_agemonths==1
  
    * total number of child reported as aged 2-4 in the microdata 
    count if merge_017==3
    global number_child_raw = r(N)
	di $number_child_raw

// define age groups 
gen age_groups = 1 if  inrange(completed_months, 24, 29) 
	replace age_groups = 2 if inrange(completed_months, 30, 35)
	replace age_groups = 3 if inrange(completed_months, 36, 41)
	replace age_groups = 4 if inrange(completed_months, 42, 47)
	replace age_groups = 5 if inrange(completed_months, 48, 59)
	replace age_groups=  6 if age_groups==. 
		assert imputed_agemonths==1 if age_groups==6
		label var age_groups "Age groups (6 months interval)"
	
		label define age_gr_lab 1 "24-29 months" 2 "30-35 months" 3 "36-41 months" 4 "42-47 months" 5 "48-59 months" 6 "out of range"
		label values age_groups age_gr_lab
	

// labels for binary indicators
label define yesno 0 "No" 1 "Yes"
label define yesno2 0 " Yes" 1 "No" 
*_____________________2.1.1 Disability of Functional Difficulties_______________
 
   // Functional difficulties 	
	/*
	Functional difficulties are defined as have at least some difficulty or cannot do least one of the following domains: seeing, hearing, walking or having disability report issued by a medical board
	 */
 
 gen functional_diff=0
	foreach var in glasses_diff vision_diff hearing_diff hearing_issue walking_aid_issue {
		//tab `var', m
		replace functional_diff= 1 if inlist(`var', 2, 3, 4)
	}
	
	
	label var functional_diff  "Having a functional difficulties"
	label values disability_report yesno
	assert !inlist(functional_diff, ., 99)
	
	// Reported disability 
	 recode disability_report (2=0) (1=1)  
			label values disability_report yesno	
			assert !inlist(disability_report, ., 99)
			
	 
    // Reported disability or functional difficulties 
	gen disability_difficulty = (functional_diff==1 | disability_report==1)
		label var disability_difficulty  "Having a disability report or functional difficulties"
        assert !inlist(disability_difficulty, ., 99)
		


*_____________________2.1.2 Child Development Outcomes__________________________

// [a] Binary indicators for each milestone 

	// keep a list of related milestones 
	local child_milestone walk jump dress button word word3 word5 pronoun knowname alphabet write count_n count_obj count_err coloring askother helpo getting_well


	// clonevar milestones to create binary variable 
	foreach var in `child_milestone'{
		clonevar milestone_`var'= `var'
		recode milestone_`var' (1=1) (2=0) (99=.)
		tab milestone_`var', m
	}
	
    // a list of binary milestones
	local binary_milestone  // empty local 
	foreach v in  `child_milestone'{
		local binary_milestone "`binary_milestone' milestone_`v'"
	}
	

	// flag observations with at least one missing milestone (except word5)
	gen missing_milestone =0
		label var missing_milestone "at least one milestone missing"
		
	foreach var in `binary_milestone'{
		label values `var' yesno
		if "`var'" != "milestone_word5"{
		replace missing_milestone=1  if `var'==.
			assert missing_milestone==1 if `var'==.
		}
	}

					
********************************************************************************

	// for mileston word5 --> impute missing values 
	* Note: impute missing values as 1 for  milestone word5 --> more than 70% obs achieved this milestone.

	// create a variable to track the imputation
	gen imputed_word5= 0
		replace imputed_word5=1 if milestone_word5==.
		label var imputed_word5 "milestone_word5 is imputed"
			
	replace milestone_word5=1 if mi(milestone_word5)
   
				
********************************************************************************


// [b] Official indicator: child reaches the number of milestones by age 
	   *Note: Only defined if the child is in a specific age interval and has no missing values for binary milestones (except word5)
	   
egen total_milestone = rsum(`binary_milestone') if missing_milestone==0 & age_groups!=6 // total number of milestone 
	assert total_milestone <=18 & !mi(total_milestone) if missing_milestone==0 & age_groups!=6
    label var total_milestone "Total number of achieved milestone"
	
		// robustness check -->  when imputed missing values as 0 for milestone word5 
		clonevar rob_milestone =total_milestone
			replace rob_milestone = total_milestone -1 if imputed_word5==1 & !inlist(total_milestone, 0, .)
			label var rob_milestone "Total number of achieved milestone (robustness check)"
			assert rob_milestone>=0 
			assert mi(rob_milestone) if mi(total_milestone)

	
	// define binary indicator for early childhood development by age groups  
	local c = 1 
	gen achieve_milestone=0 if missing_milestone==0 // empty variable 
		 label var achieve_milestone "Child attains official development standard"

		foreach x in 7 9 11 13 15 {
			replace achieve_milestone=1 if total_milestone >=`x' & age_groups==`c' & !mi(total_milestone)
			
			// cross check 
			qui sum total_milestone if age_groups==`c' & achieve_milestone==1
			assert r(min)>=`x'
			local c = `c'+1
		}
					
			assert !mi(achieve_milestone) if !mi(total_milestone)
			
		// robustness check -->  when imputed missing values as 0 for milestone word5 	
		local c = 1 
		gen rob_achieve_milestone=0 if missing_milestone==0 // empty variable 
			label var rob_achieve_milestone "Child attains official development standard (robustness check)"

		foreach x in 7 9 11 13 15 {
			replace rob_achieve_milestone=1 if rob_milestone >=`x' & age_groups==`c' & !mi(rob_milestone)
			
			// cross check 
			qui sum rob_milestone if age_groups==`c' & rob_achieve_milestone==1
			assert r(min)>=`x'
			local c = `c'+1
		}
		
	  
// [c] Continous value of milestones -- continous standardization by age in months (poly=3)
		*Note: Only defined if the child is in a specific age interval and has no missing values for binary milestones (except word5)
		
	stndzxage total_milestone completed_months, continuous poly(3) 
		 
		assert !mi(stx_total_milestone) if !mi(total_milestone)
		label var stx_total_milestone "Z-score of number of child development milestones" 
		
	
// [d] Weight (WAZ)

 	assert weight!=.  // in kg
	assert height!=.  // in cm 
	gen bmi = weight / ((height/100)^2)
		assert bmi!=.
		label var bmi "BMI index"
		
   	 // WAZ  
	 egen z_weight = zanthro(weight,wa,WHO), xvar(completed_months) gender(gender) gencode(male=1, female=2) ageunit(month) nocutoff   
		label var z_weight "Weight-for-age Z-score"
			count if mi(z_weight) // 1 missing value- completed month is out of range -- not in the main sample.
			assert age_groups ==6  if mi(z_weight)
 
// [e] Ilness and Accident 
    
	// Any health problems in last two weeks
	   recode health_issue_sr (2=1) (1=0) 
			label values health_issue_sr yesno2
			assert !inlist(health_issue_sr, ., 99)
			
		
	// Ongoing chronical disease or ilness in last 6 months 
	 recode health_issue_lr (2=1) (1=0) 
			label values health_issue_lr yesno2
			
		 
		  // create a variable to track the imputation
		  gen imputed_health= 0
			replace imputed_health=1 if inlist(health_issue_lr, ., 99)
			label var imputed_health "long-run health is imputed"
						 
			*tab general_health if health_issue_lr==99 // general health -- medium
			*tab general_health health_issue_lr if general_health==3, cell // 64 % not reporting chronic disease
			replace health_issue_lr=0 if health_issue_lr==99 // recode as 0
			assert !inlist(health_issue_lr, ., 99)

			 
	// General health status 
	 assert !inlist(general_health, ., 99)
		recode general_health (1=1) (2 3 4 5 = 0)
		 label define health 0 "not very good" 1 "very good"  
		 label values general_health health 
		 label var general_health "General health is very good"
 
 
*_____________________2.1.3 Child Development Inputs__________________________
		
 
// [a] Activities with mothers
 
local activity_name read story sing outdoor play draw 
	foreach var in `activity_name'{
		assert !mi(`var'_whom) if `var'_together==1
		recode `var'_whom (1=1) (2 98 .=0)  
}			
			
	// total number of activities with mother 
	egen total_activity_mother = rsum(read_whom story_whom sing_whom outdoor_whom play_whom draw_whom) // total number of activities
		label var total_activity_mother "Index of N activities with mother"
		assert !mi(total_activity_mother)
		
	  
// [b] Preschool participation 

	// currently attending school		
		clonevar current_school= current_school_year_attendance
			assert !inlist(current_school, ., 99)
			recode current_school (2=0) (1=1)
				label values current_school yesno
				assert !mi(current_school)
	 
	// ever attended school
		clonevar ever_school= school_status_0_17 
			recode ever_school (2=0) (1=1)
			replace ever_school =1 if current_school ==1 // if currently attending school -- recode as 1 
			replace ever_school =1 if previous_school_year_attendance ==1  // if attending the school last academic year -- recode as 1 
				
				label values ever_school yesno
				assert !mi(ever_school)
		
				
	// private vs. public school
		label define school_type_lab 1 "Public" 2 "Private"
			label values school_type school_type_lab
			assert !mi(school_type) if current_school==1
			

	// pre-school vs rest
		clonevar school_level = current_education_level
			recode  school_level (0=0) (3=1) (99=99)
			label define school_level_lab 0 "Preschool" 1 "Primary" 99 "Unknown"
			label values school_level school_level_lab
			assert !mi(school_level) if current_school==1	
			
			gen impute_school_lev=(school_level==99)
				lab var impute_school_lev "imputed school level"
			
			assert school_level!=1 if imputed_agemonths!=1 // attending preschool or reported as unknown
			
	// attending to primary school == currently attending school 
		lab var current_school "Preschool attendance"
			
	
// [c] Dietary diversity 

	// create a list to store related variables 
	local dietary fruit_intake vegetable_intake meat_intake legumes_intake animal_product_intake grain_intake

	// define label
	label define dietary_lab 1 "Every day" 2 "Several times a week" 3 "Once a week" 4 "Several times a month" 5 "Once a month" 6 "Several times a year" 7 "Once a year" 8 "Every 2 or more years" 9 "Never"

	// assign labels and create binary indicators -- ==1 if consuming every day 
	foreach v in `dietary'{
		assert !inlist(`v', ., 99)   // assert missing or unknown values 
		label values `v' dietary_lab 
		
		gen bin_`v'= (`v'==1) // assign binary variables 
		label var bin_`v' "binary - `v'"
	}
	
	// joint index -- dieatary diversity 
	egen dieatary_diversity = rsum(bin*)
		assert !mi(dieatary_diversity)
		assert dieatary_diversity<=6 // number of distinct food groups
		label var dieatary_diversity "Dietary diversity"

		 

// [d] Breastfeeding 

    // ever breastfeeding 
	clonevar ever_breastfeeding = breastfeed
		recode ever_breastfeeding (2=0) (1=1)
		assert !inlist(ever_breastfeeding, ., 99)
		label values ever_breastfeeding yesno
		
 
	// continous to be breastfed  -- only defined if ever breasfeeding
	recode breastfeed_cont (2=0) (1=1)
		assert !inlist(breastfeed_cont, ., 99) if ever_breastfeeding==1
		label values breastfeed_cont yesno
	
	// age stop breasfeeding
	assert mi(breastfeed_duration) if breastfeed_cont==1 // only defined if it is stopped
	
	
	// breastfeeding - categorical 
	label define breastfeed_cat_lab 1 "less than 6 months" 2 "6 to 11 months" 3 "12 to 17 months" 4 "18 to 23 months" 5 "24 months or more"
	
	gen breastfeed_cat = 1 if breastfeed_duration <6 & !mi(breastfeed_duration)
		replace breastfeed_cat = 2 if inrange(breastfeed_duration, 6, 11) & !mi(breastfeed_duration)
		replace breastfeed_cat = 3 if inrange(breastfeed_duration, 12, 17)  & !mi(breastfeed_duration)
		replace breastfeed_cat = 4 if inrange(breastfeed_duration, 18, 23)  & !mi(breastfeed_duration)
		replace breastfeed_cat = 5 if  breastfeed_duration>=24 & !mi(breastfeed_duration)
		
			// still breasfeeding
			replace breastfeed_cat = 5 if breastfeed_cont==1
			// never breasfeeding
			replace breastfeed_cat = 1 if ever_breastfeeding==0
			
			label var breastfeed_cat "Age stopped breastfeeding (6-month intervals)"
			label values breastfeed_cat breastfeed_cat_lab
			assert !mi(breastfeed_cat)
		

			//define breasfeeding duration --> for categories still or never  breasfeeding (robustness check)
			replace breastfeed_duration=0 if ever_breastfeeding==0
			replace breastfeed_duration= completed_months if breastfeed_cont==1 // winsorize based on current age (88 obs)
			assert !mi(breastfeed_duration)
		
*________________________2.1.4 Caregiver________________________________________

// primary caregiver 	
label define care_lab 1 "Mother" 2 "Father" 3 "Sister" 4 "Brother" 5 "Grandfather" 6 "Grandmother" 7 "Another relative" 8 "Sitter" 9 "Neighbor" 98 "Other"
		label values caregiver_relationship care_lab
		assert !inlist(caregiver_relationship, ., 99)
		
// secondary caregiver 	
label define sec_care_lab 1 "Father" 2 "Grandparents" 3 "Rest" 4 "No one" 
		// existence
		recode secondary_caregiver (2=0) (1=1)  
			label values secondary_caregiver 	
			label values secondary_caregiver yesno
			assert !inlist(secondary_caregiver, ., 99)
		
		
	     // one case with mother as secondary caregiver -- replace as father 
		 
		 *browse hhid pid mother_id father_id caregiver_id caregiver_relationship secondary_caregiver_rel if  secondary_caregiver_rel==1 & caregiver_relationship==2
			 replace caregiver_id = mother_id if secondary_caregiver_rel==1 & caregiver_relationship==2 // replace id 
			 replace caregiver_relationship =1 if secondary_caregiver_rel==1 & caregiver_relationship==2 // replace relationship - primary
			 replace secondary_caregiver_rel=2 if secondary_caregiver_rel==1 & caregiver_relationship==1 // replace relationship - secondary
			
			// relationship with child
		recode secondary_caregiver_rel (2=1) (5 6 =2) (else=3)
			replace secondary_caregiver_rel=4 if secondary_caregiver==0
		label values secondary_caregiver_rel sec_care_lab
			assert !inlist(secondary_caregiver_rel, ., 99)  
	
	   

*_____________________2.1.5 Identify Parents___________________________________
	
// mother is alive 
	recode mother_alive (1=1) (2=0)
		label values mother_alive yesno
		assert !inlist(mother_alive,., 99)
				 
	
// mother in  hh 
	recode mother_in_house (1=1) (2=0)
		label values mother_in_house yesno
		assert !inlist(mother_in_house,., 99) if mother_alive==1		
 
// restore household id and parents` IDs

preserve
	keep hhid pid mother_id father_id  // keep related variables 
	rename mother_id id1 // rename to make process easier
	rename father_id id0
	reshape long id, i(hhid pid) j(mother) // reshape wide to long 
		rename pid child_id
		rename id pid
		order pid, before(child_id)
	drop if pid ==.  // given parent does not appear in the roster (168 obs)
	save `parents_id', replace 
restore 
		
// restore housheold IDs and relationship to respondent
preserve
	keep hhid pid relationship mother_id father_id	
	save `relationship', replace 
	
	drop pid relationship mother_id father_id	
	duplicates drop hhid, force
	save `household_id', replace 
	
restore 

*________________________________2.1.6 Save_____________________________________
				
// drop unnecessary variables  and re-order
drop current_school_year_attendance school_dropout_reason current_education_level school_type previous_school_year_attendance previous_education_level school_status_0_17 dropout_reason_0_17 education_level_0_17 merge_017 breastfeed left_alone left_under_supervision *together  `child_milestone' health_complaint  chronic_daily glasses glasses_diff vision_diff hearing_aid hearing_diff hearing_issue walking_aid walking_diff walking_aid_issue fruit_intake vegetable_intake meat_intake legumes_intake animal_product_intake grain_intake snack_intake softdrink_intake sweets_intake pers_weight 


// order
order ind_weight- school_level, before(relationship)
order  weight height health_issue_sr health_issue_lr disability_report general_health sleeping, before(bmi)
order breastfeed_cont breastfeed_duration, after(ever_breastfeeding)

// recode 
foreach var in   father_alive father_in_house social_support_assistance  outside_household{
	recode `var' (2=0) (1=1) 
	label values `var' yesno
}

clonevar sex=gender 
	recode sex (1=0) (2=1)
	label var sex "Sex: female"

save `child', replace 	


/*==============================================================================
                             END OF DO FILE
==============================================================================*/

