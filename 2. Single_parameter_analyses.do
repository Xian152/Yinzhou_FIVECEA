**********************************************************************	
* Sensitivity analyses :single parameter， upper bound
****************************************************************		
	foreach para in opvisit ve ipvisit   MortalityRate MortalityHR utility_health utility_OP utility_IP   OP_directcost IP_directcost OP_indirectcost IP_indirectcost OP_nomedicalcost IP_nomedicalcost otccost  VCR_af vaccine_mktcost vaccine_govcost vaccine_adminstration{
import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear
	drop if agegroup == .	
	if !inlist(`para',ve,VCR_af){
		replace `para' = `para'*1.2
	}
	if inlist(`para',ve){
		replace `para' = 0.593
	}	
	if inlist(`para',VCR_af){
		replace `para' = 0.75
	}		
* basecase analyses	
	* incidence case
	gen opvisit_tivR = opvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop //
	gen ipvisit_tivR = ipvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen otc_tivR =  opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen mortality_tivR = episode*MortalityHR*(1+MortalityRate)*(1-VCR_af*ve)/(1-VCR_bf*ve)*pop/1000  //mortality double check
	
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
	
	*aggregrate risk group
	foreach k in opvisit_no ipvisit_no otc_no utility_OP_no utility_IP_no utility_oct_no cost_OP_no cost_IP_no cost_oct_no cost_nondirectOP_no cost_nondirectIP_no cost_nonmedicalOP_no cost_nonmedicalIP_no opvisit_tiv ipvisit_tiv otc_tiv utility_OP_tiv utility_IP_tiv utility_oct_tiv cost_OP_tiv cost_IP_tiv cost_oct_tiv cost_nondirectOP_tiv cost_nondirectIP_tiv cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv utility_mortality_tiv utility_mortality_no mortality_no mortality_tiv cost_vacc_tiv  cost_vacc_no {
		bysort agegroup : egen sumage_`k' = sum(`k'R)
	}	
	
	keep agegroup sumage_*  
	duplicates drop
	
	* sumage_mary of the cost 
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
		
	drop if agegroup ==60		
	collapse (sum) sumage_utility_gap sumage_cost_health_gap sumage_cost_social_gap		
			
	* ICER //
	gen ICER_tivno_healthA = sumage_cost_health_gap/sumage_utility_gap
	gen ICER_tivno_socialA = sumage_cost_social_gap/sumage_utility_gap
	
	sum ICER*
	
	* basecase ananlyses results
	tab ICER_tivno_healthA 
	tab ICER_tivno_socialA
	
	ren ICER_tivno_healthA ICER_hA_`para'_up
	ren ICER_tivno_socialA ICER_sA_`para'_up
		
	gen agegroup = 1 
	
	keep 	ICER_hA_`para'_up ICER_sA_`para'_up  agegroup
	tempfile `para'_increase 
save ``para'_increase',replace		
}	

*******************************************	
* Sensitivity analyses : combine all upper bound parameters
*******************************************	
tempfile t1	
use `opvisit_increase',clear	
	foreach k in  ve ipvisit   MortalityRate MortalityHR utility_health utility_OP utility_IP   OP_directcost IP_directcost OP_indirectcost IP_indirectcost OP_nomedicalcost IP_nomedicalcost otccost  VCR_af vaccine_mktcost vaccine_govcost vaccine_adminstration{
		merge 1:1 agegroup using ``k'_increase'
		drop _m
	save `t1',replace	
	}

*******************************************	
* Sensitivity analyses :single parameter， lower bound
*******************************************	
	foreach para in opvisit ve ipvisit   MortalityRate MortalityHR utility_health utility_OP utility_IP   OP_directcost IP_directcost OP_indirectcost IP_indirectcost OP_nomedicalcost IP_nomedicalcost otccost  VCR_af vaccine_mktcost vaccine_govcost vaccine_adminstration{
import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear
	drop if agegroup == .

	if !inlist(`para',ve){
		replace `para' = `para'*0.8
	}
	if inlist(`para',ve){
		replace `para' = 0.01
	}	


* basecase analyses	
	* incidence case
	gen opvisit_tivR = opvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop // 
	gen ipvisit_tivR = ipvisit*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen otc_tivR =  opvisit*(HS_OPOTC+HS_IPOTC+HS_OPIPOTC+HS_OTC)/(HS_OPonly+HS_OPOTC+HS_OPIPOTC+HS_OPIP)*(1-VCR_af*ve)/(1-VCR_bf*ve)/1000*pop
	gen mortality_tivR = episode*MortalityHR*(1+MortalityRate)*(1-VCR_af*ve)/(1-VCR_bf*ve)*pop/1000  //mortality double check
	
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
	
	
	*aggregrate risk group
	foreach k in opvisit_no ipvisit_no otc_no utility_OP_no utility_IP_no utility_oct_no cost_OP_no cost_IP_no cost_oct_no cost_nondirectOP_no cost_nondirectIP_no cost_nonmedicalOP_no cost_nonmedicalIP_no opvisit_tiv ipvisit_tiv otc_tiv utility_OP_tiv utility_IP_tiv utility_oct_tiv cost_OP_tiv cost_IP_tiv cost_oct_tiv cost_nondirectOP_tiv cost_nondirectIP_tiv cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv utility_mortality_tiv utility_mortality_no mortality_no mortality_tiv cost_vacc_tiv  cost_vacc_no {
		bysort agegroup : egen sumage_`k' = sum(`k'R)
	}	
	
	keep agegroup sumage_*  
	duplicates drop
	
	* sumage_mary of the cost 
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
		
	drop if agegroup ==60		
	collapse (sum) sumage_utility_gap sumage_cost_health_gap sumage_cost_social_gap		
			
	* ICER //
	gen ICER_tivno_healthA = sumage_cost_health_gap/sumage_utility_gap
	gen ICER_tivno_socialA = sumage_cost_social_gap/sumage_utility_gap
		
	sum ICER*
	
	* basecase ananlyses results
	tab ICER_tivno_healthA 
	tab ICER_tivno_socialA
	
	ren ICER_tivno_healthA ICER_hA_`para'_dw
	ren ICER_tivno_socialA ICER_sA_`para'_dw
	
	keep 	ICER_hA_`para'_dw ICER_sA_`para'_dw 
	gen agegroup = 1 
	tempfile `para'_decrease
save ``para'_decrease',replace			
}	

*******************************************	
* Sensitivity analyses :combine all lower bound parameters 
*******************************************	
tempfile t2
use `opvisit_decrease',clear	
	foreach k in  ve ipvisit   MortalityRate MortalityHR utility_health utility_OP utility_IP   OP_directcost IP_directcost OP_indirectcost IP_indirectcost OP_nomedicalcost IP_nomedicalcost otccost  VCR_af vaccine_mktcost vaccine_govcost vaccine_adminstration{
		merge 1:1 agegroup using ``k'_decrease'
		drop _m
	save `t2',replace	
	}	

*******************************************	
* Sensitivity analyses :单因素分析，汇总所有
*******************************************		
use `t1',clear
	merge 1:1 agegroup using `t2'
	drop _m
save "single_parameter.dta",replace
	
*******************************************	
* Sensitivity analyses :单因素分析，整理参数报告顺序
*******************************************			
use "single_parameter.dta",clear	
	collapse (sum) ICER_hA_opvisit_up ICER_sA_opvisit_up ICER_hA_ve_up ICER_sA_ve_up ICER_hA_ipvisit_up ICER_sA_ipvisit_up ICER_hA_MortalityRate_up ICER_sA_MortalityRate_up ICER_hA_MortalityHR_up ICER_sA_MortalityHR_up ICER_hA_utility_health_up ICER_sA_utility_health_up ICER_hA_utility_OP_up ICER_sA_utility_OP_up ICER_hA_utility_IP_up ICER_sA_utility_IP_up ICER_hA_OP_directcost_up ICER_sA_OP_directcost_up ICER_hA_IP_directcost_up ICER_sA_IP_directcost_up ICER_hA_OP_indirectcost_up ICER_sA_OP_indirectcost_up ICER_hA_IP_indirectcost_up ICER_sA_IP_indirectcost_up ICER_hA_OP_nomedicalcost_up ICER_sA_OP_nomedicalcost_up ICER_hA_IP_nomedicalcost_up ICER_sA_IP_nomedicalcost_up ICER_hA_otccost_up ICER_sA_otccost_up ICER_hA_VCR_af_up ICER_sA_VCR_af_up ICER_hA_vaccine_mktcost_up ICER_sA_vaccine_mktcost_up ICER_hA_vaccine_govcost_up ICER_sA_vaccine_govcost_up ICER_hA_vaccine_adminstration_up ICER_sA_vaccine_adminstration_up ICER_hA_opvisit_dw ICER_sA_opvisit_dw ICER_hA_ve_dw ICER_sA_ve_dw ICER_hA_ipvisit_dw ICER_sA_ipvisit_dw ICER_hA_MortalityRate_dw ICER_sA_MortalityRate_dw ICER_hA_MortalityHR_dw ICER_sA_MortalityHR_dw ICER_hA_utility_health_dw ICER_sA_utility_health_dw ICER_hA_utility_OP_dw ICER_sA_utility_OP_dw ICER_hA_utility_IP_dw ICER_sA_utility_IP_dw ICER_hA_OP_directcost_dw ICER_sA_OP_directcost_dw ICER_hA_IP_directcost_dw ICER_sA_IP_directcost_dw ICER_hA_OP_indirectcost_dw ICER_sA_OP_indirectcost_dw ICER_hA_IP_indirectcost_dw ICER_sA_IP_indirectcost_dw ICER_hA_OP_nomedicalcost_dw ICER_sA_OP_nomedicalcost_dw ICER_hA_IP_nomedicalcost_dw ICER_sA_IP_nomedicalcost_dw ICER_hA_otccost_dw ICER_sA_otccost_dw ICER_hA_VCR_af_dw ICER_sA_VCR_af_dw ICER_hA_vaccine_mktcost_dw ICER_sA_vaccine_mktcost_dw ICER_hA_vaccine_govcost_dw ICER_sA_vaccine_govcost_dw ICER_hA_vaccine_adminstration_dw ICER_sA_vaccine_adminstration_dw
	
	foreach k in ICER_hA_opvisit ICER_sA_opvisit ICER_hA_ve ICER_sA_ve ICER_hA_ipvisit ICER_sA_ipvisit ICER_hA_MortalityRate ICER_sA_MortalityRate ICER_hA_MortalityHR ICER_sA_MortalityHR ICER_hA_utility_health ICER_sA_utility_health ICER_hA_utility_OP ICER_sA_utility_OP ICER_hA_utility_IP ICER_sA_utility_IP ICER_hA_OP_directcost ICER_sA_OP_directcost ICER_hA_IP_directcost ICER_sA_IP_directcost ICER_hA_OP_indirectcost ICER_sA_OP_indirectcost ICER_hA_IP_indirectcost ICER_sA_IP_indirectcost ICER_hA_OP_nomedicalcost ICER_sA_OP_nomedicalcost ICER_hA_IP_nomedicalcost ICER_sA_IP_nomedicalcost ICER_hA_otccost ICER_sA_otccost ICER_hA_VCR_af ICER_sA_VCR_af ICER_hA_vaccine_mktcost ICER_sA_vaccine_mktcost ICER_hA_vaccine_govcost ICER_sA_vaccine_govcost ICER_hA_vaccine_adminstration ICER_sA_vaccine_adminstration{
		gen `k' = abs(`k'_dw - `k'_up)
	}	
	
	
	stack ICER_hA_opvisit ICER_sA_opvisit ICER_hA_ve ICER_sA_ve ICER_hA_ipvisit ICER_sA_ipvisit ICER_hA_MortalityRate ICER_sA_MortalityRate ICER_hA_MortalityHR ICER_sA_MortalityHR ICER_hA_utility_health ICER_sA_utility_health ICER_hA_utility_OP ICER_sA_utility_OP ICER_hA_utility_IP ICER_sA_utility_IP ICER_hA_OP_directcost ICER_sA_OP_directcost ICER_hA_IP_directcost ICER_sA_IP_directcost ICER_hA_OP_indirectcost ICER_sA_OP_indirectcost ICER_hA_IP_indirectcost ICER_sA_IP_indirectcost ICER_hA_OP_nomedicalcost ICER_sA_OP_nomedicalcost ICER_hA_IP_nomedicalcost ICER_sA_IP_nomedicalcost ICER_hA_otccost ICER_sA_otccost ICER_hA_VCR_af ICER_sA_VCR_af ICER_hA_vaccine_mktcost ICER_sA_vaccine_mktcost ICER_hA_vaccine_govcost ICER_sA_vaccine_govcost ICER_hA_vaccine_adminstration ICER_sA_vaccine_adminstration ,into(gap) wide
	
	
	gen parameter = ""
	
	foreach k in ICER_hA_opvisit ICER_sA_opvisit ICER_hA_ve ICER_sA_ve ICER_hA_ipvisit ICER_sA_ipvisit ICER_hA_MortalityRate ICER_sA_MortalityRate ICER_hA_MortalityHR ICER_sA_MortalityHR ICER_hA_utility_health ICER_sA_utility_health ICER_hA_utility_OP ICER_sA_utility_OP ICER_hA_utility_IP ICER_sA_utility_IP ICER_hA_OP_directcost ICER_sA_OP_directcost ICER_hA_IP_directcost ICER_sA_IP_directcost ICER_hA_OP_indirectcost ICER_sA_OP_indirectcost ICER_hA_IP_indirectcost ICER_sA_IP_indirectcost ICER_hA_OP_nomedicalcost ICER_sA_OP_nomedicalcost ICER_hA_IP_nomedicalcost ICER_sA_IP_nomedicalcost ICER_hA_otccost ICER_sA_otccost ICER_hA_VCR_af ICER_sA_VCR_af ICER_hA_vaccine_mktcost ICER_sA_vaccine_mktcost ICER_hA_vaccine_govcost ICER_sA_vaccine_govcost ICER_hA_vaccine_adminstration ICER_sA_vaccine_adminstration {
		replace parameter = "`k'" if gap == `k'
	} 
	order parameter
	keep if strmatch(parameter,"ICER_sA*")
	gsort -gap
	keep parameter gap
	gen order_sA = _n
save "single_parameter_order_sA.dta",replace
	
	
use "single_parameter.dta",clear	
	collapse (sum) ICER_hA_opvisit_up ICER_sA_opvisit_up ICER_hA_ve_up ICER_sA_ve_up ICER_hA_ipvisit_up ICER_sA_ipvisit_up ICER_hA_MortalityRate_up ICER_sA_MortalityRate_up ICER_hA_MortalityHR_up ICER_sA_MortalityHR_up ICER_hA_utility_health_up ICER_sA_utility_health_up ICER_hA_utility_OP_up ICER_sA_utility_OP_up ICER_hA_utility_IP_up ICER_sA_utility_IP_up ICER_hA_OP_directcost_up ICER_sA_OP_directcost_up ICER_hA_IP_directcost_up ICER_sA_IP_directcost_up ICER_hA_OP_indirectcost_up ICER_sA_OP_indirectcost_up ICER_hA_IP_indirectcost_up ICER_sA_IP_indirectcost_up ICER_hA_OP_nomedicalcost_up ICER_sA_OP_nomedicalcost_up ICER_hA_IP_nomedicalcost_up ICER_sA_IP_nomedicalcost_up ICER_hA_otccost_up ICER_sA_otccost_up ICER_hA_VCR_af_up ICER_sA_VCR_af_up ICER_hA_vaccine_mktcost_up ICER_sA_vaccine_mktcost_up ICER_hA_vaccine_govcost_up ICER_sA_vaccine_govcost_up ICER_hA_vaccine_adminstration_up ICER_sA_vaccine_adminstration_up ICER_hA_opvisit_dw ICER_sA_opvisit_dw ICER_hA_ve_dw ICER_sA_ve_dw ICER_hA_ipvisit_dw ICER_sA_ipvisit_dw ICER_hA_MortalityRate_dw ICER_sA_MortalityRate_dw ICER_hA_MortalityHR_dw ICER_sA_MortalityHR_dw ICER_hA_utility_health_dw ICER_sA_utility_health_dw ICER_hA_utility_OP_dw ICER_sA_utility_OP_dw ICER_hA_utility_IP_dw ICER_sA_utility_IP_dw ICER_hA_OP_directcost_dw ICER_sA_OP_directcost_dw ICER_hA_IP_directcost_dw ICER_sA_IP_directcost_dw ICER_hA_OP_indirectcost_dw ICER_sA_OP_indirectcost_dw ICER_hA_IP_indirectcost_dw ICER_sA_IP_indirectcost_dw ICER_hA_OP_nomedicalcost_dw ICER_sA_OP_nomedicalcost_dw ICER_hA_IP_nomedicalcost_dw ICER_sA_IP_nomedicalcost_dw ICER_hA_otccost_dw ICER_sA_otccost_dw ICER_hA_VCR_af_dw ICER_sA_VCR_af_dw ICER_hA_vaccine_mktcost_dw ICER_sA_vaccine_mktcost_dw ICER_hA_vaccine_govcost_dw ICER_sA_vaccine_govcost_dw ICER_hA_vaccine_adminstration_dw ICER_sA_vaccine_adminstration_dw
	
	foreach k in ICER_hA_opvisit ICER_sA_opvisit ICER_hA_ve ICER_sA_ve ICER_hA_ipvisit ICER_sA_ipvisit ICER_hA_MortalityRate ICER_sA_MortalityRate ICER_hA_MortalityHR ICER_sA_MortalityHR ICER_hA_utility_health ICER_sA_utility_health ICER_hA_utility_OP ICER_sA_utility_OP ICER_hA_utility_IP ICER_sA_utility_IP ICER_hA_OP_directcost ICER_sA_OP_directcost ICER_hA_IP_directcost ICER_sA_IP_directcost ICER_hA_OP_indirectcost ICER_sA_OP_indirectcost ICER_hA_IP_indirectcost ICER_sA_IP_indirectcost ICER_hA_OP_nomedicalcost ICER_sA_OP_nomedicalcost ICER_hA_IP_nomedicalcost ICER_sA_IP_nomedicalcost ICER_hA_otccost ICER_sA_otccost ICER_hA_VCR_af ICER_sA_VCR_af ICER_hA_vaccine_mktcost ICER_sA_vaccine_mktcost ICER_hA_vaccine_govcost ICER_sA_vaccine_govcost ICER_hA_vaccine_adminstration ICER_sA_vaccine_adminstration{
		gen `k' = abs(`k'_dw - `k'_up)
	}	
	
	
	stack ICER_hA_opvisit ICER_sA_opvisit ICER_hA_ve ICER_sA_ve ICER_hA_ipvisit ICER_sA_ipvisit ICER_hA_MortalityRate ICER_sA_MortalityRate ICER_hA_MortalityHR ICER_sA_MortalityHR ICER_hA_utility_health ICER_sA_utility_health ICER_hA_utility_OP ICER_sA_utility_OP ICER_hA_utility_IP ICER_sA_utility_IP ICER_hA_OP_directcost ICER_sA_OP_directcost ICER_hA_IP_directcost ICER_sA_IP_directcost ICER_hA_OP_indirectcost ICER_sA_OP_indirectcost ICER_hA_IP_indirectcost ICER_sA_IP_indirectcost ICER_hA_OP_nomedicalcost ICER_sA_OP_nomedicalcost ICER_hA_IP_nomedicalcost ICER_sA_IP_nomedicalcost ICER_hA_otccost ICER_sA_otccost ICER_hA_VCR_af ICER_sA_VCR_af ICER_hA_vaccine_mktcost ICER_sA_vaccine_mktcost ICER_hA_vaccine_govcost ICER_sA_vaccine_govcost ICER_hA_vaccine_adminstration ICER_sA_vaccine_adminstration ,into(gap) wide
	
	
	gen parameter = ""
	
	foreach k in ICER_hA_opvisit ICER_sA_opvisit ICER_hA_ve ICER_sA_ve ICER_hA_ipvisit ICER_sA_ipvisit ICER_hA_MortalityRate ICER_sA_MortalityRate ICER_hA_MortalityHR ICER_sA_MortalityHR ICER_hA_utility_health ICER_sA_utility_health ICER_hA_utility_OP ICER_sA_utility_OP ICER_hA_utility_IP ICER_sA_utility_IP ICER_hA_OP_directcost ICER_sA_OP_directcost ICER_hA_IP_directcost ICER_sA_IP_directcost ICER_hA_OP_indirectcost ICER_sA_OP_indirectcost ICER_hA_IP_indirectcost ICER_sA_IP_indirectcost ICER_hA_OP_nomedicalcost ICER_sA_OP_nomedicalcost ICER_hA_IP_nomedicalcost ICER_sA_IP_nomedicalcost ICER_hA_otccost ICER_sA_otccost ICER_hA_VCR_af ICER_sA_VCR_af ICER_hA_vaccine_mktcost ICER_sA_vaccine_mktcost ICER_hA_vaccine_govcost ICER_sA_vaccine_govcost ICER_hA_vaccine_adminstration ICER_sA_vaccine_adminstration {
		replace parameter = "`k'" if gap == `k'
	} 
	order parameter
	keep if strmatch(parameter,"ICER_hA*")
	gsort -gap
	keep parameter gap
	gen order_hA = _n
save "single_parameter_order_hA.dta",replace
	
use "single_parameter.dta",clear	
	collapse (sum) ICER_hA_opvisit_up ICER_sA_opvisit_up ICER_hA_ve_up ICER_sA_ve_up ICER_hA_ipvisit_up ICER_sA_ipvisit_up ICER_hA_MortalityRate_up ICER_sA_MortalityRate_up ICER_hA_MortalityHR_up ICER_sA_MortalityHR_up ICER_hA_utility_health_up ICER_sA_utility_health_up ICER_hA_utility_OP_up ICER_sA_utility_OP_up ICER_hA_utility_IP_up ICER_sA_utility_IP_up ICER_hA_OP_directcost_up ICER_sA_OP_directcost_up ICER_hA_IP_directcost_up ICER_sA_IP_directcost_up ICER_hA_OP_indirectcost_up ICER_sA_OP_indirectcost_up ICER_hA_IP_indirectcost_up ICER_sA_IP_indirectcost_up ICER_hA_OP_nomedicalcost_up ICER_sA_OP_nomedicalcost_up ICER_hA_IP_nomedicalcost_up ICER_sA_IP_nomedicalcost_up ICER_hA_otccost_up ICER_sA_otccost_up ICER_hA_VCR_af_up ICER_sA_VCR_af_up ICER_hA_vaccine_mktcost_up ICER_sA_vaccine_mktcost_up ICER_hA_vaccine_govcost_up ICER_sA_vaccine_govcost_up ICER_hA_vaccine_adminstration_up ICER_sA_vaccine_adminstration_up ICER_hA_opvisit_dw ICER_sA_opvisit_dw ICER_hA_ve_dw ICER_sA_ve_dw ICER_hA_ipvisit_dw ICER_sA_ipvisit_dw ICER_hA_MortalityRate_dw ICER_sA_MortalityRate_dw ICER_hA_MortalityHR_dw ICER_sA_MortalityHR_dw ICER_hA_utility_health_dw ICER_sA_utility_health_dw ICER_hA_utility_OP_dw ICER_sA_utility_OP_dw ICER_hA_utility_IP_dw ICER_sA_utility_IP_dw ICER_hA_OP_directcost_dw ICER_sA_OP_directcost_dw ICER_hA_IP_directcost_dw ICER_sA_IP_directcost_dw ICER_hA_OP_indirectcost_dw ICER_sA_OP_indirectcost_dw ICER_hA_IP_indirectcost_dw ICER_sA_IP_indirectcost_dw ICER_hA_OP_nomedicalcost_dw ICER_sA_OP_nomedicalcost_dw ICER_hA_IP_nomedicalcost_dw ICER_sA_IP_nomedicalcost_dw ICER_hA_otccost_dw ICER_sA_otccost_dw ICER_hA_VCR_af_dw ICER_sA_VCR_af_dw ICER_hA_vaccine_mktcost_dw ICER_sA_vaccine_mktcost_dw ICER_hA_vaccine_govcost_dw ICER_sA_vaccine_govcost_dw ICER_hA_vaccine_adminstration_dw ICER_sA_vaccine_adminstration_dw
	
	
	stack ICER_hA_opvisit_up ICER_sA_opvisit_up ICER_hA_ve_up ICER_sA_ve_up ICER_hA_ipvisit_up ICER_sA_ipvisit_up ICER_hA_MortalityRate_up ICER_sA_MortalityRate_up ICER_hA_MortalityHR_up ICER_sA_MortalityHR_up ICER_hA_utility_health_up ICER_sA_utility_health_up ICER_hA_utility_OP_up ICER_sA_utility_OP_up ICER_hA_utility_IP_up ICER_sA_utility_IP_up ICER_hA_OP_directcost_up ICER_sA_OP_directcost_up ICER_hA_IP_directcost_up ICER_sA_IP_directcost_up ICER_hA_OP_indirectcost_up ICER_sA_OP_indirectcost_up ICER_hA_IP_indirectcost_up ICER_sA_IP_indirectcost_up ICER_hA_OP_nomedicalcost_up ICER_sA_OP_nomedicalcost_up ICER_hA_IP_nomedicalcost_up ICER_sA_IP_nomedicalcost_up ICER_hA_otccost_up ICER_sA_otccost_up ICER_hA_VCR_af_up ICER_sA_VCR_af_up ICER_hA_vaccine_mktcost_up ICER_sA_vaccine_mktcost_up ICER_hA_vaccine_govcost_up ICER_sA_vaccine_govcost_up ICER_hA_vaccine_adminstration_up ICER_sA_vaccine_adminstration_up ICER_hA_opvisit_dw ICER_sA_opvisit_dw ICER_hA_ve_dw ICER_sA_ve_dw ICER_hA_ipvisit_dw ICER_sA_ipvisit_dw ICER_hA_MortalityRate_dw ICER_sA_MortalityRate_dw ICER_hA_MortalityHR_dw ICER_sA_MortalityHR_dw ICER_hA_utility_health_dw ICER_sA_utility_health_dw ICER_hA_utility_OP_dw ICER_sA_utility_OP_dw ICER_hA_utility_IP_dw ICER_sA_utility_IP_dw ICER_hA_OP_directcost_dw ICER_sA_OP_directcost_dw ICER_hA_IP_directcost_dw ICER_sA_IP_directcost_dw ICER_hA_OP_indirectcost_dw ICER_sA_OP_indirectcost_dw ICER_hA_IP_indirectcost_dw ICER_sA_IP_indirectcost_dw ICER_hA_OP_nomedicalcost_dw ICER_sA_OP_nomedicalcost_dw ICER_hA_IP_nomedicalcost_dw ICER_sA_IP_nomedicalcost_dw ICER_hA_otccost_dw ICER_sA_otccost_dw ICER_hA_VCR_af_dw ICER_sA_VCR_af_dw ICER_hA_vaccine_mktcost_dw ICER_sA_vaccine_mktcost_dw ICER_hA_vaccine_govcost_dw ICER_sA_vaccine_govcost_dw ICER_hA_vaccine_adminstration_dw ICER_sA_vaccine_adminstration_dw,into(value) wide
	
	
	gsort -value
	gen parameter = ""
	foreach k in ICER_hA_opvisit_up ICER_sA_opvisit_up ICER_hA_ve_up ICER_sA_ve_up ICER_hA_ipvisit_up ICER_sA_ipvisit_up ICER_hA_MortalityRate_up ICER_sA_MortalityRate_up ICER_hA_MortalityHR_up ICER_sA_MortalityHR_up ICER_hA_utility_health_up ICER_sA_utility_health_up ICER_hA_utility_OP_up ICER_sA_utility_OP_up ICER_hA_utility_IP_up ICER_sA_utility_IP_up ICER_hA_OP_directcost_up ICER_sA_OP_directcost_up ICER_hA_IP_directcost_up ICER_sA_IP_directcost_up ICER_hA_OP_indirectcost_up ICER_sA_OP_indirectcost_up ICER_hA_IP_indirectcost_up ICER_sA_IP_indirectcost_up ICER_hA_OP_nomedicalcost_up ICER_sA_OP_nomedicalcost_up ICER_hA_IP_nomedicalcost_up ICER_sA_IP_nomedicalcost_up ICER_hA_otccost_up ICER_sA_otccost_up ICER_hA_VCR_af_up ICER_sA_VCR_af_up ICER_hA_vaccine_mktcost_up ICER_sA_vaccine_mktcost_up ICER_hA_vaccine_govcost_up ICER_sA_vaccine_govcost_up ICER_hA_vaccine_adminstration_up ICER_sA_vaccine_adminstration_up ICER_hA_opvisit_dw ICER_sA_opvisit_dw ICER_hA_ve_dw ICER_sA_ve_dw ICER_hA_ipvisit_dw ICER_sA_ipvisit_dw ICER_hA_MortalityRate_dw ICER_sA_MortalityRate_dw ICER_hA_MortalityHR_dw ICER_sA_MortalityHR_dw ICER_hA_utility_health_dw ICER_sA_utility_health_dw ICER_hA_utility_OP_dw ICER_sA_utility_OP_dw ICER_hA_utility_IP_dw ICER_sA_utility_IP_dw ICER_hA_OP_directcost_dw ICER_sA_OP_directcost_dw ICER_hA_IP_directcost_dw ICER_sA_IP_directcost_dw ICER_hA_OP_indirectcost_dw ICER_sA_OP_indirectcost_dw ICER_hA_IP_indirectcost_dw ICER_sA_IP_indirectcost_dw ICER_hA_OP_nomedicalcost_dw ICER_sA_OP_nomedicalcost_dw ICER_hA_IP_nomedicalcost_dw ICER_sA_IP_nomedicalcost_dw ICER_hA_otccost_dw ICER_sA_otccost_dw ICER_hA_VCR_af_dw ICER_sA_VCR_af_dw ICER_hA_vaccine_mktcost_dw ICER_sA_vaccine_mktcost_dw ICER_hA_vaccine_govcost_dw ICER_sA_vaccine_govcost_dw ICER_hA_vaccine_adminstration_dw ICER_sA_vaccine_adminstration_dw{
		replace parameter = "`k'" if value == `k'
	}
	
	order parameter
	
	gen updn = "1up" if strmatch(parameter,"*_up")
	replace updn = "2dw" if strmatch(parameter,"*_dw")

	replace parameter = subinstr(parameter,"_dw","",.)
	replace parameter = subinstr(parameter,"_up","",.)
	keep  parameter value updn
	preserve
		keep if strmatch(parameter,"ICER_hA*")
		merge m:1 parameter  using  "single_parameter_order_hA.dta"
		drop _m
		save "single_parameter_fin_hA.dta",replace
	restore
	keep if strmatch(parameter,"ICER_sA*")
	merge m:1 parameter  using  "single_parameter_order_sA.dta"
	drop _m
	save "single_parameter_fin_sA.dta",replace

* single parameter analyses results: health system perspective 
use "single_parameter_fin_hA.dta",clear
	sort order_hA updn

* single parameter analyses results: social perspective 	
use "single_parameter_fin_sA.dta",clear
	sort order_sA updn
	