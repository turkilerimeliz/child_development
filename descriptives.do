/*==============================================================================
                         4: Descriptives (Stats. and Figures)
==============================================================================*/

*_______________________4.1 Descriptive Stats __________________________________

// report summary statistics of children whose mothers work and who don't work (Table 1)

qui orth_out  mother_employed CHILDOUTCOMES achieve_milestone stx_total_milestone weight z_weight health_issue_sr health_issue_lr general_health INTERMED total_activity_mother current_school  breastfeedc* dieatary_diversity CHILDVARS sex completed_months MOMVARS momedu*  age_mother age_atbirth   CONTROLS_HH  age_youngest secondary_caregiver fatstat* grandparent_exist hh_size  CONTROLS_ECON ln_hh_income deprived_monetary deprived_living deprived_educ other_support government_transfers  using "`results'\summary_stats.xlsx",  by(mother_employed)  sheet(1) sheetreplace  pcompare stars overall count armlabel("Not working" "Working")title(Table 1. Summary statistics of children in the analytical sample) note(Note: Table 1 reports the mean values for children in the analytical sample, disaggregated by the mother's employment status and overall. p-values are also reported to indicate whether the means differ by the mother's working status.)


// Logit regression - control variables on maternal work 
preserve 
	duplicates drop cluster_id, force 
		label var mother_employed " "
	
	
	logit mother_employed i.educ_comp_mother  c.age_mother c.age_atbirth c.age_youngest  secondary_caregiver i.father_status  grandparent_exist c.hh_size c.ln_hh_income   [pweight=weight_hh],   robust
	
		// report margins at mean 
		eststo s2: margins, dydx(*) atmeans post
		esttab s2, cells("b se p")
			
	
	
	qui esttab s2 using "`results'\Table_S2.html",   replace label nobase  alignment(center)  title("Table S2. Logit regression - control variables on maternal work")  cells(b(star fmt(3)) se(par fmt(3)) nolabel) collabels("Maternal Work") starlevels( * 0.10 ** 0.05 *** 0.01) nogaps note("Note: Table S2 reports the marginal effects at mean along with the robust standard errors.<br>* p < 0.10, ** p < 0.05, *** p < 0.01<br> <br></body>")  width(50%)   nomtitles nonumber  noomitted nodepvars
	
	 
restore 


*_______________________4.2 Descriptive Figures_________________________________

preserve  	

keep if completed_months == age_youngest  // keep if a given child is the youngest child in the family

count if completed_months!=.
local N=r(N)

// Figure 1 - Maternal work (%) by age of the youngest child 

mylabels 0(10)50, myscale(@/100) local(fig1_lab)
twoway lpolyci mother_employed completed_months [aw=upweight], degree(3)    ///
		ylabel(`fig1_lab',  labsize(medsmall) format(%3.0f)) ///
		xlabel(24(6)60, angle(0) nogrid labsize(medsmall)) ///
		title("{bf:Figure 1}. Maternal work by age of child") ///
		subtitle("Children in analytical sample who are the mother's youngest child", size(medsmall)) ///
		graphregion(color(white)) ///
		ytitle("Maternal work (%)", size(medium)) ///
		xtitle("Age of child (in months)", size(medium))  ///
		legend(order(1 "95% CI" 2 "polyfit") position(4) ring(0) ///
		symxsize(3) symysize(3) keygap(1) region(fcolor(gs15) lcolor(none) lwidth(0.2))) ///
		note("The estimated percentages are smoothed approximations obtained using a local" ///
		"polynomial of age of youngest child with order 3. N =`N'.", size(small)) ///
		name(F1) 
		graph export "`figures'\Fig_1.png", replace 
         


// Figure 2 - Preschool attendance (%) by age of child
mylabels 0(20)100, myscale(@/100) local(fig2_lab)
twoway lpolyci current_school completed_months [aw=upweight], degree(3)    ///
		ylabel(`fig2_lab',  labsize(medsmall) format(%3.0f)) ///
		xlabel(24(6)60, angle(0) nogrid labsize(medsmall)) ///
		title("{bf:Figure 2}. Preschool attendance by age of child") ///
		subtitle("Children in analytical sample who are the mother's youngest child", size(medsmall)) ///
		graphregion(color(white)) ///
		ytitle("Preschool attendance (%)", size(medium)) ///
		xtitle("Age of child (in months)", size(medium))  ///
		legend(order(1 "95% CI" 2 "polyfit") position(4) ring(0) ///
		symxsize(3) symysize(3) keygap(1) region(fcolor(gs15) lcolor(none) lwidth(0.2))) ///
		note("The estimated percentages are smoothed approximations obtained using a local" "polynomial of age with order 3. N =`N'.", size(small)) ///
		name(F2) 
		graph export "`figures'\Fig_2.png", replace 
        
restore 



preserve 	 
// Figure S1 - # number of milestone 
drop stx_total_milestone // re-apply standardization just to produce graph 
stndzxage total_milestone completed_months, continuous poly(3) graph
	
	gr_edit plotregion1.graph1.yaxis1.title.text = {"Number of milestones"}
	gr_edit plotregion1.graph2.yaxis1.title.text = {"Z-score (# of milestones)"}
	gr_edit plotregion1.graph1.xaxis1.title.text = {"Age in months"}
	gr_edit plotregion1.graph2.xaxis1.title.text = {"Age in months"}
	gr_edit .caption.text = {"The means are smoothed approximations using a continuous polynomial of age."}
	gr_edit .title.text = {"{bf:Figure S1}. Number of milestones by age (raw and standardized)"}
	graph export "`figures'\Fig_S1.png", replace 
	
drop stx_total_milestone // drop the re-produced version
		
// Figure S3  - WAZ score by household income 
twoway (scatter z_weight ln_hh_income [aw=upweight], mcolor(stc1) msymbol(O) msize(vtiny))  ///
       (lfit z_weight ln_hh_income [aw=upweight], lcolor(stc2) lwidth(medium)), ///
       xtitle("Monthly household income (log)", size(small)) ytitle("WAZ score", size(small))  ///
	   ylabel(-5(2.5)5 ) legend(order(1 "individual scores" 2 "linear fit")  position(4) ring(0) /// 
	   symxsize(3) symysize(3) keygap(1) region(fcolor(gs15) lcolor(none) lwidth(0.2))  size(vsmall)) ///
	    title("{bf:Figure S3}. WAZ score by household income", size(medsmall)) ///
	   xsize(6.5) ysize(5)  aspect(0.8) scale(1.1) name(S3)
	   graph export "`figures'\Fig_S3.png", replace 
	 
	 
 
// Figure S2 - Weight by Age 

**# Add a code chunk to produce weighted means #1
 
drop if imputed_waz==1 // do not include winsorized cases 
egen  mean_weight =  mean(weight), by(completed_months)

twoway (scatter weight completed_months [aw=upweight], mcolor(stc1) msymbol(O) msize(vtiny)) ///
       (scatter mean_weight completed_months, mcolor(stc2) msymbol(O) msize(tiny)), ///
       xtitle("Age in months", size(small)) ytitle("Weight (kg)", size(small)) legend(order(1 "individual scores" 2 "means") ///
	   position(4) ring(0) symxsize(3) symysize(3) keygap(1) region(fcolor(gs15) lcolor(none) lwidth(0.2)) ///
	   size(vsmall))  title("{bf:Figure S2}. Weight by age", size(medsmall)) ///
	   xsize(6.5) ysize(5)  aspect(0.8) scale(1.1)  name(S2)
	   graph export "`figures'\Fig_S2.png", replace 
	   
	   
restore 

/*==============================================================================
                             END OF DO FILE
==============================================================================*/
		

 
 