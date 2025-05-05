
/*==============================================================================
Project: Analysis of Maternal Work & Child Development 
			
Author: Meliz Tyurkileri
Dependencies: 
--------------------------------------------------------------------------------
Creation Date:       Feb, 2025
Data: Child Survey 2022, Turkiye
Modification Date: 29 Apr, 2025 
Do-file version:  18
References:          
Output:             
==============================================================================*/

macro drop _all 
drop _all
clear all
version 14

timer on 1

/*==============================================================================
                           0: Set locals and Paths							  
==============================================================================*/

*-------------------------------0.1: Paths -------------------------------------

** Meliz
if "`c(username)'" == "wb586966" {
	
	cd "/Users/wb586966/OneDrive - WBG/Desktop/Child_Development/"
	local datain "/Users/wb586966/OneDrive - WBG/Desktop/Child_Development/datain"
	local dataout "/Users/wb586966/OneDrive - WBG/Desktop/Child_Development/dataout"
	local do "/Users/wb586966/OneDrive - WBG/Desktop/Child_Development/do"
	local figures "/Users/wb586966/OneDrive - WBG/Desktop/Child_Development/figures"
	local results "/Users/wb586966/OneDrive - WBG/Desktop/Child_Development/results"
}




** For replication 
if "`c(username)'" == "" {
	
	cd ""
	local dta ""
	local dataout ""
	local do ""
	local figures ""
	local results ""
}


*---------------------------0.2: Temporary files -------------------------------

tempfile master hh_master child parents_id household_id age_children parents household relationship hh_educ grandparent clean_data


*-------------------------------0.3: Local variables ---------------------------
	

// define local variables used to define age interval of sample
local lower = 2
local upper = 4


set seed 42


/*==============================================================================
                             1: Database creation
==============================================================================*/


di in blue "currently run database_creation" 
include "`do'\database_creation.do"


/*==============================================================================
                            2: Variable creation 						  
==============================================================================*/

*_________________________________2.1 Child_____________________________________

include "`do'/variable_creation_child.do"
 
*_________________________________2.2 Parents___________________________________

include "`do'/variable_creation_parents.do"
 
*______________________________2.3 Household____________________________________

include "`do'/variable_creation_households.do"

 /*==============================================================================
                           3: Sample formation 
==============================================================================*/

include "`do'/sample_selection.do"

 /*==============================================================================
                           4: Descriptives (Stats and Figures)
==============================================================================*/

include  "`do'/descriptives.do"
 

/*==============================================================================
                            5: Results							  
==============================================================================*/

*__________________________5.1 Main Results_____________________________________

include "`do'/results.do"

*__________________________5.2 Activity________________________________________

include "`do'/results_activity.do"
 
*__________________________5.3 Heterogeneities__________________________________

include "`do'/results_heterogeneity.do"
 

 
/*==============================================================================
                            6: Figures							  
==============================================================================*/


include "`do'/figures.do"

// exit
timer off 1
timer list 1 // 596.93 second == 10 min
exit 

/*==============================================================================
                             END OF MASTER DO
==============================================================================*/

