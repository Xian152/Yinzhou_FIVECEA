****************************
* Sensitivity Analyses： Monte Carlo Sampling
****************************	
	* beta distribution
	foreach k in utility_OP utility_IP utility_health VCR_af opvisit ipvisit ve   MortalityRate MortalityHR    {
		foreach group  in  1 2 3 4 5 6 7 8 9 10 11 12  {
		import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear
		replace opvisit  = opvisit/1000
		replace ipvisit = ipvisit/1000 
		replace MortalityHR  = MortalityHR/1000 
			drop if agegroup == .
			sort agegroup riskgroup
			egen group = group( agegroup riskgroup)	
			keep if group == `group'
			sum `k' 
			local mean = r(mean)  
			local sd = `mean'/10
			local alpha = `mean' * ((`mean' * (1 - `mean') / (`sd'^2)) - 1)
			local beta = (1 - `mean') * ((`mean' * (1 - `mean') / (`sd'^2)) - 1)		
			
			clear
			set obs 10000
			
			generate `k' = rbeta(`alpha',`beta')
			
			gen group = `group'
			gen order = _n
			tempfile `k'_`group'
			cap replace opvisit  = opvisit*1000
			cap replace ipvisit = ipvisit*1000 
			cap replace MortalityHR  = MortalityHR*1000 
		save ``k'_`group'',replace
		}
	}
	
	foreach k in  ipvisit  {
		foreach group  in  1 3  {
		import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear
			drop if agegroup == .
			sort agegroup riskgroup
			egen group = group( agegroup riskgroup)	
			keep if group == `group'
			sum `k' 
			local mean = r(mean)  
			local sd = `mean'/10
			local alpha = `mean' * ((`mean' * (1 - `mean') / (`sd'^2)) - 1)
			local beta = (1 - `mean') * ((`mean' * (1 - `mean') / (`sd'^2)) - 1)		
			
			clear
			set obs 10000
			
			generate `k' = rbeta(`alpha',`beta')
			
			gen group = `group'
			gen order = _n
		save ``k'_`group'',replace
		}
	}		
	
	foreach k in  MortalityHR    {
		foreach group  in  1 2 3 4 5 6  9 10 11 12  {
		import excel "ceaparameter_old.xlsx", sheet("Sheet1") firstrow clear
			drop if agegroup == .
			sort agegroup riskgroup
			egen group = group( agegroup riskgroup)	
			keep if group == `group'
			sum `k' 
			local mean = r(mean)  
			local sd = `mean'/10
			local alpha = `mean' * ((`mean' * (1 - `mean') / (`sd'^2)) - 1)
			local beta = (1 - `mean') * ((`mean' * (1 - `mean') / (`sd'^2)) - 1)		
			
			clear
			set obs 10000
			
			generate `k' = rbeta(`alpha',`beta')
			
			gen group = `group'
			gen order = _n
		save ``k'_`group'',replace
		}
	}	
	
	foreach k in utility_OP utility_IP utility_health VCR_af opvisit ipvisit ve   MortalityRate MortalityHR    {
		use ``k'_1',clear	
			append using ``k'_2'  ``k'_3'  ``k'_4'  ``k'_5'  ``k'_6'  ``k'_7'  ``k'_8'  ``k'_9'  ``k'_10'  ``k'_11'  ``k'_12'
			tempfile `k'
		save ``k'',replace
	}
	
	tempfile t1
	
use `utility_OP',clear		
	foreach k in  utility_IP utility_health VCR_af opvisit ipvisit ve   MortalityRate MortalityHR    {
		merge 1:1 group order using ``k''
		drop _m
save `t1',replace	
	}

	
	* gamma distribution	
	foreach k in OP_directcost IP_directcost OP_indirectcost IP_indirectcost OP_nomedicalcost IP_nomedicalcost otccost vaccine_mktcost vaccine_govcost vaccine_adminstration   {
		forvalues group  = 1/12 {
			import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear
				drop if agegroup == .
				sort agegroup riskgroup
				egen group = group( agegroup riskgroup)	
				keep if group == `group'
				sum `k' 
				local mean = r(mean)  
				local sd = `mean'/10
				local shape = (`mean'^2) / (`sd'^2)
				local scale = (`sd'^2) / `mean'	
				clear
				set obs 10000
				
				generate `k' = rgamma(`shape', `scale')
				
				gen group = `group'
				gen order = _n
				tempfile `k'_`group'
			save ``k'_`group'',replace
			}
		}
	
	* gamma distribution
	foreach k in OP_directcost IP_directcost OP_indirectcost IP_indirectcost OP_nomedicalcost IP_nomedicalcost otccost vaccine_mktcost vaccine_govcost vaccine_adminstration   {
		use ``k'_1',clear	
			append using ``k'_2'  ``k'_3'  ``k'_4'  ``k'_5'  ``k'_6'  ``k'_7'  ``k'_8'  ``k'_9'  ``k'_10'  ``k'_11'  ``k'_12'
			tempfile `k'
		save ``k'',replace
	}
	
	tempfile t2
	
use `OP_directcost',clear		
	foreach k in   IP_directcost OP_indirectcost IP_indirectcost OP_nomedicalcost IP_nomedicalcost otccost vaccine_mktcost vaccine_govcost vaccine_adminstration   {
		merge 1:1 group order using ``k''
		drop _m
	save `t2',replace	
	}
	
*combine all parameters
	use `t1',clear
		merge 1:1 group order using `t2'
		drop _m
	save `t2',replace	
	
	import excel "ceaparameter.xlsx", sheet("Sheet1") firstrow clear
		drop utility_OP utility_IP utility_health VCR_af opvisit ipvisit ve   MortalityRate MortalityHR   OP_directcost IP_directcost OP_indirectcost IP_indirectcost OP_nomedicalcost IP_nomedicalcost otccost vaccine_mktcost vaccine_govcost vaccine_adminstration 
		drop if agegroup == .
		sort agegroup riskgroup
		egen group = group( agegroup riskgroup)	
		merge 1:m group using `t2'
		drop _m
save 	"Sensitivity_monte_carlo.dta",replace
	
****************************
* Sensitivity Analyses： calculate CEA for Monte Carlo Sampling
****************************			
use "Sensitivity_monte_carlo.dta",clear		
	count //120,000
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
	
	* vaccine cost 
	gen cost_vacc_tivR = (vaccine_govcost+vaccine_adminstration) * VCR_af * pop    if inrange(agegroup,70,100)
	replace cost_vacc_tivR = (vaccine_mktcost+vaccine_adminstration) * VCR_af * pop    if inrange(agegroup,60,65)
	gen cost_vacc_noR =  (vaccine_mktcost+vaccine_adminstration) * VCR_bf * pop	
		
	*aggregrate risk group
	foreach k in opvisit_no ipvisit_no otc_no utility_OP_no utility_IP_no utility_oct_no cost_OP_no cost_IP_no cost_oct_no cost_nondirectOP_no cost_nondirectIP_no cost_nonmedicalOP_no cost_nonmedicalIP_no opvisit_tiv ipvisit_tiv otc_tiv utility_OP_tiv utility_IP_tiv utility_oct_tiv cost_OP_tiv cost_IP_tiv cost_oct_tiv cost_nondirectOP_tiv cost_nondirectIP_tiv cost_nonmedicalOP_tiv cost_nonmedicalIP_tiv utility_mortality_tiv utility_mortality_no mortality_no mortality_tiv cost_vacc_tiv  cost_vacc_no {
		bysort agegroup order: egen sumage_`k' = sum(`k'R)
	}	
	
	keep agegroup order sumage_*  
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
		
	* basecase ananlyses results

	drop if agegroup == 60	
	collapse (sum)  sumage_utility_noA sumage_utility_tivA  sumage_utility_gap sumage_cost_health_gap  sumage_cost_social_gap ,by(order)

	gen ICER_tivno_healthA = sumage_cost_health_gap/sumage_utility_gap
	gen ICER_tivno_socialA = sumage_cost_social_gap/sumage_utility_gap
	
	sum ICER*	
	
	gen wtp1 = ICER_tivno_socialA<= 22871.87 
	gen wtp15 = ICER_tivno_socialA<=  34307.81  
	gen hwtp1 = ICER_tivno_healthA<= 22871.87 
	gen hwtp15 = ICER_tivno_healthA<=  34307.81  
	
	label variable sumage_cost_social_gap "Societal Perspective"
	label variable ICER_tivno_healthA "Health System Perspective"
	label variable ICER_tivno_socialA	 "Societal Perspective"
	label variable sumage_cost_health_gap "Health System Perspective"

save 	"sensitivity_monte_carlo_forfigure.dta",replace

****************************
* Sensitivity Analyses： Monte Carlo Figure: Figure 2
****************************	
use "sensitivity_monte_carlo_forfigure.dta",clear
	graph twoway (scatter sumage_cost_health_gap sumage_utility_gap ) (scatter sumage_cost_social_gap sumage_utility_gap ) ///
		(function y =22871.87*x, range(0 25)) (function y = 34307.81 *x, range(0 20)) ///
		(scatteri  500000 40  "WTP = 22871.9 USD/QALY"  , mlabsize(vsmall) msymbol(i) mlabposition(20) mlabcolor(black) ) ///
		(scatteri  680000 22  "WTP = 34307.8  USD/QALY"  , mlabsize(vsmall) msymbol(i) mlabposition(25) mlabcolor(black) ), ///
		xtitle("Incremental Costs (USD)" ,size(small))  ytitle("Incremental QALYs",size(small)) title("") xlabel(0(10)60) ylabel(0(100000)700000) legend(size(small) order(1 2) row(1) pos(6) ) title("TIV vs. No Policy")
		
	graph save "Figure_2.gph",replace
	graph export "Figure_2.png",replace
	graph export "Figure_2.tiff", as(tif) replace
