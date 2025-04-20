************************************************
********** Basecase + scenario 1 icer outcomes
************************************************
cd "../"

import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear

* basecase analyses	
	* incidence case
	gen opvisit_tivR = opvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop 
	gen ipvisit_tivR = ipvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen otc_tivR =  opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen mortality_tivR = episode*MortalityHR*(1+MortalityRate)*(1-VCR_af*ve)/(1-VCR_bf*ve)*pop/1000 //mortality double check
	
	gen opvisit_noR = opvisit/1000*pop
	gen ipvisit_noR = ipvisit/1000*pop
	gen otc_noR = opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)/1000*pop
	gen mortality_noR = episode*MortalityHR*(1+MortalityRate)*pop/1000
		
	* total utlity loss for that group
	gen utility_OP_noR  = (utility_health-utility_OP)*opvisit_noR 
	gen utility_OP_tivR = (utility_health-utility_OP)*opvisit_tivR 
	gen utility_IP_noR  = (utility_health-utility_IP)*opvisit_noR 
	gen utility_IP_tivR = (utility_health-utility_IP)*opvisit_tivR 
	gen utility_oct_noR  = 0.05*opvisit_noR 
	gen utility_oct_tivR = 0.05*opvisit_tivR 
	gen utility_mortality_noR  = utility_health*mortality_no
	gen utility_mortality_tivR =  utility_health*mortality_tiv
	
	* total cost for that group
	gen cost_OP_noR  = OP_directcost * opvisit_noR
	gen cost_OP_tivR = OP_directcost * opvisit_tivR
	gen cost_IP_noR  =  IP_directcost * ipvisit_noR
	gen cost_IP_tivR = IP_directcost * ipvisit_tivR
	gen cost_oct_noR  = otccost * otc_noR
	gen cost_oct_tivR = otccost * otc_tivR
	gen cost_nondirectOP_noR  = OP_indirectcost * opvisit_noR 
	gen cost_nondirectOP_tivR =  OP_indirectcost * opvisit_tivR 
	gen cost_nondirectIP_noR  = IP_indirectcost * ipvisit_noR 
	gen cost_nondirectIP_tivR =  IP_indirectcost * ipvisit_tivR 
	gen cost_nonmedicalOP_noR  = OP_nomedicalcost * opvisit_noR 
	gen cost_nonmedicalOP_tivR =  OP_nomedicalcost * opvisit_tivR 
	gen cost_nonmedicalIP_noR  = IP_nomedicalcost * ipvisit_noR  
	gen cost_nonmedicalIP_tivR = IP_nomedicalcost * ipvisit_tivR 
	
	* vaccine cost 
	gen cost_vacc_tivR = (vaccine_govcost+vaccine_adminstration) * VCR_af * pop    if inrange(agegroup,70,100)
	replace cost_vacc_tivR = (vaccine_mktcost+vaccine_adminstration) * VCR_af * pop    if inrange(agegroup,60,65)
	gen cost_vacc_noR =  (vaccine_mktcost+vaccine_adminstration) * VCR_bf * pop	
	
	*aggregrate risk group,keep age group
	foreach k in opvisit_no ipvisit_no otc_no utility_OP_no utility_IP_no utility_oct_no cost_OP_no cost_IP_no cost_oct_no cost_nondirectOP_no cost_nondirectIP_no cost_nonmedicalOP_no cost_nonmedicalIP_no opvisit_tiv ipvisit_tiv otc_tiv utility_OP_tiv utility_IP_tiv utility_oct_tiv cost_OP_tiv cost_IP_tiv cost_oct_tiv cost_nondirectOP_tiv cost_nondirectIP_tiv cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv utility_mortality_tiv utility_mortality_no mortality_no mortality_tiv cost_vacc_tiv  cost_vacc_no {
		bysort agegroup : egen sumage_`k' = sum(`k'R)
	}	
	
	keep agegroup sumage_*  
	duplicates drop
	
	* summary of the cost 
	*utility cost / utility loss
	gen sumage_utility_noA = sumage_utility_OP_no+sumage_utility_IP_no+sumage_utility_oct_no+sumage_utility_mortality_no
	gen sumage_utility_tivA = sumage_utility_OP_tiv+sumage_utility_IP_tiv+sumage_utility_oct_tiv+sumage_utility_mortality_tiv
	
	egen sumage_cost_nohealthA = rowtotal(sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no  sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_cost_vacc_no)
	
	egen sumage_cost_tivhealthA = rowtotal(sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv  sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_cost_vacc_tiv)

	egen sumage_cost_nosocialA = rowtotal(sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no sumage_cost_nondirectIP_no sumage_cost_nondirectOP_no sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_cost_vacc_no)
	
	egen sumage_cost_tivsocialA = rowtotal(sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv sumage_cost_nondirectIP_tiv sumage_cost_nondirectOP_tiv sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_cost_vacc_tiv)
		
	* gap 
	gen sumage_utility_gap = sumage_utility_noA - sumage_utility_tivA
	gen sumage_cost_health_gap = sumage_cost_tivhealthA-sumage_cost_nohealthA
	gen sumage_cost_social_gap = sumage_cost_tivsocialA-sumage_cost_nosocialA
		
	preserve 
		drop if agegroup ==60		
		collapse (sum) sumage_utility_gap sumage_cost_health_gap sumage_cost_social_gap		
			
		* ICER 
		gen ICER_tivno_healthA = sumage_cost_health_gap/sumage_utility_gap
		gen ICER_tivno_socialA = sumage_cost_social_gap/sumage_utility_gap
		
		sum ICER*

		gen Hper = .
		gen Sper = .
		
		*** Table 3: basecase
		table1 ,vars( sumage_utility_gap contn\ Hper contn\ sumage_cost_health_gap contn\ ICER_tivno_healthA  contn\ Sper contn\ sumage_cost_social_gap contn\ ICER_tivno_socialA contn\ )   format(%2.1f) saving("basecase.xls", replace)
	restore

************************************************
********** scenario 1: expand to 60+
************************************************
import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear

* basecase analyses	
	* incidence case
	gen opvisit_tivR = opvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop 
	gen ipvisit_tivR = ipvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen otc_tivR =  opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen mortality_tivR = episode*MortalityHR*(1+MortalityRate)*(1-VCR_af*ve)/(1-VCR_bf*ve)*pop/1000 //mortality double check
	
	gen opvisit_noR = opvisit/1000*pop
	gen ipvisit_noR = ipvisit/1000*pop
	gen otc_noR = opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)/1000*pop
	gen mortality_noR = episode*MortalityHR*(1+MortalityRate)*pop/1000
	
	sum *_tiv* *_no*
	
	* total utlity loss for that group
	gen utility_OP_noR  = (utility_health-utility_OP)*opvisit_noR 
	gen utility_OP_tivR = (utility_health-utility_OP)*opvisit_tivR 
	gen utility_IP_noR  = (utility_health-utility_IP)*opvisit_noR 
	gen utility_IP_tivR = (utility_health-utility_IP)*opvisit_tivR 
	gen utility_oct_noR  = 0.05*opvisit_noR 
	gen utility_oct_tivR = 0.05*opvisit_tivR 
	gen utility_mortality_noR  = utility_health*mortality_no
	gen utility_mortality_tivR =  utility_health*mortality_tiv
	
	* total cost for that group
	gen cost_OP_noR  = OP_directcost * opvisit_noR
	gen cost_OP_tivR = OP_directcost * opvisit_tivR
	gen cost_IP_noR  =  IP_directcost * ipvisit_noR
	gen cost_IP_tivR = IP_directcost * ipvisit_tivR
	gen cost_oct_noR  = otccost * otc_noR
	gen cost_oct_tivR = otccost * otc_tivR
	gen cost_nondirectOP_noR  = OP_indirectcost * opvisit_noR 
	gen cost_nondirectOP_tivR =  OP_indirectcost * opvisit_tivR 
	gen cost_nondirectIP_noR  = IP_indirectcost * ipvisit_noR 
	gen cost_nondirectIP_tivR =  IP_indirectcost * ipvisit_tivR 
	gen cost_nonmedicalOP_noR  = OP_nomedicalcost * opvisit_noR 
	gen cost_nonmedicalOP_tivR =  OP_nomedicalcost * opvisit_tivR 
	gen cost_nonmedicalIP_noR  = IP_nomedicalcost * ipvisit_noR  
	gen cost_nonmedicalIP_tivR = IP_nomedicalcost * ipvisit_tivR 
	
	* vaccine cost 
	gen cost_vacc_tivR = (vaccine_govcost+vaccine_adminstration) * VCR_af * pop   
	gen cost_vacc_noR =  (vaccine_mktcost+vaccine_adminstration) * VCR_bf * pop	
	
	*aggregrate risk group,keep age group
	foreach k in opvisit_no ipvisit_no otc_no utility_OP_no utility_IP_no utility_oct_no cost_OP_no cost_IP_no cost_oct_no cost_nondirectOP_no cost_nondirectIP_no cost_nonmedicalOP_no cost_nonmedicalIP_no opvisit_tiv ipvisit_tiv otc_tiv utility_OP_tiv utility_IP_tiv utility_oct_tiv cost_OP_tiv cost_IP_tiv cost_oct_tiv cost_nondirectOP_tiv cost_nondirectIP_tiv cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv utility_mortality_tiv utility_mortality_no mortality_no mortality_tiv cost_vacc_tiv  cost_vacc_no {
		bysort agegroup : egen sumage_`k' = sum(`k'R)
	}	
	
	keep agegroup sumage_*  
	duplicates drop
	
	* summary of the cost 
	*utility cost 
	gen sumage_utility_noA = sumage_utility_OP_no+sumage_utility_IP_no+sumage_utility_oct_no+sumage_utility_mortality_no
	gen sumage_utility_tivA = sumage_utility_OP_tiv+sumage_utility_IP_tiv+sumage_utility_oct_tiv+sumage_utility_mortality_tiv
	
	egen sumage_cost_nohealthA = rowtotal(sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no  sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_cost_vacc_no)
	
	egen sumage_cost_tivhealthA = rowtotal(sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv  sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_cost_vacc_tiv)

	egen sumage_cost_nosocialA = rowtotal(sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no sumage_cost_nondirectIP_no sumage_cost_nondirectOP_no sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_cost_vacc_no)
	
	egen sumage_cost_tivsocialA = rowtotal(sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv sumage_cost_nondirectIP_tiv sumage_cost_nondirectOP_tiv sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_cost_vacc_tiv)
		
	* gap 
	gen sumage_utility_gap = sumage_utility_noA - sumage_utility_tivA
	gen sumage_cost_health_gap = sumage_cost_tivhealthA-sumage_cost_nohealthA
	gen sumage_cost_social_gap = sumage_cost_tivsocialA-sumage_cost_nosocialA
		
	preserve 
		collapse (sum) sumage_utility_gap sumage_cost_health_gap sumage_cost_social_gap		
			
		* ICER 
		gen ICER_tivno_healthA = sumage_cost_health_gap/sumage_utility_gap
		gen ICER_tivno_socialA = sumage_cost_social_gap/sumage_utility_gap
		
		sum ICER*
	
		gen Hper = .
		gen Sper = .
		*** Table 3: scenario 1
		table1 ,vars( sumage_utility_gap contn\ Hper contn\ sumage_cost_health_gap contn\ ICER_tivno_healthA  contn\ Sper contn\ sumage_cost_social_gap contn\ ICER_tivno_socialA contn\ )     format(%2.1f) saving("scenario_60.xls", replace)
	restore	

************************************************
********** scenario 2:  focus on highrisk older adults
************************************************
import excel "/Users/x152/Library/CloudStorage/Box-Box/CEA小小组/A02 CEA/Analyses/do/ceaparameter_old.xlsx", sheet("Sheet1") firstrow clear
	drop if agegroup == .
* highrisk ,new setting
	replace VCR_af = VCR_bf if riskgroup == 0
	replace VCR_af = 0.87 if riskgroup == 1
* basecase analyses	
	* incidence case
	gen opvisit_tivR = opvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop 
	gen ipvisit_tivR = ipvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen otc_tivR =  opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen mortality_tivR = episode*MortalityHR*(1+MortalityRate)*(1-VCR_af*ve)/(1-VCR_bf*ve)*pop/1000 //mortality double check
	
	gen opvisit_noR = opvisit*pop/1000
	gen ipvisit_noR = ipvisit*pop/1000
	gen otc_noR = opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)/1000*pop
	gen mortality_noR = episode*MortalityHR*(1+MortalityRate)*pop/1000 //  episode*MortalityHR*pop/1000
	
	sum *_tiv* *_no*
	
	* total utlity loss for that group
	gen utility_OP_noR  = (utility_health-utility_OP)*opvisit_noR 
	gen utility_OP_tivR = (utility_health-utility_OP)*opvisit_tivR 
	gen utility_IP_noR  = (utility_health-utility_IP)*opvisit_noR 
	gen utility_IP_tivR = (utility_health-utility_IP)*opvisit_tivR 
	gen utility_oct_noR  = 0.05*opvisit_noR 
	gen utility_oct_tivR = 0.05*opvisit_tivR 
	gen utility_mortality_noR  = utility_health*mortality_no
	gen utility_mortality_tivR =  utility_health*mortality_tiv
	
	* total cost for that group
	gen cost_OP_noR  = OP_directcost * opvisit_noR
	gen cost_OP_tivR = OP_directcost * opvisit_tivR
	gen cost_IP_noR  =  IP_directcost * ipvisit_noR
	gen cost_IP_tivR = IP_directcost * ipvisit_tivR
	gen cost_oct_noR  = otccost * otc_noR
	gen cost_oct_tivR = otccost * otc_tivR
	gen cost_nondirectOP_noR  = OP_indirectcost * opvisit_noR 
	gen cost_nondirectOP_tivR =  OP_indirectcost * opvisit_tivR 
	gen cost_nondirectIP_noR  = IP_indirectcost * ipvisit_noR 
	gen cost_nondirectIP_tivR =  IP_indirectcost * ipvisit_tivR 
	gen cost_nonmedicalOP_noR  = OP_nomedicalcost * opvisit_noR 
	gen cost_nonmedicalOP_tivR =  OP_nomedicalcost * opvisit_tivR 
	gen cost_nonmedicalIP_noR  = IP_nomedicalcost * ipvisit_noR  
	gen cost_nonmedicalIP_tivR = IP_nomedicalcost * ipvisit_tivR 
	
	* vaccine cost 
	gen cost_vacc_tivR = (vaccine_govcost+vaccine_adminstration) * VCR_af * pop    if riskgroup == 1 
	replace cost_vacc_tivR = (vaccine_mktcost+vaccine_adminstration) * VCR_af * pop    if riskgroup == 0
	gen cost_vacc_noR =  (vaccine_mktcost+vaccine_adminstration) * VCR_bf * pop	
	
	*aggregrate risk group,keep age group
	foreach k in opvisit_no ipvisit_no otc_no utility_OP_no utility_IP_no utility_oct_no cost_OP_no cost_IP_no cost_oct_no cost_nondirectOP_no cost_nondirectIP_no cost_nonmedicalOP_no cost_nonmedicalIP_no opvisit_tiv ipvisit_tiv otc_tiv utility_OP_tiv utility_IP_tiv utility_oct_tiv cost_OP_tiv cost_IP_tiv cost_oct_tiv cost_nondirectOP_tiv cost_nondirectIP_tiv cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv utility_mortality_tiv utility_mortality_no mortality_no mortality_tiv cost_vacc_tiv  cost_vacc_no {
		bysort agegroup : egen sumage_`k' = sum(`k'R)
	}	
	
	keep agegroup sumage_*  
	duplicates drop
	
	* summary of the cost 
	*utility cost /
	gen sumage_utility_noA = sumage_utility_OP_no+sumage_utility_IP_no+sumage_utility_oct_no+sumage_utility_mortality_no
	gen sumage_utility_tivA = sumage_utility_OP_tiv+sumage_utility_IP_tiv+sumage_utility_oct_tiv+sumage_utility_mortality_tiv
	
	egen sumage_cost_nohealthA = rowtotal(sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no  sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_cost_vacc_no)
	
	egen sumage_cost_tivhealthA = rowtotal(sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv  sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_cost_vacc_tiv)

	egen sumage_cost_nosocialA = rowtotal(sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no sumage_cost_nondirectIP_no sumage_cost_nondirectOP_no sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_cost_vacc_no)
	
	egen sumage_cost_tivsocialA = rowtotal(sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv sumage_cost_nondirectIP_tiv sumage_cost_nondirectOP_tiv sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_cost_vacc_tiv)
	
	* gap 
	gen sumage_utility_gap = sumage_utility_noA - sumage_utility_tivA
	gen sumage_cost_health_gap = sumage_cost_tivhealthA-sumage_cost_nohealthA
	gen sumage_cost_social_gap = sumage_cost_tivsocialA-sumage_cost_nosocialA
	
	preserve 
		drop if agegroup ==60	
		collapse (sum) sumage_utility_gap sumage_cost_health_gap sumage_cost_social_gap		
		
	* ICER //
	gen ICER_tivno_healthA = sumage_cost_health_gap/sumage_utility_gap
	gen ICER_tivno_socialA = sumage_cost_social_gap/sumage_utility_gap
	
	sum ICER*
	
	* basecase ananlyses results
	tab ICER_tivno_healthA 
	tab ICER_tivno_socialA
		gen Hper = .
		gen Sper = .
		*** Table 3: scenario 2		
		table1 ,vars( sumage_utility_gap contn\ Hper contn\ sumage_cost_health_gap contn\ ICER_tivno_healthA  contn\ Sper contn\ sumage_cost_social_gap contn\ ICER_tivno_socialA contn\ )    format(%2.1f) saving("scenario_highrisk.xls", replace)
	restore

************************************************
********** basecase results by age and risk group
************************************************
import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear
	* incidence case
	gen opvisit_tivR = opvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop 
	gen ipvisit_tivR = ipvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen otc_tivR =  opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen mortality_tivR = episode*MortalityHR*(1+MortalityRate)*(1-VCR_af*ve)/(1-VCR_bf*ve)*pop/1000 //mortality double check
	
	gen opvisit_noR = opvisit/1000*pop
	gen ipvisit_noR = ipvisit/1000*pop
	gen otc_noR = opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)/1000*pop
	gen mortality_noR = episode*MortalityHR*(1+MortalityRate)*pop/1000
	
	sum *_tiv* *_no*
	
	* total utlity loss for that group
	gen utility_OP_noR  = (utility_health-utility_OP)*opvisit_noR 
	gen utility_OP_tivR = (utility_health-utility_OP)*opvisit_tivR 
	gen utility_IP_noR  = (utility_health-utility_IP)*opvisit_noR 
	gen utility_IP_tivR = (utility_health-utility_IP)*opvisit_tivR 
	gen utility_oct_noR  = 0.05*opvisit_noR 
	gen utility_oct_tivR = 0.05*opvisit_tivR 
	gen utility_mortality_noR  = utility_health*mortality_no
	gen utility_mortality_tivR =  utility_health*mortality_tiv
	
	* total cost for that group
	gen cost_OP_noR  = OP_directcost * opvisit_noR
	gen cost_OP_tivR = OP_directcost * opvisit_tivR
	gen cost_IP_noR  =  IP_directcost * ipvisit_noR
	gen cost_IP_tivR = IP_directcost * ipvisit_tivR
	gen cost_oct_noR  = otccost * otc_noR
	gen cost_oct_tivR = otccost * otc_tivR
	gen cost_nondirectOP_noR  = OP_indirectcost * opvisit_noR 
	gen cost_nondirectOP_tivR =  OP_indirectcost * opvisit_tivR 
	gen cost_nondirectIP_noR  = IP_indirectcost * ipvisit_noR 
	gen cost_nondirectIP_tivR =  IP_indirectcost * ipvisit_tivR 
	gen cost_nonmedicalOP_noR  = OP_nomedicalcost * opvisit_noR 
	gen cost_nonmedicalOP_tivR =  OP_nomedicalcost * opvisit_tivR 
	gen cost_nonmedicalIP_noR  = IP_nomedicalcost * ipvisit_noR  
	gen cost_nonmedicalIP_tivR = IP_nomedicalcost * ipvisit_tivR 
	
	* vaccine cost 
	gen cost_vacc_tivR = (vaccine_govcost+vaccine_adminstration) * VCR_af * pop    if inrange(agegroup,70,100)
	replace cost_vacc_tivR = (vaccine_mktcost+vaccine_adminstration) * VCR_af * pop    if inrange(agegroup,60,65)
	gen cost_vacc_noR =  (vaccine_mktcost+vaccine_adminstration) * VCR_bf * pop	
	
	* summary of the cost 
	*utility cost /
	gen utility_noA = utility_OP_no+utility_IP_no+utility_oct_no+utility_mortality_no
	gen utility_tivA = utility_OP_tiv+utility_IP_tiv+utility_oct_tiv+utility_mortality_tiv
	
	egen cost_nohealthA = rowtotal(cost_OP_no cost_IP_no cost_oct_no  cost_nonmedicalOP_no cost_nonmedicalIP_no cost_vacc_no)
	
	egen cost_tivhealthA = rowtotal(cost_OP_tiv cost_IP_tiv cost_oct_tiv  cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv cost_vacc_tiv)

	egen cost_nosocialA = rowtotal(cost_OP_no cost_IP_no cost_oct_no cost_nondirectIP_no cost_nondirectOP_no cost_nonmedicalOP_no cost_nonmedicalIP_no cost_vacc_no)
	
	egen cost_tivsocialA = rowtotal(cost_OP_tiv cost_IP_tiv cost_oct_tiv cost_nondirectIP_tiv cost_nondirectOP_tiv cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv cost_vacc_tiv)
		
	* gap 
	gen utility_gap = utility_noA - utility_tivA
	gen cost_health_gap = cost_tivhealthA-cost_nohealthA
	gen cost_social_gap = cost_tivsocialA-cost_nosocialA
		
	* ICER
	gen ICER_tivno_healthA = cost_health_gap/utility_gap
	gen ICER_tivno_socialA = cost_social_gap/utility_gap
	
	sum ICER* utility_gap  cost_health_gap cost_social_gap
	
	
	recode  riskgroup (1=0) (0=1)
	egen agerisk = group(agegroup riskgroup)
	
	*Appendix Table S6C+S6D combined
	gen Hper = .
	gen Sper = .
	sum utility_gap  Hper  cost_health_gap  ICER_tivno_healthA   Sper cost_social_gap  ICER_tivno_socialA 
	
	keep agegroup riskgroup agerisk utility_gap  Hper  cost_health_gap  ICER_tivno_healthA   Sper cost_social_gap  ICER_tivno_socialA  
	
	order agerisk utility_gap  Hper  cost_health_gap  ICER_tivno_healthA   Sper cost_social_gap  ICER_tivno_socialA  
	foreach k in utility_gap  Hper  cost_health_gap  ICER_tivno_healthA   Sper cost_social_gap  ICER_tivno_socialA  {
		replace `k' = round(`k',0.1)
	}
	sort agerisk
	
	*** Table S16
	table1 ,by(agerisk) vars( utility_gap contn\  cost_health_gap contn\ ICER_tivno_healthA  contn\  cost_social_gap contn\ ICER_tivno_socialA contn\ )  format(%2.1f) saving("tableS16.xls", replace)
	
	
	
************************************************
********** basecase  : Health, QALY and Cost  outcomes by program
************************************************	
import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear
	drop if agegroup == .
* basecase analyses	
	* incidence case
	gen opvisit_tivR = opvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop // 
	gen ipvisit_tivR = ipvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen otc_tivR =  opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen mortality_tivR = episode*MortalityHR*(1+MortalityRate)*(1-VCR_af*ve)/(1-VCR_bf*ve)*pop/1000 //mortality double check
	
	gen opvisit_noR = opvisit/1000*pop
	gen ipvisit_noR = ipvisit/1000*pop
	gen otc_noR = opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)/1000*pop
	gen mortality_noR = episode*MortalityHR*(1+MortalityRate)*pop/1000
	
	sum *_tiv* *_no*
	
	* total utlity loss for that group
	gen utility_OP_noR  = (utility_health-utility_OP)*opvisit_noR 
	gen utility_OP_tivR = (utility_health-utility_OP)*opvisit_tivR 
	gen utility_IP_noR  = (utility_health-utility_IP)*opvisit_noR 
	gen utility_IP_tivR = (utility_health-utility_IP)*opvisit_tivR 
	gen utility_oct_noR  = 0.05*opvisit_noR 
	gen utility_oct_tivR = 0.05*opvisit_tivR 
	gen utility_mortality_noR  = utility_health*mortality_no
	gen utility_mortality_tivR =  utility_health*mortality_tiv
	
	* total cost for that group
	gen cost_OP_noR  = OP_directcost * opvisit_noR
	gen cost_OP_tivR = OP_directcost * opvisit_tivR
	gen cost_IP_noR  =  IP_directcost * ipvisit_noR
	gen cost_IP_tivR = IP_directcost * ipvisit_tivR
	gen cost_oct_noR  = otccost * otc_noR
	gen cost_oct_tivR = otccost * otc_tivR
	gen cost_nondirectOP_noR  = OP_indirectcost * opvisit_noR 
	gen cost_nondirectOP_tivR =  OP_indirectcost * opvisit_tivR 
	gen cost_nondirectIP_noR  = IP_indirectcost * ipvisit_noR 
	gen cost_nondirectIP_tivR =  IP_indirectcost * ipvisit_tivR 
	gen cost_nonmedicalOP_noR  = OP_nomedicalcost * opvisit_noR 
	gen cost_nonmedicalOP_tivR =  OP_nomedicalcost * opvisit_tivR 
	gen cost_nonmedicalIP_noR  = IP_nomedicalcost * ipvisit_noR  
	gen cost_nonmedicalIP_tivR = IP_nomedicalcost * ipvisit_tivR 
	
	gen cost_nonmedical_tivR = cost_nonmedicalOP_tivR + cost_nonmedicalIP_tivR
	gen cost_nonmedical_noR =  cost_nonmedicalOP_noR + cost_nonmedicalIP_noR
	
	gen cost_nondirect_tivR = cost_nondirectOP_tivR + cost_nondirectIP_tivR
	gen cost_nondirect_noR =  cost_nondirectOP_noR + cost_nondirectIP_noR
	
	* vaccine cost 
	gen cost_vacc_tivR = (vaccine_govcost+vaccine_adminstration) * VCR_af * pop    if inrange(agegroup,65,100)
	replace cost_vacc_tivR = (vaccine_mktcost+vaccine_adminstration) * VCR_af * pop    if agegroup == 60
	gen cost_vacc_noR =  (vaccine_mktcost+vaccine_adminstration) * VCR_bf * pop	
	
	*aggregrate risk group
	foreach k in opvisit_no ipvisit_no otc_no utility_OP_no utility_IP_no utility_oct_no cost_OP_no cost_IP_no cost_oct_no cost_nondirectOP_no cost_nondirectIP_no cost_nonmedicalOP_no cost_nonmedicalIP_no opvisit_tiv ipvisit_tiv otc_tiv utility_OP_tiv utility_IP_tiv utility_oct_tiv cost_OP_tiv cost_IP_tiv cost_oct_tiv cost_nondirectOP_tiv cost_nondirectIP_tiv cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv utility_mortality_tiv utility_mortality_no mortality_no mortality_tiv cost_vacc_tiv  cost_vacc_no cost_nonmedical_no cost_nonmedical_tiv cost_nondirect_tiv cost_nondirect_no{
		bysort agegroup : egen sumage_`k' = sum(`k'R)
	}	
	
	keep agegroup sumage_*  
	duplicates drop
	
	* summary of the cost 
	*utility cost 
	gen sumage_utility_noA = sumage_utility_OP_no+sumage_utility_IP_no+sumage_utility_oct_no+sumage_utility_mortality_no
	gen sumage_utility_tivA = sumage_utility_OP_tiv+sumage_utility_IP_tiv+sumage_utility_oct_tiv+sumage_utility_mortality_tiv
	
	egen sumage_cost_nohealthA = rowtotal(sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no  sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_cost_vacc_no)
	
	egen sumage_cost_tivhealthA = rowtotal(sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv  sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_cost_vacc_tiv)

	egen sumage_cost_nosocialA = rowtotal(sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no sumage_cost_nondirectIP_no sumage_cost_nondirectOP_no sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_cost_vacc_no)
	
	egen sumage_cost_tivsocialA = rowtotal(sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv sumage_cost_nondirectIP_tiv sumage_cost_nondirectOP_tiv sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_cost_vacc_tiv)
	
	drop if agegroup == 60
		
	collapse (sum) * 
	
	rename (sumage_opvisit_no sumage_ipvisit_no sumage_otc_no sumage_utility_OP_no sumage_utility_IP_no sumage_utility_oct_no sumage_cost_OP_no sumage_cost_IP_no sumage_cost_oct_no sumage_cost_nondirectOP_no sumage_cost_nondirectIP_no sumage_cost_nonmedicalOP_no sumage_cost_nonmedicalIP_no sumage_utility_mortality_no sumage_mortality_no sumage_cost_vacc_no sumage_utility_noA sumage_cost_nohealthA sumage_cost_nosocialA sumage_cost_nondirect_no sumage_cost_nonmedical_no) (sumage_opvisit_0 sumage_ipvisit_0 sumage_otc_0 sumage_utility_OP_0 sumage_utility_IP_0 sumage_utility_oct_0 sumage_cost_OP_0 sumage_cost_IP_0 sumage_cost_oct_0 sumage_cost_nondirectOP_0 sumage_cost_nondirectIP_0 sumage_cost_nonmedicalOP_0 sumage_cost_nonmedicalIP_0   sumage_utility_mortality_0 sumage_mortality_0 sumage_cost_vacc_0 sumage_utility_0 sumage_costhealth_0 sumage_costsocial_0 sumage_cost_nondirect_0 sumage_cost_nonmedical_0)
	
	
	ren (sumage_opvisit_tiv sumage_ipvisit_tiv sumage_otc_tiv sumage_utility_OP_tiv sumage_utility_IP_tiv sumage_utility_oct_tiv sumage_cost_OP_tiv sumage_cost_IP_tiv sumage_cost_oct_tiv sumage_cost_nondirectOP_tiv sumage_cost_nondirectIP_tiv sumage_cost_nonmedicalOP_tiv sumage_cost_nonmedicalIP_tiv sumage_utility_mortality_tiv sumage_mortality_tiv sumage_cost_vacc_tiv sumage_utility_tivA sumage_cost_tivhealthA sumage_cost_tivsocialA sumage_cost_nondirect_tiv sumage_cost_nonmedical_tiv) (sumage_opvisit_1 sumage_ipvisit_1 sumage_otc_1 sumage_utility_OP_1 sumage_utility_IP_1 sumage_utility_oct_1 sumage_cost_OP_1 sumage_cost_IP_1 sumage_cost_oct_1 sumage_cost_nondirectOP_1 sumage_cost_nondirectIP_1 sumage_cost_nonmedicalOP_1 sumage_cost_nonmedicalIP_1 sumage_utility_mortality_1 sumage_mortality_1 sumage_cost_vacc_1 sumage_utility_1 sumage_costhealth_1 sumage_costsocial_1 sumage_cost_nondirect_1 sumage_cost_nonmedical_1)
	
	drop agegroup
	gen id = 1 
	
	reshape long sumage_opvisit_ sumage_ipvisit_ sumage_otc_ sumage_utility_OP_ sumage_utility_IP_ sumage_utility_oct_ sumage_cost_OP_ sumage_cost_IP_ sumage_cost_oct_ sumage_cost_nondirectOP_ sumage_cost_nondirectIP_ sumage_cost_nonmedicalOP_ sumage_cost_nonmedicalIP_ sumage_utility_mortality_ sumage_mortality_ sumage_cost_vacc_ sumage_utility_ sumage_costhealth_ sumage_costsocial_ sumage_cost_nondirect_ sumage_cost_nonmedical_, i(id) j(policy)
	
	*Table S15
	table1 ,by(policy) vars( sumage_opvisit_  contn\ sumage_ipvisit_  contn\ sumage_mortality_  contn\ sumage_utility_OP_  contn\ sumage_utility_IP_ contn\  sumage_utility_oct_ contn\  sumage_utility_mortality_   contn\ sumage_utility_  contn\ sumage_cost_OP_  contn\ sumage_cost_IP_  contn\ sumage_cost_oct_  contn\  sumage_cost_nonmedical_  contn\   sumage_cost_vacc_  contn\ sumage_costhealth_  contn\ sumage_cost_nondirect_ contn\  sumage_costsocial_  contn\ )     format(%2.1f) saving("tablebasecase_S15.xls", replace)
