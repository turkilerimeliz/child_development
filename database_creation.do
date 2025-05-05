/*==============================================================================
                      1: Database creation 
==============================================================================*/

*__________________________________1.1 Household________________________________

// deploy household-level data
use "`datain'/TCS_Household_Microdata.dta", clear
	
// rename and label	
rename birimno hhid 
		label var hhid "Household identifier"

rename faktor_hane hh_weight
		label var hh_weight "Household weight"
		
rename cevaplayici_fertno respondent_id
		label var respondent_id "Repondent id-household questionnaire"
		
rename hh_buyukluk hh_size 
		label var hh_size "Household size"	
		
rename	gelir_hane	hh_income
		label var hh_income "Monthly household income (in TL)"
	
// rename 
rename	anaokul_mesafe	preschool_distance
rename	ilkokul_mesafe	primary_distance
rename	ortaokul_mesafe	middle_distance
rename	lise_mesafe	highschool_distance
rename	spor_saha_mesafe	sport_distance
rename	kutuphane_mesafe	library_distance
rename	kurs_mesafe	course_distance
rename	ibadethane_mesafe	worship_distance
rename	cocuk_park_mesafe	playground_distance
rename	sinema_mesafe	cinema_distance
rename	kultur_mesafe	culture_center_distance
rename	market_mesafe	market_distance
rename	karakol_mesafe	police_distance
rename	saglik_mesafe	health_distance
rename	aile_yardim	family_aid
rename	aile_yardim_son12ay	family_aid_12m
rename	barinma_yardim	housing_aid
rename	barinma_yardim_son12ay	housing_aid_12m
rename	saglik_yardim	health_aid
rename	saglik_yardim_son12ay	health_aid_12m
rename	engelli_yardim	disability_aid
rename	engelli_yardim_son12ay	disability_aid_12m
rename	egitim_yardim	education_aid
rename	egitim_yardim_son12ay	education_aid_12m
rename	baska_yardim	other_aid
rename	baska_yardim_son12ay	other_aid_12m
rename  tuvalet_ic sanitary_inside_hh
rename  tuvalet_dis sanitary_outside_hh
rename  cati leaking_roof
rename nemli_duvar damping_wall_floor
rename curume_pencere rot_window_floor


// keep relevant variables 
keep hhid hh_weight respondent_id hh_income hh_size *_distance *_aid *aid_12m  sanitary_inside_hh  sanitary_outside_hh leaking_roof damping_wall_floor rot_window_floor


// save
save `hh_master', replace 

*______________________1.2 Child and Household roster___________________________


// deploy household roster 
use "`datain'/TCS_Individuallist_Microdata.dta", clear
	
	
	// merge with child dataset

	merge 1:1 birimno fertno using "`datain'/TCS_Individual_0-17_Microdata.dta"
	assert _merge!=2
	rename _merge  merge017
	 
		
    * rename key variables 
	rename birimno hhid // housheold id
		   label var hhid "Household identifier"
			
	rename fertno pid   // personal id 
		   label var pid "Personal identifier"

// cross checks  - number of observations 

	* children (0-17) - 14705 children were surveyed 
	count if merge017==3
		local obs = `r(N)'
		assert `obs'== 14705
	   
	* households- 7716 households were surveyed 

	preserve
		duplicates drop hhid, force 
		count if hhid!=.
			local obs = `r(N)'
			assert `obs'== 7716
		
	restore 
	

// keep only related variables 
keep hhid pid  cinsiyet dogum_tarih_gun dogum_tarih_ay dogum_tarih_yil yas_bitirilen yas_yil yas_ay yas_gun yakinlik medeni_durum fertno_es oz_anne_hayatta oz_anne_bu_evde fertno_oz_anne oz_baba_hayatta oz_baba_bu_evde fertno_oz_baba temel_bakim gunduz_bakim gunduz_bakim_yakinlik hane_disindan okul_durum egitim_seviye seviye_bitirme_durum okur_yazar faal_durum  fertno_bakim_veren yakinlik_bakim_veren okul_yili_devam okul_yili_terk_neden okul_yili_seviye_devam yardim_okul_malzeme okul_tur onceki_okul_yili_devam onceki_okul_yili_seviye_devam yardim_sartli_egitim yardim_sosyal_destek okul_durum_0_17 okul_terk_neden_0_17 egitim_seviye_0_17 cocuk_kitap yalniz_kalma gozetime_birakma birlikte_kitap_okuma kimle_kitap_okuma birlikte_hikaye kimle_hikaye birlikte_sarki kimle_sarki birlikte_disari kimle_disari birlikte_oynama kimle_oynama birlikte_cizme kimle_cizme engebede_yurume ziplama giyinme dugme_ilikleme kelime_soyleme uc_kelimelik_cumle bes_kelimelik_cumle zamir_kullanma nesne_ismi_bilme alfabe_bes_harf ismini_yazma birden_bese_sayma sayili_nesne hatasiz_sayma boya_yapma baskalarini_sorma yardim_teklif iyi_gecinme uyuma kilo boy saglik_sorun saglik_sikayet kronik_hastalik kronik_hastalik_1 kronik_hastalik_gunluk engelli_rapor genel_saglik_0_17 gozluk_takma_2_4_yas gozluk_takma_zorluk_2_4_yas gorme_zorluk_2_4_yas isitme_cihaz_takma_2_4_yas isitme_cihaz_zorluk_2_4_yas duymada_zorluk_2_4_yas yurume_ekipman_2_4_yas yurumede_zorluk_2_4_yas yurume_ekipman_zorluk_2_4_yas faktor_fert merge017 anne_sutu anne_sutu_devam anne_sutu_sure meyve_yeme sebze_yeme et_tavuk_balik_yeme bakliyat_yeme hayvan_urunu_yeme tatli_yeme atistirmalik_yeme alkolsuz_icecek_icme tahil_yeme merge017



// rename / label - household roster 

rename  faktor_fert pers_weight
		label var pers_weight "Personal weight"
		
rename  cinsiyet gender
		label var gender "Gender"
		
rename	dogum_tarih_gun	birth_day
		label var birth_day "Day of birth"
		
rename	dogum_tarih_ay	birth_month
		label var birth_month "Month of birth"
		
rename	dogum_tarih_yil	birth_year
		label var birth_year "Year of birth"
rename	yas_yil	age_years 
		label var age_years "Age in years - reported in microdata"
		
rename	yas_bitirilen	completed_age
rename	yas_ay	age_months
rename	yas_gun	age_days
		
		
// check implausible age and flag the cases 

*Note: exact survey date was not reported,  use the start and end period of the field study to define tresholds
	gen month_lw = datediff(mdy(birth_month, birth_day, birth_year), mdy(10, 10, 2022), "month")  // lower bound - age in months
	gen month_up = datediff(mdy(birth_month, birth_day, birth_year), mdy(12, 16, 2022), "month")  // upper bound - age in months 
	
	// defined completed age in moths (based on reported age data)
	gen completed_months = (12*age_years) + age_months 
		label var completed_months "Age (in months)"

		// flag implausible cases 
		gen implausible_age =(completed_months<month_lw | completed_months>month_up)
			label var implausible_age "data error - age in completed months"

			 
		// flag missing values for year of birth (completed age is reported for these cases)
		gen flag_mis_birthyear = (birth_year==.)
			label var flag_mis_birthyear "age data is used to recall birth year"
			replace birth_year = 2022- completed_age if flag_mis_birthyear==1
			assert birth_year!=.
			
			
		// use lower bound of age in months to impute cases with implausible age (in months)
		*Note: these cases are excluded from the child sample -- but still they are neccessary to report age of youngest child
		replace completed_months= month_lw if implausible_age==1 & flag_mis_birthyear!=1 & !mi(birth_month) & !mi(birth_day)
		gen imputed_agemonths = (implausible_age==1 & flag_mis_birthyear!=1 & !mi(birth_month) & !mi(birth_day))
		
		    // correct age in years for these cases 
		    gen age = floor(completed_months/12)
				assert age==age_years if imputed_agemonths!=1
				label var age "Age (in years)"
				assert age!=.
			
		
	    // drop intermediate variables 
		drop month_lw month_up month_up implausible_age age_days age_months 
				
		
// rename / label - household roster  (rest)		
		
rename	yakinlik relationship
		label var relationship "Relationship with household respondent"
		
rename	medeni_durum marital_status
		label var marital_status "Marital status"
		
rename	fertno_es spouse_id
		label var spouse_id "Spouse`s id"
		
rename	oz_anne_hayatta	mother_alive
		label var mother_alive "Mother is alive"
		
rename	oz_anne_bu_evde	mother_in_house
		label var mother_in_house "Mother is living in the same household"
	
rename	fertno_oz_anne	mother_id
		label var mother_id "Mother`s id"
		
rename	oz_baba_hayatta	father_alive
		label var father_alive "Father is alive"
		
rename	oz_baba_bu_evde	father_in_house
		label var father_in_house "Father is living in the same household"

rename	fertno_oz_baba	father_id
		label var father_id "Father`s id"

rename	gunduz_bakim secondary_caregiver
		label var secondary_caregiver "Presence of secondary caregiver"
		
rename	gunduz_bakim_yakinlik secondary_caregiver_rel
		label var secondary_caregiver_rel "Relationship of secondary caregiver with child"
		
rename	hane_disindan	outside_household
		label var outside_household "Secondary caregiver is not a hh member"
		
rename	okul_durum school_stat
		label var school_stat "School status"
		
rename	egitim_seviye education
		label var education "Educational attainment"
	
rename	seviye_bitirme_durum completion_status
		label var completion_status "Completed education"
		
rename	okur_yazar literacy_status
		label var literacy_status "Literacy status"
		
rename	faal_durum employment_status
		label var employment_status "Employment status"
		
rename	temel_bakim	primary_caregiver
		label var primary_caregiver "Primary caregiver - id"
 

// rename - main characteristics (child) 
rename	fertno_bakim_veren	caregiver_id
		label var caregiver_id "Primary caregiver`s id"
		
rename	yakinlik_bakim_veren caregiver_relationship
	label var caregiver_relationship "Relationship of primary caregiver with child"
	
rename	okul_yili_devam	current_school_year_attendance
		label var current_school_year_attendance "Currently attending school"
	
rename	okul_yili_seviye_devam	current_education_level
		label var current_education_level "School level"
		
rename	okul_tur school_type
		label var school_type "Type of school"

rename	okul_durum_0_17	school_status_0_17
		label var school_status_0_17 "Has ever attended school"

rename	yardim_sosyal_destek social_support_assistance
		label var social_support_assistance "Received social support for the child in last 12 months"
	
rename	cocuk_kitap	child_book
		label var child_book "Number of book in hh for each child"
	

// rename and label milestones (child)
rename	engebede_yurume	walk
		label var walk "Walking (uneven surface)"
		
rename	ziplama	jump
		label var jump "Jumping"
		
rename	giyinme	dress
		label var dress "Dressing"
		
rename	dugme_ilikleme button
		label var button "Button"
		
rename	kelime_soyleme word
		label var word "10 or more word"
		
rename	uc_kelimelik_cumle word3
		label var word3 "3-word sentence"
		
rename	bes_kelimelik_cumle word5
		label var word5 "5-word sentence"
		
rename	zamir_kullanma pronoun
		label var pronoun "Using pronoun"
		
rename	nesne_ismi_bilme knowname
		label var knowname "Naming objects"
		
rename	alfabe_bes_harf	alphabet
		label var alphabet "Letter recognition"
		
rename	ismini_yazma write 
		label var write "Writing own name"
		
rename	birden_bese_sayma count_n
		label var count_n "Counting 1 to 5"
		
rename	sayili_nesne count_obj
		label var count_obj "Counting objects"
		
rename	hatasiz_sayma count_err
		label var count_err "Counting without error"
		
rename	boya_yapma	coloring
		label var coloring "Painting"
		
rename	baskalarini_sorma askother
		label var askother "Asking about others"
		
rename	yardim_teklif helpo
		label var helpo "Offering help"
		
rename	iyi_gecinme	getting_well
		label var getting_well "Getting along with others"
	
	
// rename / label well-being and diatery (child)
rename	uyuma sleeping
		label var sleeping "Hours of sleep per day"
		
rename	kilo	weight
		label var weight "Weight in kg"
		
rename	boy	height
		label var height "Height in cm"
		
rename	saglik_sorun	health_issue_sr
		label var health_issue_sr "Short-term health (over the past two weeks)"
	
rename	kronik_hastalik	health_issue_lr
		label var health_issue_lr "Long-term health (last six months)"
	
rename	genel_saglik_0_17	general_health
		label var general_health "General health is very good"
		
rename	engelli_rapor	disability_report
		label var disability_report  "Having a disability report issued by a medical board"
		
rename	anne_sutu	breastfeed
		label var breastfeed "Child ever breastfed"
		
rename	anne_sutu_devam	breastfeed_cont
		label var breastfeed_cont "Continous to be breastfed"

rename	anne_sutu_sure	breastfeed_duration
		label var breastfeed_duration "Breastfeeding cessation age (in months)"
		
	
// rename - rest 
rename	yardim_okul_malzeme	school_supplies_assistance
rename	okul_yili_terk_neden	school_dropout_reason
rename	onceki_okul_yili_devam	previous_school_year_attendance
rename	onceki_okul_yili_seviye_devam	previous_education_level
rename	yardim_sartli_egitim	conditional_education_assistance
rename	okul_terk_neden_0_17	dropout_reason_0_17
rename	egitim_seviye_0_17	education_level_0_17

rename	yalniz_kalma	left_alone
rename	gozetime_birakma	left_under_supervision
rename	birlikte_kitap_okuma	read_together
rename	kimle_kitap_okuma	read_whom
rename	birlikte_hikaye	story_together
rename	kimle_hikaye	story_whom
rename	birlikte_sarki	sing_together
rename	kimle_sarki	sing_whom
rename	birlikte_disari	outdoor_together
rename	kimle_disari	outdoor_whom
rename	birlikte_oynama	play_together
rename	kimle_oynama	play_whom
rename	birlikte_cizme	draw_together
rename	kimle_cizme	draw_whom

rename	saglik_sikayet	health_complaint
rename	kronik_hastalik_1	chronic_disease_det
rename	kronik_hastalik_gunluk	chronic_daily
rename	gozluk_takma_2_4_yas	glasses
rename	gozluk_takma_zorluk_2_4_yas	glasses_diff
rename	gorme_zorluk_2_4_yas	vision_diff
rename	isitme_cihaz_takma_2_4_yas	hearing_aid
rename	isitme_cihaz_zorluk_2_4_yas	hearing_diff
rename	duymada_zorluk_2_4_yas	hearing_issue
rename	yurume_ekipman_2_4_yas	walking_aid
rename	yurumede_zorluk_2_4_yas	walking_diff
rename	yurume_ekipman_zorluk_2_4_yas	walking_aid_issue
rename	meyve_yeme	fruit_intake
rename	sebze_yeme	vegetable_intake
rename	et_tavuk_balik_yeme	meat_intake
rename	bakliyat_yeme	legumes_intake
rename	hayvan_urunu_yeme	animal_product_intake
rename	tatli_yeme	sweets_intake
rename	atistirmalik_yeme	snack_intake
rename	alkolsuz_icecek_icme	softdrink_intake
rename	tahil_yeme	grain_intake
rename	merge017	merge_017



 
// save
save `master', replace 


/*==============================================================================
                             END OF DO FILE
==============================================================================*/

