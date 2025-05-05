 /*==============================================================================
                           6: Figures
==============================================================================*/
use `child_o', clear 
 
clonevar outcome_lab = outcome 

// restore original variable names
local i=1
foreach var in achieve_milestone stx_total_milestone z_weight health_issue_sr health_issue_lr general_health total_activity_mother current_school  breastfeed_num  dieatary_diversity rob_achieve_milestone breastfeed_duration {
	replace outcome_lab="`var'"  if outcome== "y`i'" 
	local i=`i'+1
	
}

// re-estimate confidence intervals based on adjusted p-values 

gen z_adj = invnorm(1 - (p_adj / 2))
	replace z_adj = 10 if p_adj==0  & b>0 // set a very high z value
	replace z_adj =-10 if p_adj==0  & b<0 // set a very high z value
	replace z_adj = invnorm(1-(0.999/2)) if p_adj==1
	
gen se_adj = abs(b / z_adj)
gen ll_adj = b - (1.96*se_adj)
gen ul_adj = b + (1.96*se_adj)

	replace ll_adj = -0.6 if  ll_adj<-0.6 | ll_adj==.
	replace ul_adj = 0.6 if ul_adj==. | ul_adj>0.6 
 

 
// define order variable to report different models at the same figure 
gen ord=.
forvalues i=1/6{
	replace ord=`i' if model=="m`i'"
}


  
*_______________________6.1 Child development outcomes__________________________

preserve

local subf a b c d e f 
forvalues i=1/6{			
	
		local y: word `i' of `subf'
		
		if `i'==1 local labtit "Child attains official development standard"
		if `i'==2 local labtit "Z-score (number of milestones)"
		if `i'==3 local labtit "Weight-for-age Z-score"
		if `i'==4 local labtit "Short-term health (over the past two weeks)"
		if `i'==5 local labtit "Long-term health (last six months)"
		if `i'==6 local labtit "General health is very good"
		
		
		
twoway (bar b ord if outcome == "y`i'",  color(ltblue) barwidth(0.6)) (rcap ul_adj ll_adj ord  if outcome == "y`i'", color(maroon) lwidth(thin)), ///
		xlabel(1 "Un-adjusted" 2 "Child Development Inputs" 3 "Mother Characteristics" 4 "Household Structure" 5 "Economic Variables" 6 "All & Development Inputs" , angle(35) labsize(small) gstyle(major) glwidth(thin)) ///
		graphregion(fcolor(white) color(white)) bgcolor(white)  ///
		ylabel(-0.6(0.3)0.6, labsize(*.7) gstyle(major) glwidth(thin) ) ///
		xtitle("") ///
		title("`y'. `labtit'", size(medsmall)) ///
		text(-.58  5.8 "*", color(maroon) placement(c) size(small)) ///
		legend(off) xsize(5) ysize(5)  ///
		name(fig`i'_1, replace)
		
twoway (bar b ord if outcome == "y`i'",  color(ltblue) barwidth(0.6)) (rcap ul ll ord  if outcome == "y`i'", color(maroon) lwidth(thin)), ///
		xlabel(1 "Un-adjusted" 2 "Child Development Inputs" 3 "Mother Characteristics" 4 "Household Structure" 5 "Economic Variables" 6 "All & Development Inputs" , angle(35) labsize(small) gstyle(major) glwidth(thin)) ///
		graphregion(fcolor(white) color(white)) bgcolor(white)  ///
		ylabel(-0.6(0.3)0.6, labsize(*.7) gstyle(major) glwidth(thin) ) ///
		xtitle("") ///
		title("`y'. `labtit'", size(medsmall)) ///
		legend(off)  xsize(5) ysize(5) ///
		name(fig`i'_2, replace)
		
}
		
		graph combine fig1_1 fig2_1 fig3_1 fig4_1 fig5_1 fig6_1, ///
		plotregion(icolor(white)) graphregion(fcolor(white) color(white)) ///
		title("{bf:Figure 3}. Children of working mothers compared to children of non-working mothers", size(medsmall))  ///
		subtitle("Differences in means", size(small)) ///
		cols(3) xsize(15) ysize(9) imargin(0 0 0 0) ///
		caption("Positive values indicate the children of working mothers have better outcomes." ///
		        "95% percent confidence intervals are estimated using adjusted p-values, with 100 bootstrap repetitions." ///
			    "All models include child sex and age." ///
			    "Numeric estimates found in Table 1." ///
				"*The upper and lower limits of the confidence intervals are constrained between -0.6 and 0.6", size(vsmall))
				 
		graph export "`figures'\Fig_3.png", replace 
		
		
	
		graph combine fig1_2 fig2_2 fig3_2 fig4_2 fig5_2 fig6_2, ///
		plotregion(icolor(white)) graphregion(fcolor(white) color(white)) ///
		title("{bf:Figure S4}. Children of working mothers compared to children of non-working mothers", size(medsmall))  ///
		subtitle("Differences in means", size(small)) ///
		t2title("Wtithout p-value adjustments for multiple Hypothesis testing", size(small)) ///
		cols(3) xsize(15) ysize(9) imargin(0 0 0 0) ///
		caption("Positive values indicate the children of working mothers have better outcomes." ///
				"95% percent confidence intervals are reported along with mean differences." ///
			    "All models include child sex and age." ///
			    "Numeric estimates found in Tables S3-S8.",  size(vsmall))
		graph export "`figures'\Fig_S4.png", replace 
		
*_______________________6.2 Child development inputs____________________________
		
	

replace ord= ord-1 if ord!=1	
forvalues i=7/10{				
	
		local x= `i'-6
		local y: word `x' of `subf'
		
		if `i'==7 local labtit  "Index of N activities with mother"
		if `i'==8 local labtit  "Preschool attendence"
		if `i'==9 local labtit  "Age stopped breastfeeding"
		if `i'==10 local labtit "Dietary diversity"
		
		
	
	twoway (bar b ord if outcome == "y`i'",  color(ltblue) barwidth(0.6)) (rcap ul_adj ll_adj ord  if outcome == "y`i'", color(maroon) lwidth(thin)), ///
			xlabel(1 "Un-adjusted" 2 "Mother Characteristics" 3 "Household Structure" 4 "Economic Variables" 5 "All Controls", angle(35) labsize(small) gstyle(major) glwidth(thin) ) ///
			graphregion(fcolor(white) color(white)) bgcolor(white)  ///
			ylabel(-0.6(0.3)0.6, labsize(*.7) gstyle(major) glwidth(thin) ) ///
			xtitle("") ///
			title("`y'. `labtit'", size(medsmall)) ///
			text(-.58 4.8 "*", color(maroon) placement(c) size(small)) ///
			legend(off)   xsize(4) ysize(4) ///
			name(fig`i'_1, replace)
			
	twoway (bar b ord if outcome == "y`i'",  color(ltblue) barwidth(0.6)) (rcap ul ll ord  if outcome == "y`i'", color(maroon) lwidth(thin)), ///
			xlabel(1 "Un-adjusted" 2 "Mother Characteristics" 3 "Household Structure" 4 "Economic Variables" 5 "All Controls", angle(35) labsize(small) gstyle(major) glwidth(thin)) ///
			graphregion(fcolor(white) color(white)) bgcolor(white)  ///
			ylabel(-0.6(0.3)0.6, labsize(*.7) gstyle(major) glwidth(thin) ) ///
			xtitle("")  ///
			title("`y'. `labtit'", size(medsmall)) ///
			legend(off)  xsize(4) ysize(4) ///
			name(fig`i'_2, replace)
	}
restore 
	 
		graph combine fig7_1 fig8_1 fig9_1 fig10_1, ///
		plotregion(icolor(white)) graphregion(fcolor(white) color(white)) ///
		title("{bf:Figure 4}. Children of working mothers compared to children of non-working mothers", size(medsmall)) ///
		subtitle("Differences in means", size(small)) ///
		cols(2) xsize(20) ysize(15) imargin(2 2 2 2) ///
		caption("Positive values indicate the children of working mothers have better outcomes." ///
				"95% percent confidence intervals are estimated using adjusted p-values, with 100 bootstrap repetitions." ///
			    "All models include child sex and age." ///
			    "Numeric estimates found in Table 2." ///
				"*The upper and lower limits of the confidence intervals are constrained between -0.6 and 0.6", size(vsmall))
		graph export "`figures'\Fig_4.png", replace 
		
		graph combine fig7_2 fig8_2 fig9_2 fig10_2, ///
		plotregion(icolor(white)) graphregion(fcolor(white) color(white)) ///
		title("{bf:Figure S5}. Children of working mothers compared to children of non-working mothers", size(medsmall)) ///
		subtitle("Differences in means", size(small)) ///
		t2title("Without p-value adjustments for multiple Hypothesis testing", size(small)) ///
		cols(2) xsize(21) ysize(16) imargin(2 2 2 2)  ///
		caption("Positive values indicate the children of working mothers have better outcomes." ///
				"95% percent confidence intervals are reported along with mean differences." ///
			    "All models include child sex and age." ///
			    "Numeric estimates found in Tables S9-S12.", size(vsmall))
		graph export "`figures'\Fig_S5.png", replace 
	  
 
// save as a dta file
drop z_adj se_adj 
save "`dataout'\Regressions.dta", replace

	 
*_______________________6.3 Activity with mother________________________________
			
use `child_a', clear 	

local y =5 // placeholder for the figure numerator

preserve  
keep if model =="m6" // keep the models with full set of controls

// destring share of children interact with their mother through the specified activity
replace share = round(share, 2) 
tostring share, generate(bar_lab)
replace bar_lab = "*"+bar_lab + "%"

    // keep them as local to recall as a part of the xlabels
	forvalues i=1/6{
		local bar_lab`i'= "`=bar_lab[`i']'"
		di "`bar_lab`i''"
	}
	 
 
// define order for figure 
gen ord=_n
mylabels -20(10)10, myscale(@/100) local(act_lab)

twoway  (bar b ord if outcome=="read_whom",  color(navy) barwidth(0.6)) (rcap ul  ll ord if  outcome=="read_whom", color(navy) lwidth(vthin)) ///
	   (bar b ord if outcome=="story_whom",  color(maroon) barwidth(0.6)) (rcap ul  ll ord if outcome=="story_whom", color(maroon) lwidth(vthin))   ///
	   (bar b ord if outcome=="sing_whom",  color(teal) barwidth(0.6)) (rcap ul  ll ord if outcome=="sing_whom", color(teal) lwidth(vthin))   ///
	   (bar b ord if outcome=="outdoor_whom",  color(sienna) barwidth(0.6)) (rcap ul  ll ord if outcome=="outdoor_whom", color(sienna) lwidth(vthin))   ///
	   (bar b ord if outcome=="play_whom",  color(dknavy) barwidth(0.6)) (rcap ul  ll ord if outcome=="play_whom", color(dknavy) lwidth(vthin))   ///
	   (bar b ord if outcome=="draw_whom",  color(khaki) barwidth(0.6)) (rcap ul  ll ord if outcome=="draw_whom", color(khaki) lwidth(vthin)), ///
		xlabel(1 "read (`bar_lab1')" 2 "story (`bar_lab2')"  3 "sing (`bar_lab3')" 4 "outdoor (`bar_lab4')" 5 "play (`bar_lab5')" 6 "draw (`bar_lab6')" , labsize(vsmall) gstyle(major) glwidth(thin)) ///
		graphregion(fcolor(white) color(white)) bgcolor(white)  ///
		ylabel(`act_lab', labsize(small) gstyle(major) glwidth(thin) ) ///
		xtitle("") ///
		ytitle("difference in means (percentage point)", size(vsmall)) ///
		title("{bf:Figure `y'}. Compared to mothers who do not work, mothers who work are", size(small)) ///
		subtitle("over 10% less likely to engage in outdoor and play activities with their young child", size(small)) ///
		legend(off) xsize(30) ysize(20) scale(1.2) ///		
		caption("The figure reports the difference in means across various activities involving both the mother and child." ///
				"*Shows the percentage of children who interact with their mother through the specified activity." ///
		        "All models include full set of controls, 95% confidence intervals are reported along with the mean differences." ///
				"Positive values indicate the children of working mothers are more likely to engage in the given activity with their mother." , size(vsmall)) ///
		name(figA1, replace)
		graph export "`figures'\Fig_`y'.png", replace 
		graph save "`figures'\Fig_`y'", replace 
restore 

*_______________________6.3 Heterogeneity results_______________________________
		
	
use `child_h', clear 	 

local y =`y'+1 //placeholder for the figure numerator

clonevar outcome_lab = outcome 

// restore original variable names
local i=1
foreach var in achieve_milestone stx_total_milestone z_weight health_issue_sr health_issue_lr general_health total_activity_mother current_school  breastfeed_num  dieatary_diversity rob_achieve_milestone breastfeed_duration {
	replace outcome_lab="`var'"  if outcome== "y`i'" 
	local i=`i'+1
	
}



// re-estimate confidence intervals based on adjusted p-values 

gen z_adj = invnorm(1 - (p_adj / 2))
	replace z_adj = 10 if p_adj==0  & b>0 // set a very high z value
	replace z_adj =-10 if p_adj==0  & b<0 // set a very high z value
	replace z_adj = invnorm(1-(0.999/2)) if p_adj==1
	
gen se_adj = abs(b / z_adj)
gen ll_adj = b - (1.96*se_adj)
gen ul_adj = b + (1.96*se_adj)

	replace ll_adj = -1 if  ll_adj<-1 | ll_adj==.
	replace ul_adj = 1 if ul_adj==. | ul_adj>1 
 



forvalues i=1/10{
 
preserve 
keep if !inlist(model, "age", "sex" ) & outcome=="y`i'"

gen ord=_n
	replace ord= ord+1 if model=="momeduc"
	replace ord= ord+2 if model=="father"

		if `i'==1 local labtit  "Child attains official development standard"
		if `i'==2 local labtit  "Z-score (number of milestones)"
		if `i'==3 local labtit  "Weight-for-age Z-score"
		if `i'==4 local labtit  "Short-term health (over the past two weeks)"
		if `i'==5 local labtit  "Long-term health (last six months)"
		if `i'==6 local labtit  "General health is very good"
		if `i'==7 local labtit  "Index of N activities with mother"
		if `i'==8 local labtit  "Preschool attendence"
		if `i'==9 local labtit  "Age stopped breastfeeding"
		if `i'==10 local labtit "Dietary diversity"
		
		if `i'<=6 local captit "All models include full set of controls and the child development inputs."
		else local captit "All models include full set of controls."
		
twoway  (bar b ord if model=="grandpa",  color(navy) barwidth(0.6)) (rcap ul_adj ll_adj ord if model=="grandpa", color(navy) lwidth(vthin)) ///
	   (bar b ord if model=="momeduc",  color(maroon) barwidth(0.6)) (rcap ul_adj ll_adj ord if model=="momeduc", color(maroon) lwidth(vthin))   ///
	   (bar b ord if model=="father",  color(teal) barwidth(0.6)) (rcap ul_adj ll_adj ord if model=="father", color(teal) lwidth(vthin))   , ///
		xlabel(1 "no grandparent" 2 "grandparent in housheold"  4 "less than primary" 5 "primary" 6 "upper secondary" 7 "tertiary" 9 "employed father" 10 "unemployed father" 11 "no father in household"   , angle(25) labsize(tiny) nogrid) ///
		graphregion(fcolor(white) color(white)) bgcolor(white)  ///
		ylabel(-1(0.5)1, labsize(small) gstyle(major) glwidth(thin) ) ///
		xtitle("") ///
		text(-1  11 "*", color(maroon) placement(c) size(tiny)) ///
		text(-1.03  1.5 "{bf:GRANDPARENT PRESENCE}", color(navy) placement(c) size(tiny)) ///
		text(-1.03  5.5 "{bf:MATERNAL EDUCATION}", color(navy) placement(c) size(tiny)) ///
		text(-1.03  10 "{bf:FATHER STATUS}", color(navy) placement(c) size(tiny)) ///
		title("{bf:Figure `y'}. Children of working mothers compared to children of non-working mothers", size(small)) ///
		subtitle("`labtit'", size(small)) ///
		legend(off) xsize(30) ysize(20) scale(1.25) ///
		caption("The figure reports the difference in means." ///
				"`captit'" ///
				"Positive values indicate the children of working mothers have better outcomes." ///
				"95% percent confidence intervals are estimated using adjusted p-values, with 100 bootstrap repetitions." ///
			    "*The upper and lower limits of the confidence intervals are constrained between -1 and 1.", size(vsmall)) ///
		name(figH`i', replace)
		graph export "`figures'\Fig_`y'.png", replace 
restore 

local y = `y'+1
 
}


// save as a dta file
drop z_adj se_adj 
save "`dataout'\Regressions_heterogeneity.dta", replace


/*==============================================================================
                             END OF DO FILE
==============================================================================*/

