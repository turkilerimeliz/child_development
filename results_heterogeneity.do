/*==============================================================================
                          5.3: Results - Heterogeneities
==============================================================================*/

// drop stored estimates -- already reported 
est drop _all


// open postfile to report regression results 

tempname  posth
tempfile child_h
postfile `posth' str20(outcome) str20(model) str20(group)  b se z pval ll ul p_adj using `child_h', replace 
 
//set of controls 
local control_common   "c.age_mother c.age_atbirth c.age_youngest  secondary_caregiver  c.hh_size  c.ln_hh_income  deprived_monetary deprived_living deprived_educ government_transfers other_support"


*___________________________5.3.1 Grandparent presence__________________________


local i =1
foreach var in `dependent'{
	
		forvalues y=0/1{
	
			if !(`: list var in interm_var') { 
				   eststo G`i'_`y':regress  `var' mother_employed sex c.completed_months `control_common' `interm'  i.educ_comp_mother  i.father_status  [pw=upweight] if grandparent_exist==`y',  vce(cluster  cluster_id)
			}
			
			else {
				   eststo G`i'_`y': regress  `var' mother_employed sex c.completed_months `control_common'  i.educ_comp_mother  i.father_status  [pw=upweight] if grandparent_exist==`y',  vce(cluster  cluster_id)
			}
			
				matrix A = r(table)[1..6,1]'
				post `posth'("`var'") ("grandpa") ("`y'") (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
				
			
		}
		
	 local i = `i'+1
	}
	
*___________________________5.3.2 Maternal education____________________________


local i =1
foreach var in `dependent'{
	
		forvalues y=1/4{
	
			if !(`: list var in interm_var') { 
				   eststo E`i'_`y':regress  `var' mother_employed sex c.completed_months `control_common' `interm'  grandparent_exist  i.father_status  [pw=upweight] if educ_comp_mother==`y',  vce(cluster  cluster_id)
			}
			
			else {
				   eststo E`i'_`y': regress  `var' mother_employed sex c.completed_months `control_common'  grandparent_exist  i.father_status  [pw=upweight] if educ_comp_mother==`y',  vce(cluster  cluster_id)
			}
			
				matrix A = r(table)[1..6,1]'
				post `posth'("`var'") ("momeduc") ("`y'") (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			
		}
		
	 local i = `i'+1
	}
	

*____________________________5.3.3 Child sex____________________________________

	
local i =1
foreach var in `dependent'{
	
		forvalues y=0/1{
	
			if !(`: list var in interm_var') { 
				   eststo S`i'_`y':regress  `var' mother_employed  c.completed_months `control_common' `interm'  grandparent_exist i.educ_comp_mother  i.father_status  [pw=upweight] if sex==`y',  vce(cluster  cluster_id)
			}
			
			else {
				   eststo S`i'_`y': regress  `var' mother_employed  c.completed_months `control_common'  grandparent_exist i.educ_comp_mother  i.father_status  [pw=upweight] if sex==`y',  vce(cluster  cluster_id)
			}
			
				matrix A = r(table)[1..6,1]'
				post `posth'("`var'") ("sex") ("`y'") (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			
		}
		
	 local i = `i'+1
	}	
	
	
*___________________________5.3.4 Child age_____________________________________


local i =1
foreach var in `dependent'{
	
		forvalues y=2/4{
	
			if !(`: list var in interm_var') { 
				   eststo A`i'_`y':regress  `var' mother_employed sex  `control_common' `interm'  grandparent_exist i.educ_comp_mother  i.father_status  [pw=upweight] if age==`y',  vce(cluster  cluster_id)
			}
			
			else {
				   eststo A`i'_`y': regress  `var' mother_employed sex  `control_common'  grandparent_exist i.educ_comp_mother  i.father_status  [pw=upweight] if age==`y',  vce(cluster  cluster_id)
			}
			
				matrix A = r(table)[1..6,1]'
				post `posth'("`var'") ("age") ("`y'") (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			
		}
		
	 local i = `i'+1
	}		
	
*___________________________5.3.5 Father status_________________________________
	
local i =1
foreach var in `dependent'{
	
		forvalues y=1/3{
	
			if !(`: list var in interm_var') { 
				   eststo F`i'_`y':regress  `var' mother_employed  sex c.completed_months  `control_common' `interm'  grandparent_exist i.educ_comp_mother   [pw=upweight] if father_status==`y',  vce(cluster  cluster_id)
			}
			
			else {
				   eststo F`i'_`y': regress  `var' mother_employed sex c.completed_months  `control_common'  grandparent_exist i.educ_comp_mother    [pw=upweight] if father_status==`y',  vce(cluster  cluster_id)
			}
			
				matrix A = r(table)[1..6,1]'
				post `posth'("`var'") ("father") ("`y'") (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			
		}
		
	 local i = `i'+1
	}		
	
*_______________________________________________________________________________
		
// close postfile 

postclose `posth'
	
*_______________________5.3.6 Multiple Hypothesis Adjustments___________________


foreach var in  grandparent_exist  educ_comp_mother  sex  age father_status {
  levelsof 	`var', local(groups)
  
  
   if "`var'" == "grandparent_exist" {
  	local model_name "grandpa" 
	local collec "G"
  }
  
  if "`var'" == "educ_comp_mother" {
  	local model_name "momeduc" 
	local collec "E"
  }
  
  if "`var'" == "sex" {
  	local model_name "sex" 
	local collec "S"
  }
  
   if "`var'" == "age" {
  	local model_name "age" 
	local collec "A"
  }
  
  if "`var'" == "father_status" {
  	local model_name "father" 
	local collec "F"
  }
   
  
  foreach y in `groups' {
  	
	di "currently run for `var': `y'" 
 	
	  preserve 
		  keep if `var'==`y'
		  
		  if "`var'" == "grandparent_exist" {
		  wyoung y1 y2 y3 y4 y5 y6, cmd(regress OUTCOMEVAR mother_employed sex c.completed_months `control_common' `interm'  i.educ_comp_mother  i.father_status [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
		  
		  if "`var'" == "educ_comp_mother" {
		  wyoung y1 y2 y3 y4 y5 y6, cmd(regress OUTCOMEVAR mother_employed sex c.completed_months `control_common' `interm'  grandparent_exist i.father_status [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
		  
		  if "`var'" == "sex" {
			wyoung y1 y2 y3 y4 y5 y6, cmd(regress OUTCOMEVAR mother_employed  c.completed_months `control_common' `interm'  grandparent_exist i.educ_comp_mother  i.father_status [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
			   
			   
		if "`var'" == "age" {
		  wyoung y1 y2 y3 y4 y5 y6, cmd(regress OUTCOMEVAR mother_employed sex  `control_common' `interm'  grandparent_exist i.educ_comp_mother i.father_status [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
		  
		 if "`var'" == "father_status" {
		  wyoung y1 y2 y3 y4 y5 y6, cmd(regress OUTCOMEVAR mother_employed sex c.completed_months `control_common' `interm'  grandparent_exist i.educ_comp_mother  [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
		  
		  foreach num of numlist 1(1)6 {
				local po`num'_`y' = r(table)[`num',3]
				local pw`num'_`y' = r(table)[`num',4]
				local pb`num'_`y' = r(table)[`num',5]
					
			}
			
		  if "`var'" == "grandparent_exist" {
		  wyoung y7 y8 y9 y10, cmd(regress OUTCOMEVAR mother_employed sex c.completed_months `control_common'   i.educ_comp_mother  i.father_status [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
		  
		  if "`var'" == "educ_comp_mother" {
		  wyoung y7 y8 y9 y10, cmd(regress OUTCOMEVAR mother_employed sex c.completed_months `control_common'   grandparent_exist i.father_status [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
		  
		  if "`var'" == "sex" {
			wyoung y7 y8 y9 y10, cmd(regress OUTCOMEVAR mother_employed  c.completed_months `control_common'   grandparent_exist i.educ_comp_mother  i.father_status [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
			   
			   
		if "`var'" == "age" {
		  wyoung y7 y8 y9 y10, cmd(regress OUTCOMEVAR mother_employed sex  `control_common'   grandparent_exist i.educ_comp_mother i.father_status [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
		  
		 if "`var'" == "father_status" {
		  wyoung y7 y8 y9 y10, cmd(regress OUTCOMEVAR mother_employed sex c.completed_months `control_common'   grandparent_exist i.educ_comp_mother  [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
		  }
		
		 foreach num of numlist 7(1)10{
			local t = `num'-6	
			local po`num'_`y' = r(table)[`t',3]
			local pw`num'_`y' = r(table)[`t',4]
			local pb`num'_`y' = r(table)[`t',5]
			
		}
			
		  foreach num of numlist 1(1)10 {
				estadd scalar po = `po`num'_`y'' : `collec'`num'_`y'
				estadd scalar pw = `pw`num'_`y'' : `collec'`num'_`y'
				estadd scalar pb = `pb`num'_`y'' : `collec'`num'_`y'
				
				matrix P2= (`pw`num'_`y'')
				mat colnames P2 = "mother_employed" 
				estadd matrix P2 : `collec'`num'_`y'	
			}
		
	 restore 
 
 preserve 
	use `child_h', clear
		foreach num of numlist 1(1)10 {
			qui replace p_adj= `pw`num'_`y'' if outcome=="y`num'" &  model=="`model_name'" & group=="`y'"
		}
	save `child_h', replace 
	
 restore

 }

} 
 
 
*____________________________5.3.7 Report Results ______________________________

	
	 label define grandpa_lab 0 "Grandparent: not in household" 1 "Grandparent: in household"
	 label values grandparent_exist grandpa_lab
	 
	 label define sex_lab 0 "Sex: male" 1 "Sex: female"
	 label values  sex sex_lab
	  
	 label define age_lab 2 "Age:2" 3 "Age:3" 4 "Age:4"
	 label values age age_lab
	
	
	local cell G E S A F 
	
	local x=1
	foreach var in grandparent_exist educ_comp_mother  sex  age father_status{
		
		local lblname : value label `var'  
				
		levelsof 	`var', local(groups)
		local z: word `x' of `cell'
		
		foreach y in `groups' {
			
			local lbl : label `lblname' `y'
			local lbl = substr("`lbl'", strpos("`lbl'", ".")+1, .)

			if `x'==1 & `y'==0 {
				esttab  `z'1_`y' `z'2_`y' `z'3_`y' `z'4_`y' `z'5_`y' `z'6_`y' `z'7_`y' `z'8_`y' `z'9_`y' `z'10_`y' using "`results'\Table4.csv", replace  prehead("Table 4. Heterogeneity" @hline@hline@hline@hline ) cells(b(star fmt(3) pvalue(P2)) se(par fmt(3))  P2(par([ ]) fmt(3)) nolabel) keep(mother_employed) varlabels(mother_employed "`lbl'" )  collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01)  nogaps nomtitles noobs nolines nodepvars hlinechar("_")  	
			}
			
			
			else if `x'==5 & `y'==3 {
				esttab  `z'1_`y' `z'2_`y' `z'3_`y' `z'4_`y' `z'5_`y' `z'6_`y' `z'7_`y' `z'8_`y' `z'9_`y' `z'10_`y'  using "`results'\Table4.csv", append  cells(b(star fmt(3) pvalue(P2)) se(par fmt(3))  P2(par([ ]) fmt(3)) nolabel) keep(mother_employed)  varlabels(mother_employed "`lbl'" )   collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01)  nogaps nomtitles nolines nodepvars noobs 	nonumbers postfoot(@hline@hline@hline@hline "Note: Table 4 reports the effect of maternal employment on child development outcomes and inputs across different subsamples. Standards errors clustered at mother level are reported in parentheses. The p-values given in brackets are adjusted using the Westfall-Young method (Westfall and Young 1993)." "* p < 0.10 ** p < 0.05 *** p < 0.01" ) hlinechar("_")
			}
	
			else{
				esttab `z'1_`y' `z'2_`y' `z'3_`y' `z'4_`y' `z'5_`y' `z'6_`y' `z'7_`y' `z'8_`y' `z'9_`y' `z'10_`y' using "`results'\Table4.csv", append  cells(b(star fmt(3) pvalue(P2)) se(par fmt(3))   P2(par([ ]) fmt(3)) nolabel) keep(mother_employed) varlabels(mother_employed "`lbl'" )  collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nomtitles noobs  nolines nodepvars  nonumbers 
			}
			
		}
		
	 local x= `x'+1	
	}
		
		
	
 

/*==============================================================================
                             END OF DO FILE
==============================================================================*/


 
	
