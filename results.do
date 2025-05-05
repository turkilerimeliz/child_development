/*==============================================================================
                              5.1: Results - Main
==============================================================================*/

*_________________________5.1.1 Preparation_____________________________________


// clone breastfeeding categories to use them as numeric dependent var in OLS 
clonevar breastfeed_num = breastfeed_cat
	label values breastfeed_num


// rename outcome variable -- for simplicity 
local i=1
foreach var in achieve_milestone stx_total_milestone z_weight health_issue_sr health_issue_lr general_health total_activity_mother current_school  breastfeed_num  dieatary_diversity  rob_achieve_milestone breastfeed_duration{
	rename `var' y`i'
	local i=`i'+1
	
}
 
//cluster dependent and independent variables  -- grouped set of controls. 
local dependent  y1 y2 y3 y4 y5 y6 y7 y8 y9 y10 y11 y12
local interm_var y7 y8 y9 y10 y12

local child   "sex c.completed_months"
local interm  "c.y7 y8 c.y9 c.y10"
local mom     "i.educ_comp_mother c.age_mother c.age_atbirth"
local hhdem   "c.age_youngest secondary_caregiver i.father_status  grandparent_exist c.hh_size"
local hhinc   "c.ln_hh_income  deprived_monetary deprived_living deprived_educ government_transfers other_support"


*__________________________5.1.2 Regressions____________________________________


// open postfile to report regression results 

tempname  posto
tempfile child_o
postfile `posto' str20(outcome) str20(model)  b se z pval ll ul p_adj using `child_o', replace 
 
 
// binary dependent variable (Logit)
 

local i =1
	foreach var in `dependent'{
	
		 qui eststo a`i': regress  `var' mother_employed `child' [pw=upweight],  vce(cluster  cluster_id)
			matrix A = r(table)[1..6,1]'
			post `posto' ("`var'") ("m1")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			
		if !(`: list var in interm_var') {
			
		  qui eststo b`i':regress  `var' mother_employed `child' `interm' [pw=upweight],  vce(cluster  cluster_id)
			matrix A = r(table)[1..6,1]'
			post `posto'("`var'") ("m2")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
		}	 
		 
		  qui eststo c`i': regress  `var' mother_employed `child' `mom' [pw=upweight],  vce(cluster  cluster_id)
			matrix A = r(table)[1..6,1]'
			post `posto'("`var'") ("m3")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			 
		 
		  qui eststo d`i': regress  `var' mother_employed `child' `hhdem' [pw=upweight],  vce(cluster  cluster_id)
			matrix A = r(table)[1..6,1]'
			post `posto'("`var'") ("m4")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			 
		 
		  qui eststo e`i': regress  `var' mother_employed `child' `hhinc' [pw=upweight],  vce(cluster  cluster_id)
			matrix A = r(table)[1..6,1]'
			post `posto'("`var'") ("m5")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			 
		 
		if !(`: list var in interm_var') { 
			  qui eststo f`i':regress  `var' mother_employed `child' `interm' `mom' `hhdem' `hhinc' [pw=upweight],  vce(cluster  cluster_id)
		}
		
		else {
			  qui eststo f`i': regress  `var' mother_employed `child'  `mom' `hhdem' `hhinc' [pw=upweight],  vce(cluster  cluster_id)
		}
		
			matrix A = r(table)[1..6,1]'
			post `posto'("`var'") ("m6")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (.)
			
		
	 local i = `i'+1
	}


postclose `posto'
	
 
 
*________________________5.1.3 Multiple Hypothesis Adjustments__________________ 

// child development outcomes
 
local mcell a b c d e f 

forvalues x=1/6 {
	
	local y: word `x' of `mcell'
	
	if `x'==1 local control `child'
	if `x'==2 local control `child' `interm'
	if `x'==3 local control `child' `mom'
	if `x'==4 local control `child' `hhdem'
	if `x'==5 local control `child' `hhinc'
	if `x'==6 local control `child' `interm' `mom' `hhdem' `hhinc'
	
	
	   
	  wyoung y1 y2 y3 y4 y5 y6, cmd(regress OUTCOMEVAR mother_employed `control' [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
	   
		 
		
	foreach num of numlist 1(1)6 {
		local po`num'_`x' = r(table)[`num',3]
		local pw`num'_`x' = r(table)[`num',4]
		local pb`num'_`x' = r(table)[`num',5]
			
	}
	

	foreach num of numlist 1(1)6 {
		estadd scalar po = `po`num'_`x'' : `y'`num'
		estadd scalar pw = `pw`num'_`x'' : `y'`num'
		estadd scalar pb = `pb`num'_`x'' : `y'`num'
		
		matrix P2= (`pw`num'_`x'')
		mat colnames P2 = "mother_employed" 
		estadd matrix P2 : `y'`num' 
		
		preserve 	 
			use `child_o', clear
				qui replace p_adj= `pw`num'_`x'' if outcome=="y`num'" &  model=="m`x'"
			save `child_o', replace 
		restore
	}
	
	
}

 

// child development inputs  

foreach x in 1 3 4 5 6 {
	
	local y: word `x' of `mcell'
	
	if `x'==1 local control `child'
	if `x'==3 local control `child' `mom'
	if `x'==4 local control `child' `hhdem'
	if `x'==5 local control `child' `hhinc'
	if `x'==6 local control `child' `mom' `hhdem' `hhinc'
	
	    
	   wyoung y7 y8 y9 y10, cmd(regress OUTCOMEVAR mother_employed `control' [pw=upweight], cluster(cluster_id)) cluster(cluster_id) familyp(mother_employed)  bootstraps(100) seed(42)  
	 
		
	foreach num of numlist 7(1)10{
		local t = `num'-6	
		local po`num'_`x' = r(table)[`t',3]
		local pw`num'_`x' = r(table)[`t',4]
		local pb`num'_`x' = r(table)[`t',5]
		
	}
	
	foreach num of numlist 7(1)10 {
		estadd scalar po = `po`num'_`x'' : `y'`num'
		estadd scalar pw = `pw`num'_`x'' : `y'`num'
		estadd scalar pb = `pb`num'_`x'' : `y'`num'
		
		matrix P2= (`pw`num'_`x'')
		mat colnames P2 = "mother_employed" 
		estadd matrix P2 : `y'`num' 
		
		preserve 	 
			use `child_o', clear
				qui replace p_adj= `pw`num'_`x'' if outcome=="y`num'" &  model=="m`x'"
			save `child_o', replace 
		restore
	}
	

}
	 
	

*_________________________5.1.4 Report  Main Results____________________________

	// Report results - child development outcome 
		
	local labtit "`: variable label y1'"	
 
	esttab a1 b1 c1 d1 e1 f1 using "`results'\Table2.csv", replace  prehead("Table 2. Child development outcomes and maternal work" @hline@hline@hline@hline@hline@hline ) cells(b(star fmt(3) pvalue(P2)) se(par fmt(3))  P2(par([ ]) fmt(3)) nolabel) keep(mother_employed) varlabels(mother_employed "`labtit'")  collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01)  nogaps nomtitles noobs nolines nodepvars hlinechar("_")  
	
	forvalues x=2/5{
		
	  local labtit "`: variable label y`x''"
	
			
		esttab a`x' b`x' c`x' d`x' e`x' f`x' using "`results'\Table2.csv", append  cells(b(star fmt(3) pvalue(P2)) se(par fmt(3))   P2(par([ ]) fmt(3)) nolabel) keep(mother_employed) varlabels(mother_employed "`labtit'" )  collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nomtitles noobs  nolines nodepvars  nonumbers 
	}
	
	local labtit "`: variable label y6'"
	esttab a6 b6 c6 d6 e6 f6 using "`results'\Table2.csv", append  cells(b(star fmt(3) pvalue(P2)) se(par fmt(3))  P2(par([ ]) fmt(3)) nolabel) keep(mother_employed)  varlabels(mother_employed "`labtit'" )   collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01)  nogaps nomtitles nolines nodepvars 	nonumbers postfoot(@hline@hline@hline@hline@hline@hline "Note: Table 2 reports the effect of maternal employment on child development outcomes. The positive values indicate the children of working mothers have better outcome. Short-term health and Long-term health are defined as  bivariate variables indicates if the child was free of health problems for the past two weeks or if the child was free of ongoing chronic disease or illness for the last six months. Each column presents estimates from the same baseline model but with different sets of controls. The child's sex and age are controlled for each specification. Column 1 reports baseline model (un-adjusted). Column 2 adds controls related to child development inputs.  Column 3 includes maternal characteristics. Columns 4 and 5 introduce controls for household characteristics and household welfare respectively. Column 6 reports the extended model incorporating all controls and child development inputs. Standards errors clustered at mother level are reported in parentheses. The p-values presented in brackets are adjusted using the Westfall-Young method (Westfall and Young 1993). 100 repetitions are used for bootstrapping." "* p < 0.10 ** p < 0.05 *** p < 0.01" ) hlinechar("_")
	 
	
	 
	 // Report results - child development inputs
 
	local labtit "`: variable label y7'"	
	esttab a7 c7 d7 e7 f7 using "`results'\Table3.csv", replace  prehead("Table 3. Child development inputs and maternal work" @hline@hline@hline@hline@hline@hline) cells(b(star fmt(3)  pvalue(P2)) se(par fmt(3))  P2(par([ ]) fmt(3)) nolabel) keep(mother_employed) varlabels(mother_employed "`labtit'") collabels(none)  starlevels( * 0.10 ** 0.05 *** 0.01)  nogaps nomtitles nolines nodepvars noobs hlinechar("_")  
	
	forvalues x=8/9{
		
		local labtit "`: variable label y`x''"	
		 
		esttab a`x'  c`x' d`x' e`x' f`x' using "`results'\Table3.csv", append  cells(b(star fmt(3)  pvalue(P2)) se(par fmt(3))  P2(par([ ]) fmt(3)) nolabel)  keep(mother_employed)   varlabels(mother_employed "`labtit'" ) collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nomtitles nolines nodepvars noobs	nonumbers
	}
	
		local labtit "`: variable label y10'"	
	esttab a10 c10 d10 e10 f10 using "`results'\Table3.csv", append  cells(b(star fmt(3)  pvalue(P2)) se(par fmt(3))  P2(par([ ]) fmt(3)) nolabel) keep(mother_employed)   varlabels(mother_employed "`labtit'") collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01)   nomtitles nolines nodepvars nonumbers  postfoot(@hline@hline@hline@hline@hline@hline "Note: Table 3 reports the effect of maternal employment on child development inputs. The positive values indicate the children of working mothers have better outcome. Each column presents estimates from the same baseline model but with different sets of controls. The child's sex and age are controlled for each specification. Column 1 reports baseline model (un-adjusted). Column 2 adds controls on maternal characteristics. Columns 3 and 4 introduce controls for household characteristics and household welfare respectively. Column 5 reports the extended model incorporating all controls. The p-values given in brackets are adjusted using the Westfall-Young method (Westfall and Young 1993). 100 repetitions are used for bootstrapping." "* p < 0.10 ** p < 0.05 *** p < 0.01" ) hlinechar("_")
	 
 

*_________________________5.1.5 Report  Appendix Tables_________________________
	
forvalues x=1/10{	
	
	local snum = `x'+2
	local labtit "`: variable label y`x''"
	
	if `x'<=6 {
	esttab a`x' b`x' c`x' d`x' e`x' f`x' using "`results'\Table_S`snum'.html", replace  label  nobase alignment(center)  title("Table S`snum'. Child development outcome: `labtit'") cells(b(star fmt(3)) se(par fmt(3)) nolabel) stats(pw pb r2 N, fmt(%05.3f %05.3f %05.3f %9.0gc) labels("Adjusted p-value (Westfall-Young)" "Bonferroni-Holm p-value" R² Observations)) collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nonote  varwidth(35) width(80%)  drop (_cons) nomtitle noomitted nodepvars note("Note: Table S`snum' presents the results of the specification where the dependent variable is the child development outcome: <i>`labtit'</i>. The positive values indicate the children of working mothers have better outcome. Each column presents estimates from the same baseline model but with different sets of controls. The child's sex and age are controlled for each specification. Column 1 reports baseline model (un-adjusted). Column 2 adds controls related to child development inputs.  Column 3 includes maternal characteristics. Columns 4 and 5 introduce controls for household characteristics and household welfare respectively. Column 6 reports the extended model incorporating all controls and child development inputs. Standard errors are clustered at the mother level. The significance level is reported based on unadjusted p-values. Westfall-Young and Bonferroni-Holm p-values are reported only for the maternal work and  100 repetitions are used for bootstrapping. <br>* p < 0.10, ** p < 0.05, *** p < 0.01<br><br></body>")
	}
		
	
	else{
	esttab a`x'  c`x' d`x' e`x' f`x' using "`results'\Table_S`snum'.html", replace  label  nobase alignment(center)  title("Table S`snum'. Child development input: `labtit'") cells(b(star fmt(3)) se(par fmt(3)) nolabel) stats(pw pb r2 N, fmt(%05.3f %05.3f  %05.3f %9.0gc) labels("Adjusted p-value (Westfall-Young)" "Bonferroni-Holm p-value"  R² Observations)) collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nonote  varwidth(35) width(80%)  drop (_cons) nomtitle noomitted nodepvars note("Note: Table S`snum' presents the results of the specification where the dependent variable is the child development input: <i>`labtit'</i>. The positive values indicate the children of working mothers have better outcome. Each column presents estimates from the same baseline model but with different sets of controls. The child's sex and age are controlled for each specification. Column 1 reports baseline model (un-adjusted). Column 2 adds controls on maternal characteristics. Columns 3 and 4 introduce controls for household characteristics and household welfare respectively. Column 5 reports the extended model incorporating all controls. Standard errors are clustered at the mother level. The significance level is reported based on unadjusted p-values. Westfall-Young and Bonferroni-Holm p-values are reported only for the maternal work and  100 repetitions are used for bootstrapping <br>* p < 0.10, ** p < 0.05, *** p < 0.01<br><br></body>")
		
	}
	
}

*_______________________________5.1.6 Robustness Checks_________________________
	
 local labtit "`: variable label y11'"
 
// [a] Imputation of missing values on 5-word sentence 
esttab a11 b11 c11 d11 e11 f11 using "`results'\Table_S13.html", replace  label  nobase alignment(center) title("Table S13. Child development outcome: `labtit'") cells(b(star fmt(3)) se(par fmt(3)) nolabel) stats( r2 N, fmt( %05.3f %9.0gc) labels(R² Observations)) collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nonote  varwidth(35) width(75%)  drop (_cons) nomtitle noomitted nodepvars note("Note: Table S13 reports the results of the specifications where the dependent variable is the official child development indicator for a slightly different sample. As a robustness check, the missing outcomes of the 5-word sentence are imputed as zero rather than one. The positive values indicate the children of working mothers have better outcome. Each column presents estimates from the same baseline model but with different sets of controls. The child's sex and age are controlled for each specification. Column 1 reports baseline model (un-adjusted). Column 2 adds controls related to child development inputs.  Column 3 includes maternal characteristics. Columns 4 and 5 introduce controls for household characteristics and household welfare respectively. Column 6 reports the extended model incorporating all controls and child development inputs. Standard errors are clustered at the mother level. The significance level is reported based on unadjusted p-valuesStandard errors are clustered at the mother level. The significance level is reported based on unadjusted p-values. Westfall-Young and Bonferroni-Holm p-values are reported only for the maternal work and  100 repetitions are used for bootstrapping. <br>* p < 0.10, ** p < 0.05, *** p < 0.01<br><br></body>")

// [b] Continous breastfeeding duration (in months)


 local labtit "`: variable label y12'"
esttab a12 c12 d12 e12 f12 using "`results'\Table_S14.html", replace  label  nobase alignment(center) title("Table S14. Child development input: `labtit'") cells(b(star fmt(3)) se(par fmt(3)) nolabel) stats( r2 N, fmt( %05.3f %9.0gc) labels(R² Observations)) collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nonote  varwidth(35) width(75%)  drop (_cons) nomtitle noomitted nodepvars note("Note: Table S14 reports the results of the specifications where the dependent variable is age stopped breastfeeding (in months). The positive values indicate the children of working mothers have better outcome. Each column presents estimates from the same baseline model but with different sets of controls. The child's sex and age are controlled for each specification. Column 1 reports baseline model (un-adjusted). Column 2 adds controls on maternal characteristics. Columns 3 and 4 introduce controls for household characteristics and household welfare respectively. Column 5 reports the extended model incorporating all controls. Standard errors are clustered at the mother level. The significance level is reported based on unadjusted p-values. Westfall-Young and Bonferroni-Holm p-values are reported only for the maternal work and  100 repetitions are used for bootstrapping.  <br>* p < 0.10, ** p < 0.05, *** p < 0.01<br><br></body>")


/*==============================================================================
                             END OF DO FILE
==============================================================================*/


 
	
