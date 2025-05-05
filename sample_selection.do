/*==============================================================================
                      3:  Sample Selection
==============================================================================*/

// merge household dataset with child and parents characteristics 

merge 1:m hhid using `child'
	assert _merge==3 
	drop _merge 

merge 1:1 hhid pid using `parents'
	assert _merge!=2
	rename _merge parents_merge
	 
	// check unmatch cases (10 obs) -- mother and father not in the house
	tab mother_in_house if parents_merge==1, m
	tab father_in_house if parents_merge==1, m
	
// order 
order pid- parents_merge, before(hh_income)
 

// generate a cluster id to uniquely map each mother in the dataset 

gen cluster_id = string(hhid) + "-" + string(mother_id)
	label var cluster_id "unique id - mother"
 
 
*_____________________3.1 Father`s status ______________________________________

gen father_status = 1 if employment_status_father==1
	replace father_status= 2 if mi(father_status)
	replace father_status= 3 if father_in_house==0
	label var father_status "status of father"
	
	label define fat_stat_lab 1 "Father status: Employed father in household" 2 "Father status: Unemployed father in household" 3 "Father status: No father in household"
	label values father_status fat_stat_lab

*_____________________3.2 Government transfers__________________________________


gen government_transfers = (social_support_assistance==1 | family_support_12m==1)
	label var government_transfers "Household received government transfer for child or family in last 12 months"
	label values government_transfers yesno
	assert !mi(government_transfers)
	
	

*________________________3.3 Sample formation___________________________________

file open sample_stats using "`results'/sample_stats.txt", write replace
	file write sample_stats _n "***Number of observations" _n

// clean sample
gen insample =1 
	count if !mi(pid)
	file write sample_stats "Children aged 2-4 years:" _tab "`r(N)'" _n
	
	// exclude child with reported disability and functional difficulties
	count if disability_difficulty==1 & insample==1 
	file write sample_stats "Children with medically documented disabilities or functional difficulties:" _tab "`r(N)'" _n
	count if disability_report==1 & functional_diff==0 & insample==1 
	file write sample_stats "--Children with medically documented disabilities:" _tab "`r(N)'" _n
	count if disability_report==0 & functional_diff==1 & insample==1 
	file write sample_stats "--Children with parent-reported functional difficulties:" _tab "`r(N)'" _n
	count if disability_report==1 & functional_diff==1 & insample==1 
	file write sample_stats "--Children with  medically documented disabilities and parent-reported functional difficulties:" _tab "`r(N)'" _n
	
	replace insample=0 if disability_difficulty==1 & insample==1 
	
	// exclude child with cancer or musculoskeletal system disease
	count if inlist(chronic_disease_det, 6, 18) & insample==1 
	file write sample_stats "Children with cancer or a musculoskeletal system disease:" _tab "`r(N)'" _n
	replace insample=0 if inlist(chronic_disease_det, 6, 18) & insample==1 
	
	// report child if there is at least one missing milestone 
	count if (missing_milestone==1 | imputed_word5==1) & insample==1 
	file write sample_stats "--Children with missing data on at least one child development milestone:" _tab "`r(N)'" _n
	
	// report child if there is missing milestone only for five word sentence
	count if (missing_milestone==0 & imputed_word5==1) & insample==1 
	file write sample_stats "--Children with missing data on only five-word sentence:" _tab "`r(N)'" _n
	
	// exclude with missing milestone except five-word sentence
	count if missing_milestone==1  & insample==1 
	file write sample_stats "Children with missing data on at least one child development milestone (except five-word sentence):" _tab "`r(N)'" _n
	replace insample=0 if  missing_milestone==1 & insample==1 
		
	// exclude child if mother is not alive 
	count if mother_alive==0 & insample==1 
	file write sample_stats "Children whose mothers are not alive:" _tab "`r(N)'" _n
	replace insample=0 if mother_alive==0 & insample==1 
	
	//exclude child if mother is not in the household
	count if mother_in_house==0 & insample==1 
	file write sample_stats "Children whose mothers are not in the household:" _tab "`r(N)'" _n _n
	replace insample=0 if mother_in_house==0 & insample==1 
	
	//exclude child if mother is not in the household
	count if imputed_agemonths==1 & insample==1 
	file write sample_stats "Children with implausible age data:" _tab "`r(N)'" _n 
	replace insample=0 if imputed_agemonths==1 & insample==1
	file write sample_stats "Note: The Child Survey reports the child's age, as well as their year, month, and day of birth."  _n
	file write sample_stats "Cases where there is a discrepancy between age (in months) reported in the microdata and the" _n
	file write sample_stats "calculated age (in months) based on the year of birth and month are excluded from the survey."  _n
	file write sample_stats "The start and end dates of the field study are used to calculate the lower and upper bounds of"  _n
	file write sample_stats "the calculated age as the exact interview dates are not reported in the microdata. Cases with a"  _n
	file write sample_stats "reported age outside the lower and upper bounds are excluded from the sample and flagged as implausible."  _n
	
	// total number of child - clean sample
	file write sample_stats  _n "****" _n
	count if insample==1 
	file write sample_stats "Children in the final sample:" _tab "`r(N)'" _n
	file write sample_stats  "****" _n
	
// imputations & winsorization
	file write sample_stats _n "**** Number of observations in the final sample with imputed or winsorized data" _n
	
	//  imputed milestone word5 
	count if imputed_word5==1 & insample==1 
	file write sample_stats "Children with imputed data on a specific milestone: can the child generate a five-word sentence:"  _tab "`r(N)'" _n

	//  imputed health 
	count if imputed_health==1 & insample==1 
	file write sample_stats "Children with imputed data on ongoing chronic disease or illness in the last six months:"  _tab "`r(N)'" _n _n

	//  implausible mother age 
	count if implausible_motherage==1 & insample==1 
	file write sample_stats "Children with imputed data on mother`s age - year of birth (implausible age):"  _tab "`r(N)'" _n 
	file write sample_stats "Note: Mother`s age is defined as implausible [1] if the mother is 15 or more years older than the father"  _n
	file write sample_stats "or [2] the mother`s age at the last birth is more than 54 years. In cases of [1], the mother`s age"  _n
	file write sample_stats "is imputed as the father`s age minus the average age gap of parents. If the age gap between father`s" _n
	file write sample_stats "and the oldest child is less than 15 years, than the mother`s age was accepted as correct and kept as it is." _n
	file write sample_stats "In cases of [2], the mother`s age is winsorized at 54."  _n _n
	
	//  imputed father`s status
	count if imputed_fatheremp==1 & insample==1 
	file write sample_stats "Children with imputed data on father`s status:"  _tab "`r(N)'" _n

	//  imputed government transfers 
	count if (imputed_hhsupport==1 | imputed_familysupport==1) & insample==1 
	file write sample_stats "Children with imputed data on received government transfers:"  _tab "`r(N)'" _n _n

	//  imputed youngest child age 
	count if corrected_youngest==1 & insample==1
	file write sample_stats "Children with imputed data on mother`s youngest child age:"  _tab "`r(N)'" _n
	file write sample_stats "Note: When there is a discrepancy between reported age and year of birth - month data, the start date"  _n
	file write sample_stats "of the field study  and the year of birth - month   were used to compute age of youngest child."  _n _n
	
    // winsorized weight 
	count if abs(z_weight)>5 & insample==1
	file write sample_stats "Children with winsorized weight-for-age z-score:"  _tab "`r(N)'" _n
	file write sample_stats "Note: Winsorization is applied for the cases where the weight exceeds 5 standard deviations from the mean."  _n
	
		* winsorize those with |z|>5 
		gen imputed_waz= (abs(z_weight)>5) // flag winsorized cases 
		replace z_weight=5 if  z_weight>5 & !mi(z_weight)
		replace z_weight=-5 if z_weight<-5 & !mi(z_weight)
		
	file write sample_stats  "****" _n
	


*________________________3.4 Organize variable clusters_________________________

// define heading variables 

gen CHILDOUTCOMES=9999
	label var CHILDOUTCOMES "Child Development Outcome Variables"

gen INTERMED=9999
	label var INTERMED "Child Development Input Variables"
	
gen CHILDVARS=9999
	label var CHILDVARS "Child Variables"
	
gen MOMVARS=9999
	label var MOMVARS "Mother Variables"

gen CONTROLS_HH=9999
	label var CONTROLS_HH "Household Structure Variables"
	
gen CONTROLS_ECON=9999
	label var CONTROLS_ECON "Economic Variables"
		
// create binary variables of categorical controls (for reporting purpose) 

qui tabulate educ_comp_mother, generate(momedu)
   foreach var of varlist momedu* {  // Replace with actual variable names or use wildcard
		local old_label : variable label `var'  
		local new_label = subinstr("`old_label'", "educ_comp_mother==", "", .)  
		label variable `var' "`new_label'"
}
   
qui tabulate breastfeed_cat, generate(breastfeedc)
	
   foreach var of varlist breastfeedc* {  // Replace with actual variable names or use wildcard
		local old_label : variable label `var'  
		local new_label = subinstr("`old_label'", "breastfeed_cat==", "Age stopped breastfeeding: ", .)  
		label variable `var' "`new_label'"
}

   
qui tabulate father_status, generate(fatstat)
    foreach var of varlist fatstat* {  // Replace with actual variable names or use wildcard
		local old_label : variable label `var'  
		local new_label = subinstr("`old_label'", "father_status==", "", .)  
		label variable `var' "`new_label'"
}
   
   
 *________________________3.5 Report sample statistics_________________________
  
// summary statistics for children who were selected for the sample and those who were excluded 

qui orth_out  mother_employed CHILDOUTCOMES achieve_milestone stx_total_milestone weight z_weight health_issue_sr health_issue_lr general_health  INTERMED total_activity_mother current_school  breastfeedc* dieatary_diversity CHILDVARS sex completed_months MOMVARS momedu* age_mother age_atbirth  CONTROLS_HH  age_youngest secondary_caregiver fatstat* grandparent_exist hh_size  CONTROLS_ECON ln_hh_income deprived_monetary deprived_living deprived_educ other_support government_transfers using   "`results'/summary_stats.xlsx",  by(insample) sheet(AX) sheetreplace stars pcompare count armlabel("Not in sample" "In sample") title(Table AX. Summary statistics of children included in the sample vs not in sample) note(Note: Table AX reports the mean values for children who were selected for the sample and those who were excluded due to the specified reason in Section XXX.)


*________________________3.6 Upweighting - survey weights______________________
  
//  conduct logit regression for generating inverse probability weights 

	label var insample " " 
	qui logit insample sex completed_months secondary_caregiver i.father_status  grandparent_exist c.hh_size  c.ln_hh_income  deprived_monetary deprived_living deprived_educ government_transfers other_support,  vce(cluster  cluster_id)
		
		 // predict probabilities 
		predict prob_sample, pr
			assert prob_sample!=. 
			label var prob_sample "probability of being sampled"
		 
			gen inv_p = 1/ prob_sample
				assert !mi(inv_p) 
				label var inv_p  "inverse probability of being sampled"
			
			
		// report margins at mean 
		eststo s1: margins, dydx(*) atmeans post
		esttab s1, cells("b se p")
		

		qui esttab s1 using "`results'\Table_S1.html",  replace  label  nobase alignment(center)  title("Table S1. Logit regression for generating inverse probability weights") cells(b(star fmt(3)) se(par fmt(3)) nolabel) collabels("Included in Sample") starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nonumber note("Note: Table S1 reports the marginal effects at mean along with their corresponding standard errors. Standard errors are clustered at mother level.<br>* p < 0.10, ** p < 0.05, *** p < 0.01<br> <br></body>")  width(50%)   nomtitles    noomitted nodepvars
		


// upweight probabilities for the cases in the analytical sample 
   *Note: upweight the observations that are most similar to the missing observations.
	gen upweight = ind_weight * inv_p
		label var upweight  "survey weight - upweighted"
		assert !mi(upweight) 

		
		
*________________________3.7 Clean sample ______________________________________

// keep only the neccessary variables to conduct the analysis and save 


keep hhid pid mother_id father_id ind_weight upweight inv_p prob_sample weight_hh CHILDOUTCOMES achieve_milestone rob_achieve_milestone total_milestone rob_milestone stx_total_milestone weight z_weight health_issue_sr health_issue_lr general_health general_health MOMVARS mother_employed age_mother age_atbirth educ_comp_mother momedu* CHILDVARS sex completed_months age birth_year INTERMED total_activity_mother current_school dieatary_diversity breastfeed_cat breastfeedc* breastfeed_duration CONTROLS_HH  secondary_caregiver  secondary_caregiver  father_status fatstat* grandparent_exist hh_size age_youngest CONTROLS_ECON ln_hh_income deprived_monetary deprived_living deprived_educ other_support government_transfers one_child  pcincome_2021ppp  hh_income insample cluster_id imputed_waz read_whom story_whom sing_whom outdoor_whom play_whom draw_whom 



// drop unselected cases 
drop if insample==0 	

// identify siblings 
bysort cluster_id: gen sibling_number = _N -1 
	   label var sibling_number "number of sibling in the sample"
gen sibling = sibling_number>=1 & !mi(sibling_number)
	   label var sibling "sibling(s) in the sample"
	   
	file write sample_stats _n "**** Other characteristics" _n _n
	
	// report number of clusters 
	
	preserve
		duplicates drop cluster_id, force 
		count if sibling==1
		file write sample_stats "Number of mothers with multiple children in the sample:"  _tab "`r(N)'" _n

		estpost tab father_status
		local nonwork_spouse = e(pct)[1,2]
		local nothome_spouse = e(pct)[1,3]
		file write sample_stats %7.2f (`nonwork_spouse') "% "   "of mothers in households without fathers work." _n
		file write sample_stats %7.2f (`nothome_spouse') "% "   "of mothers in households where no father is present." _n 
		
		count if !mi(cluster_id)
		file write sample_stats "Number of clusters in the sample :"  _tab "`r(N)'" _n _n

	restore 

	
	// report median household income 
	preserve 
		duplicates drop hhid, force
		_pctile hh_income [pw=weight_hh], p(50)
		file write sample_stats "Median monthly disposable household income (in 2022 prices):"  _tab %7.2f (r(r1)) " TL - " "US$ " %7.2f (r(r1)/16.5) _n
		mean hh_income [pw=weight_hh]
		local mean_inc= r(table)[1,1]
		file write sample_stats "Mean monthly disposable household income (in 2022 prices):"  _tab %7.2f (`mean_inc') " TL - " "US$ " %7.2f (`mean_inc'/16.5) _n 
		file write sample_stats "Mean monthly disposable household income - official:"  _tab "15100 TL - " "US$ " %7.2f (15100/16.5) _n _n
	restore 
	
	

	// report poverty rate 
	preserve 
		duplicates drop hhid, force
		gen weight_pov = weight_hh * hh_size 
		povdeco pcincome_2021ppp [pw=weight_pov], pline(8.30)
		file write sample_stats "International poverty line: US$8.30 (2021ppp) per capita per day (equivalent to 43.24TL in 2022 prices)" _n 
		file write sample_stats "--Poverty rate among individuals living in the sampled households:"  _tab  %7.2f (r(fgt0)*100) "%" _n 
	restore 
	
	preserve 
		povdeco pcincome_2021ppp [pw=upweight], pline(8.30)
		file write sample_stats "--Poverty rate among children aged 2 to 4:"  _tab  %7.2f (r(fgt0)*100) "%" _n 
		file write sample_stats "--National poverty rate based on the international poverty line:"  _tab "10.79%  of population" _n _n
	restore 
	
	file write sample_stats  "****" _n
	

// close the file 
file close sample_stats


// save cleaned data 
save `clean_data', replace 


/*==============================================================================
                             END OF DO FILE
==============================================================================*/




	



		
 


