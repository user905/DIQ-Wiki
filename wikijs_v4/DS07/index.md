## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1070259](/DIQs/DS07/1070259) | Negative MR Reprogramming | Is the MR reprogramming less than zero? | MR_rpg_dollars < 0. |
| [1070260](/DIQs/DS07/1070260) | OTB/OTS Date without MR | Is there an OTB/OTS date without MR? | MR_bgt_dollars = 0 when OTB_OTS_date exists. |
| [1070262](/DIQs/DS07/1070262) | Negative CBB | Is CBB negative? | CBB_dollars < 0. |
| [1070263](/DIQs/DS07/1070263) | CBB Not Equal to NCC Plus AUW | Is CBB not equal to NCC plus AUW? | CBB_dollars <> NCC_dollars + AUW_dollars. |
| [1070264](/DIQs/DS07/1070264) | PM EAC Best Date Earlier Than CPP SD | Is the PM EAC Best date earlier than the CPP Status Date? | EAC_PM_best_date < DS00.CPP_Status_Date. |
| [1070265](/DIQs/DS07/1070265) | Negative or Zero PM EAC Best Dollars | Is the PM EAC Best dollars value zero or negative? | EAC_PM_Best_dollars <= 0. |
| [1070266](/DIQs/DS07/1070266) | PM EAC Likely Date Earlier Than CPP SD | Is the PM EAC likely date earlier than the CPP Status Date? | EAC_PM_likely_date < DS00.CPP_Status_Date. |
| [1070267](/DIQs/DS07/1070267) | PM EAC Dates Chronology Issue | Are the PM EAC dates chronologically ordered as best, likely, worst? | EAC_PM_best_date >= EAC_PM_likely_date OR EAC_PM_likely_date >= EAC_PM_worst_date. |
| [1070268](/DIQs/DS07/1070268) | Negative or Zero PM EAC Likely Dollars | Is the PM EAC Likely dollars value zero or negative? | EAC_PM_Likely_dollars <= 0. |
| [1070269](/DIQs/DS07/1070269) | PM EAC Dollars Out of Order | Are the PM EAC dollars increasing in an order other than best, likely, worst? | EAC_PM_best_dollars >= EAC_PM_likely_dollars OR EAC_PM_likely_dollars >= EAC_PM_worst_dollars. |
| [1070270](/DIQs/DS07/1070270) | PM EAC Likely Dollars & CBB Issue | Are the PM EAC likely dollars greater than the CBB without an OTB/OTS? | EAC_PM_likely_dollars > CBB_dollars where OTB_OTS_date is missing. |
| [1070271](/DIQs/DS07/1070271) | PM EAC Worst Date Earlier Than CPP SD | Is the PM EAC Worst date earlier than the CPP Status Date? | EAC_PM_worst_date < DS00.CPP_Status_Date. |
| [1070272](/DIQs/DS07/1070272) | Negative or Zero PM EAC Worst Dollars | Is the PM EAC Worst dollars value zero or negative? | EAC_PM_worst_dollars <= 0. |
| [1070274](/DIQs/DS07/1070274) | Negative MR Budget | Is the MR budget less than zero? | MR_bgt_dollars < 0. |
| [1070275](/DIQs/DS07/1070275) | MR Reprogramming without OTB/OTS Date | Is there MR reprogramming without an OTB/OTS date? | MR_rpg_dollars > 0 & OTB_OTS_date missing. |
| [1070276](/DIQs/DS07/1070276) | Negative NCC | Is NCC negative? | NCC_dollars < 0. |
| [1070355](/DIQs/DS07/1070355) | Negative Profit Fee | Is profit fee negative? | profit_fee_dollars < 0. |
| [1070357](/DIQs/DS07/1070357) | Low Cost QRA | Is the quantitative risk analysis confidence level for cost less than 70%? | QRA_CL_cost_pct < .7. |
| [1070359](/DIQs/DS07/1070359) | Low Schedule QRA | Is the quantitative risk analysis confidence level for schedule less than 70%? | QRA_CL_schedule_pct < .7. |
| [1070360](/DIQs/DS07/1070360) | Negative TAB | Is the TAB negative? | TAB_dollars < 0. |
| [1070381](/DIQs/DS07/1070381) | Contract Type Missing | Is the contract type missing? | type = blank or missing. |
| [1070382](/DIQs/DS07/1070382) | Negative UB (Days) | Are the UB days negative? | UB_bgt_days < 0. |
| [1070383](/DIQs/DS07/1070383) | Negative UB (Dollars) | Are the UB dollars negative? | UB_bgt_dollars < 0. |
| [1070384](/DIQs/DS07/1070384) | Negative UB Estimated (Days) | Are the UB estimated days negative? | UB_est_days < 0. |
| [1070385](/DIQs/DS07/1070385) | Negative UB Estimated (Dollars) | Are the UB estimated dollars negative? | UB_est_dollars < 0. |
| [9070308](/DIQs/DS07/9070308) | PM EAC Likely Date After CD-4 | Is the PM EAC Likely date later than the CD-4 milestone? | EAC_PM_Likely_date > minimum DS04.EF_date where milestone_level = 190 (FC only). |
| [9070338](/DIQs/DS07/9070338) | OTB / OTS Without BAC Reprogramming | Is there an OTB/OTS date without BAC reprogramming? | OTB_OTS_date is not null/blank & SUM(DS03.BAC_rpg) = 0. |
| [9070339](/DIQs/DS07/9070339) | OTB / OTS Without CV Reprogramming | Is there an OTB/OTS date without CV reprogramming? | OTB_OTS_date is not null/blank & SUM(DS03.CV_rpg) = 0. |
| [9070340](/DIQs/DS07/9070340) | OTB / OTS Without Schedule Reprogramming | Is there an OTB/OTS date without schedule reprogramming? | OTB_OTS_date is not null/blank & COUNT(DS04.RPG = Y) = 0. |
| [9070341](/DIQs/DS07/9070341) | OTB / OTS Without SV Reprogramming | Is there an OTB/OTS date without SV reprogramming? | OTB_OTS_date is not null/blank & SUM(DS03.SV_rpg) = 0. |
| [9070351](/DIQs/DS07/9070351) | CBB Misaligned with PMB, MR, & Overrun | Is the stated CBB value in the IPMR header plus the cost Overrun equal to the PMB plus MR? | CBB_dollars <> PMB (DS03.DB + DS07.UB_bgt) + MR_bgt + MR_rpg - Overrun (Sum of DS03.BAC_rpg). |
| [9070361](/DIQs/DS07/9070361) | TAB Misaligned with BAC Repgrogramming & CBB | Does TAB equal something other than CBB plus BAC Reprogramming? | TAB_dollars <> CBB_dollars + SUM(DS03.BAC_rpg). |
| [9070363](/DIQs/DS07/9070363) | UB Without UB Change Control | Are there UB dollars without UB transactions in the change control log? | UB_bgt_dollars <> 0 & no rows found in DS10 where category = UB. |
| [9070365](/DIQs/DS07/9070365) | 12 Months Since OTB-OTS Without BCP | Has it been twelve months since an OTB-OTS date without a BCP? | Minimum 12 month delta between CPP status date & OTB_OTS_date without DS09.type = BCP or DS04.milestone_level between 131 & 135. |
| [9070367](/DIQs/DS07/9070367) | QRA Confidence Level Low for Cost Following BCP | Is the QRA Confidence Level below 90% for cost following a BCP? | QRA_CL_cost_pct < .9 & count where DS09.type = BCP or where DS04.milestone_level between 131 & 135 > 0. |
| [9070368](/DIQs/DS07/9070368) | QRA Confidence Level Low for Schedule Following BCP | Is the QRA Confidence Level below 90% for schedule following a BCP? | QRA_CL_schedule_pct < .9 count where DS09.type = BCP or where DS04.milestone_level between 131 & 135 > 0. |
| [9070369](/DIQs/DS07/9070369) | PMB + MR <> CBB + Overrun | Are the PM and MR equal to something other than CBB plus overrun? | CBB_dollars != sum of DS08.budget_dollars + UB_bgt + MR_bgt + MR_rpg - sum DS03.BAC_rpg. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1070273](/DIQs/DS07/1070273) | High or Low Escalation Rate Percent | Is the escalation rate percentage exceptionally low (below 3%) or high (above 20%)? | escalation_rate_pct <= 0.03 or > 0.2. |
| [1070335](/DIQs/DS07/1070335) | UB Estimated Greater Than UB Budgeted (Days) | Is the UB estimated days amount greater than UB budgeted? | UB_est_days > UB_est_days. |
| [1070336](/DIQs/DS07/1070336) | UB Estimated Greater Than UB Budgeted (Dollars) | Is the UB estimated dollar amount greater than UB budgeted? | UB_est_dollars > UB_est_dollars. |
| [1070337](/DIQs/DS07/1070337) | MR Reprogramming | Is there MR reprogramming? | MR_rpg <> 0. |
| [1070342](/DIQs/DS07/1070342) | UB Budget Days without UB Budget Dollars | Are there UB budget days but no UB budget dollars? | UB_bgt_days <> 0 & UB_bgt_dollars = 0. |
| [1070343](/DIQs/DS07/1070343) | UB Budget without UB Estimate (Days) | Are there UB budget days but no UB estimated days? | UB_bgt_days <> 0 & UB_est_day = 0. |
| [1070344](/DIQs/DS07/1070344) | UB Budget Dollars without UB Budget Days | Are there UB budget dollars but no UB budget dayss? | UB_bgt_dollars <> 0 & UB_bgt_days = 0. |
| [1070345](/DIQs/DS07/1070345) | UB Budget without UB Estimate (Dollars) | Are there UB budget dollars but no UB estimated dollars? | UB_bgt_dollars <> 0 & UB_est_dollars = 0. |
| [1070346](/DIQs/DS07/1070346) | UB Estimated without UB Budget (Days) | Are there UB estimated days but no UB budget days? | UB_est_days <> 0 & UB_bgt_days = 0. |
| [1070347](/DIQs/DS07/1070347) | UB Estimated Days without UB Estimated Dollars | Are there UB estimated days but no UB estimated dollars? | UB_est_days <> 0 & UB_est_dollars = 0. |
| [1070348](/DIQs/DS07/1070348) | UB Estimated without UB Budget (Dollars) | Are there UB estimated dollars but no UB budget dollars? | UB_est_dollars <> 0 & UB_bgt_dollars = 0. |
| [1070349](/DIQs/DS07/1070349) | UB Estimated Dollars without UB Estimated Days | Are there UB estimated dollars but no UB estimated days? | UB_est_dollars <> 0 & UB_est_days = 0. |
| [1070354](/DIQs/DS07/1070354) | Zero Profit Fee | Is profit fee zero? | profit_fee_dollars = 0. |
| [1070356](/DIQs/DS07/1070356) | Over-Optimistic Cost QRA | Is the quantitative risk analysis confidence level for cost above 95%? | QRA_CL_cost_pct > .95. |
| [1070358](/DIQs/DS07/1070358) | Over-Optimistic Schedule QRA | Is the quantitative risk analysis confidence level for schedule above 95%? | QRA_CL_schedule_pct > .95. |
| [1070362](/DIQs/DS07/1070362) | Zero Favorable Cost Cum Dollar Threshold | Is the favorable cost cum dollar threshold equal to zero? | threshold_cost_cum_dollar_fav = 0. |
| [1070363](/DIQs/DS07/1070363) | Zero Unfavorable Cost Cum Dollar Threshold | Is the unfavorable cost cum dollar threshold equal to zero? | threshold_cost_cum_dollar_unfav = 0. |
| [1070364](/DIQs/DS07/1070364) | Zero Favorable Cost Cum Percent Threshold | Is the favorable cost cum percent threshold equal to zero? | threshold_cost_cum_pct_fav = 0. |
| [1070365](/DIQs/DS07/1070365) | Zero Unfavorable Cost Cum Percent Threshold | Is the unfavorable cost cum percent threshold equal to zero? | threshold_cost_cum_pct_unfav = 0. |
| [1070366](/DIQs/DS07/1070366) | Zero Favorable Cost Inc Dollar Threshold | Is the favorable cost inc dollar threshold equal to zero? | threshold_cost_inc_dollar_fav = 0. |
| [1070367](/DIQs/DS07/1070367) | Zero Unfavorable Cost Inc Dollar Threshold | Is the unfavorable cost inc dollar threshold equal to zero? | threshold_cost_inc_Dollar_unfav = 0. |
| [1070368](/DIQs/DS07/1070368) | Zero Favorable Cost Inc Percent Threshold | Is the favorable cost inc percent threshold equal to zero? | threshold_cost_inc_pct_fav = 0. |
| [1070369](/DIQs/DS07/1070369) | Zero Unfavorable Cost Inc Percent Threshold | Is the unfavorable cost inc percent threshold equal to zero? | threshold_cost_inc_pct_unfav = 0. |
| [1070370](/DIQs/DS07/1070370) | Zero Favorable Cost VAC Percent Threshold | Is the favorable cost VAC percent threshold equal to zero? | threshold_cost_VAC_pct_fav = 0. |
| [1070371](/DIQs/DS07/1070371) | Zero Unfavorable Cost VAC Percent Threshold | Is the unfavorable cost VAC percent threshold equal to zero? | threshold_cost_VAC_pct_unfav = 0. |
| [1070372](/DIQs/DS07/1070372) | Zero Favorable Schedule Cum Dollar Threshold | Is the favorable schedule cum dollar threshold equal to zero? | threshold_schedule_cum_dollar_fav = 0. |
| [1070373](/DIQs/DS07/1070373) | Zero Unfavorable Schedule Cum Dollar Threshold | Is the unfavorable schedule cum dollar threshold equal to zero? | threshold_schedule_cum_dollar_unfav = 0. |
| [1070374](/DIQs/DS07/1070374) | Zero Favorable Schedule Cum Percent Threshold | Is the favorable schedule cum percent threshold equal to zero? | threshold_schedule_cum_pct_fav = 0. |
| [1070375](/DIQs/DS07/1070375) | Zero Unfavorable Schedule Cum Percent Threshold | Is the unfavorable schedule cum percent threshold equal to zero? | threshold_schedule_cum_pct_unfav = 0. |
| [1070376](/DIQs/DS07/1070376) | Zero Favorable Schedule Inc Dollar Threshold | Is the favorable schedule inc dollar threshold equal to zero? | threshold_schedule_inc_dollar_fav = 0. |
| [1070377](/DIQs/DS07/1070377) | Zero Unfavorable Schedule Inc Dollar Threshold | Is the unfavorable schedule inc dollar threshold equal to zero? | threshold_schedule_inc_Dollar_unfav = 0. |
| [1070378](/DIQs/DS07/1070378) | Zero Favorable Schedule Inc Percent Threshold | Is the favorable schedule inc percent threshold equal to zero? | threshold_schedule_inc_pct_fav = 0. |
| [1070379](/DIQs/DS07/1070379) | Zero Unfavorable Schedule Inc Percent Threshold | Is the unfavorable schedule inc percent threshold equal to zero? | threshold_schedule_inc_pct_unfav = 0. |
| [1070380](/DIQs/DS07/1070380) | CPE Contract Type | Is this a CPE contract type? | type = CPE. |
| [1070389](/DIQs/DS07/1070389) | Zero Favorable Cost VAC Dollar Threshold | Is the favorable cost VAC dollar threshold equal to zero? | threshold_cost_VAC_dollar_fav = 0. |
| [1070390](/DIQs/DS07/1070390) | Zero Unfavorable Cost VAC Dollar Threshold | Is the unfavorable cost VAC dollar threshold equal to zero? | threshold_cost_VAC_dollar_unfav = 0. |
| [9070302](/DIQs/DS07/9070302) | PM EAC Likely Misaligned with Calculated EAC | Is the PM EAC Likely dollars value less than the cost-calculated EAC? | EAC_PM_Likely_dollars < sum of DS03.ACWPc + DS03.ETCc + DS07.UB_est_dollars. |
| [9070303](/DIQs/DS07/9070303) | PM EAC Best Date Misaligned with Cost Estimates | Is the PM EAC Best date earlier than the last recorded ETC plus estimated UB? | EAC_PM_best_date < last DS03.period_date where ETCi > 0 (hours, dollars, or FTEs) + DS07.UB_EST_days. |
| [9070304](/DIQs/DS07/9070304) | PM EAC Best Date Prior to End of PMB Milestone | Is the PM EAC Best date earlier than the End of PMB milestone? | EAC_PM_Best < minimum DS04.EF_date where milestone_level = 175 (BL or FC). |
| [9070305](/DIQs/DS07/9070305) | PM EAC Likely Date Misaligned with Cost Estimates | Is the PM EAC likely date earlier than the last recorded ETC plus estimated UB? | EAC_PM_likely < last DS03.period_date where ETCi > 0 (hours, dollars, or FTEs) + DS07.UB_EST_days. |
| [9070306](/DIQs/DS07/9070306) | PM EAC Likely Date Prior to End of PMB Milestone | Is the PM EAC Likely date earlier than the End of PMB milestone? | EAC_PM_Likely < minimum DS04.EF_date where milestone_level = 170 (BL or FC). |
| [9070307](/DIQs/DS07/9070307) | PM EAC Likely Date After Contract Completion | Is the PM EAC Likely date later than the Contract Completion milestone? | EAC_PM_Likely_date > minimum DS04.EF_date where milestone_level = 180 (FC only). |
| [9070310](/DIQs/DS07/9070310) | RPG without OTB/OTS Date | Are there RPG tasks without an OTB/OTS Date? | DS04 tasks with RPG = Y found without DS07.OTB_OTS_Date. |
| [9070350](/DIQs/DS07/9070350) | PM EAC Best Misaligned with Calculated EAC | Is the PM EAC Best dollars value less than the cost-calculated EAC? | EAC_PM_Best_dollars < sum of DS03.ACWPc + DS03.ETCc + DS07.UB_est_dollars. |
| [9070353](/DIQs/DS07/9070353) | PM EAC Worst Date Later Than CD-4 | Is the PM EAC Worst date later than the CD-4 milestone date? | EAC_PM_worst_date > DS04.EF_date where milestone_level = 190 (FC only). |
| [9070362](/DIQs/DS07/9070362) | EAC PM Likely Incommensurate with WAD BAC | Is the EAC PM likely considerably different from the BAC as reported in the WADs? | |(EAC_PM_likey_dollars - sum of DS08.budget_[EOC]_dollars) / sum of DS08.budget_[EOC]_dollars)| > .1 (Or delta > $1,000 where either value = 0). |
| [9070364](/DIQs/DS07/9070364) | EAC > BAC without OTB / OTS Date | Is EAC greater than BAC without an OTB / OTS date? | DS03.ACWPc + DS03.ETCc > DS03.BCWSc & OTB_OTS_date is missing or blank. |
| [9070366](/DIQs/DS07/9070366) | Profit Fee Misaligned With CC Log Detail | Is profit fee misaligned with the dollars delta for profit fee transactions in the CC log detail? | profit_fee_dollars <> sum of DS10.dollars_delta where category = profit-fee. |
