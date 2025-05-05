/*==============================================================================
                              5.2: Results - Activity
==============================================================================*/

// drop stored estimates -- already reported 
est drop _all

*__________________________5.2.1 Regressions____________________________________


// open postfile to report regression results 

tempname  posta
tempfile child_a
postfile `posta' str20(outcome) str20(model)  b se z pval ll ul share using `child_a', replace 
 
 
// list sub-items of activity with mother 

local activity_list  read_whom story_whom sing_whom outdoor_whom play_whom draw_whom


local i =1
	foreach var in `activity_list'{
	
		 assert !mi(`var') // no missing values 
		 qui  eststo W1_`i': regress  `var' mother_employed `child' [pw=upweight],  vce(cluster  cluster_id)
			matrix A = r(table)[1..6,1]'
			mean `var' [pw=upweight]
			matrix B = r(table)[1,1]*100
			post `posta' ("`var'") ("m1")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6])  (B[1,1])
			
	   	qui  eststo W2_`i': regress  `var' mother_employed `child' `mom' [pw=upweight],  vce(cluster  cluster_id)
			matrix A = r(table)[1..6,1]'
			post `posta' ("`var'") ("m3")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6])  (B[1,1])
			
		qui  eststo W3_`i': regress  `var' mother_employed `child'  `mom' `hhdem' `hhinc' [pw=upweight],  vce(cluster  cluster_id)
			matrix A = r(table)[1..6,1]'
			post `posta' ("`var'") ("m6")  (A[1,1]) (A[1,2]) (A[1,3]) (A[1,4]) (A[1,5]) (A[1,6]) (B[1,1])
			
	 local i = `i'+1
	}


postclose `posta'
	

*__________________________5.2.2 Export Results____________________________________



esttab W1_1 W1_2 W1_3 W1_4 W1_5 W1_6 using "`results'\Table_S15.html", replace  label  nobase alignment(center) title("Table S15a. Activity with mother (baseline model)") cells(b(star fmt(3)) se(par fmt(3)) nolabel) stats( N, fmt( %9.0gc) labels(Observations)) collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nonote  varwidth(35) width(60%)  drop (_cons) mtitle(read story sing outdoor play draw)  noomitted nodepvars note("Note: Table S15a reports the results of the baseline model  controlling only for child`s age and gender. The dependent variables are the distinct activities with mother. Standard errors are clustered at the mother level. The significance level is reported based on unadjusted p-values. <br>* p < 0.10, ** p < 0.05, *** p < 0.01<br><br></body>")


esttab W2_1 W2_2 W2_3 W2_4 W2_5 W2_6 using "`results'\Table_S15.html", append  label  nobase alignment(center) title("Table S15b. Activity with mother (maternal characteristics)") cells(b(star fmt(3)) se(par fmt(3)) nolabel) stats( N, fmt( %9.0gc) labels(Observations)) collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nonote  varwidth(35) width(60%)  drop (_cons) mtitle(read story sing outdoor play draw) noomitted nodepvars note("Note: Table S15b reports the results of an extended version of the baseline model including additional controls on maternal characteristics. The dependent variables are the distinct activities with mother. Standard errors are clustered at the mother level. The significance level is reported based on unadjusted p-values. <br>* p < 0.10, ** p < 0.05, *** p < 0.01<br><br></body>")

 
esttab W3_1 W3_2 W3_3 W3_4 W3_5 W3_6 using "`results'\Table_S15.html", append  label  nobase alignment(center) title("Table S15c. Activity with mother (extended model)") cells(b(star fmt(3)) se(par fmt(3)) nolabel) stats( N, fmt( %9.0gc) labels(Observations)) collabels(none) starlevels( * 0.10 ** 0.05 *** 0.01) nogaps nonote  varwidth(35) width(60%)  drop (_cons) mtitle(read story sing outdoor play draw) noomitted nodepvars note("Note:Table S15c reports the results of an extended  model including full set of controls. The dependent variables are the distinct activities with mother. Standard errors are clustered at the mother level. The significance level is reported based on unadjusted p-values. <br>* p < 0.10, ** p < 0.05, *** p < 0.01<br><br></body>")

 
/*==============================================================================
                             END OF DO FILE
==============================================================================*/


 
	
