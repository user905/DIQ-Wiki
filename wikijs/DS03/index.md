## ERROR

| UID                           | Title                                                | Summary                                                                               | Error Message                                                                                                                                                                                                                                                                                         |
| ----------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [1030058](/DIQs/DS03/1030058) | Actuals At CA and WP Level                           | Are actuals collected at both the CA and WP level?                                    | CAs and WPs found with ACWPi <> 0 (Dollars, Hours, or FTEs)                                                                                                                                                                                                                                           |
| [1030072](/DIQs/DS03/1030072) | WP or PP with Multiple EVT Groups                    | Does this WP or PP have more than one EVT group?                                      | WP or PP where EVT group is not uniform (EVTs are not all LOE, Discrete, Apportioned, or Planning Package for this WP or PP data).                                                                                                                                                                    |
| [1030077](/DIQs/DS03/1030077) | Apportioned To WBS ID Missing                        | Is the WBS ID to which this work is apportioned missing?                              | EVT = J or M but EVT_J_to_WBS_ID is missing.                                                                                                                                                                                                                                                          |
| [1030106](/DIQs/DS03/1030106) | WP or PP Found Across Multiple CAs                   | Is the WP or PP found across multiple Control Accounts?                               | WBS_ID_WP found across distinct WBS_ID_CA.                                                                                                                                                                                                                                                            |
| [1030108](/DIQs/DS03/1030108) | Non-Unique Cost Row                                  | Is this row duplicated by period date, CA WBS ID, WP WBS ID, EOC, EVT, & is_indirect? | Count of period_date, WBS_ID_CA, WBS_ID_WP, EOC, EVT, is_indirect combo > 1.                                                                                                                                                                                                                          |
| [9030061](/DIQs/DS03/9030061) | Performance On SLPP, CA, or PP                       | Has this SLPP, CA, or PP collected performance?                                       | SLPP, CA, or PP found with BCWPi <> 0 (Dollars, Hours, or FTEs).                                                                                                                                                                                                                                      |
| [9030062](/DIQs/DS03/9030062) | CA with Budget                                       | Does this CA have budget?                                                             | CA found with BCWSi > 0 (Dollars, Hours, or FTEs).                                                                                                                                                                                                                                                    |
| [9030078](/DIQs/DS03/9030078) | Apportionment IDs Mismatch Between Cost and Schedule | Is the WBS ID to which this work is apportioned mismatched in cost and schedule?      | EVT = J or M where EVT_J_to_WBS_ID does not equal the WBS ID in Schedule.                                                                                                                                                                                                                             |
| [1030116](/DIQs/DS03/1030116) | Inconsistent Use of Indirect                         | Is indirect distributed inconsistently?                                               | Possible Reasons: 1) indirect actuals found where is_indirect = Y, and both EOC = Indirect and EOC <> Indirect are used; 2) is_indirect utilized in some WPs/CAs and missing in others; 3) indirect actuals found at both the CA & WP levels; 4) data found where is_indirect = N but EOC = Indirect. |

## WARNING

| UID                           | Title                                                             | Summary                                                                                                                       | Error Message                                                                                                                                                                        |
| ----------------------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- | --- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| [1030059](/DIQs/DS03/1030059) | Future Actuals                                                    | Were actuals collected in the future?                                                                                         | ACWPi <> 0 (Dollars, Hours, or FTEs) and period_date > cpp_status_date.                                                                                                              |
| [1030060](/DIQs/DS03/1030060) | Future Performance                                                | For this WP, was performance collected in the future?                                                                         | WP found with BCWPi <> 0 (Dollars, Hours, or FTEs) and period_date > cpp_status_date.                                                                                                |
| [1030064](/DIQs/DS03/1030064) | Estimates in the Past                                             | Are there estimates still showing in previous periods?                                                                        | ETCi <> 0 (Dollars, Hours, or FTEs) where period_date <= CPP_Status_Date.                                                                                                            |
| [1030067](/DIQs/DS03/1030067) | BCWSi <> BCWPi for LOE                                            | Is there a delta between BCWS and BCWP for this LOE work?                                                                     | BCWSi <> BCWPi for LOE work (Dollar, Hours, or FTEs).                                                                                                                                |
| [1030074](/DIQs/DS03/1030074) | 0-100 Budget Spread Improperly                                    | Is the budget for this 0-100 work spread across more than a one period?                                                       | 0-100 work found with BCWSi > 0 (Dollar, Hours, or FTEs) in more than one period.                                                                                                    |
| [1030075](/DIQs/DS03/1030075) | 50-50 Budget Spread Improperly                                    | Is the budget for this 50-50 work spread improperly? (Must be across two consecutive periods and with the same value.)        | 50-50 work (EVT = E) where BCWSi (Dollar, Hours, or FTEs) was found in either one period only or more than two, non-consecutive periods more than 45 days apart, or spread unevenly. |
| [1030079](/DIQs/DS03/1030079) | Negative Performance                                              | Does this WP or PP have negative performance?                                                                                 | WP or PP found with BCWPi < 0 (Dollars, Hours, or FTEs).                                                                                                                             |
| [1030080](/DIQs/DS03/1030080) | Negative Budget                                                   | Does this WP or PP have negative budget?                                                                                      | WP or PP found with BCWSi < 0 (Dollars, Hours, or FTEs).                                                                                                                             |
| [1030084](/DIQs/DS03/1030084) | Negative Estimates                                                | Does this CA, WP, or PP have negative estimates?                                                                              | CA, WP, or PP found with ETCi < 0 (Dollars, Hours, or FTEs).                                                                                                                         |
| [1030086](/DIQs/DS03/1030086) | EVT Justification Missing                                         | Is this WP or PP missing an EVT Justification?                                                                                | EVT Justification is missing for EVT = B,G, H, J, L, M, N, O, or P.                                                                                                                  |
| [1030087](/DIQs/DS03/1030087) | EVT Missing                                                       | Is this WP or PP missing an EVT?                                                                                              | EVT is missing.                                                                                                                                                                      |
| [1030099](/DIQs/DS03/1030099) | Estimates On Completed Work                                       | Are there estimates on this WP even though it is complete?                                                                    | ETCi <> 0 (Dollars, Hours, or FTEs) on completed work (BCWPc / BCWSc > 99%).                                                                                                         |
| [9030057](/DIQs/DS03/9030057) | Cost Periods Not One Month Apart                                  | Is this period date less than 20 or more than 36 days apart from either the previous or next period?                          | Period_date is not within 20-36 days from previous or next period.                                                                                                                   |
| [9030065](/DIQs/DS03/9030065) | Estimates on PP or CA                                             | Are there estimates on this CA or PP?                                                                                         | CA or PP with ETCi <> 0 (Dollars, Hours, or FTEs).                                                                                                                                   |
| [9030071](/DIQs/DS03/9030071) | SLPP or PP with Actuals                                           | Does this SLPP or PP have actuals?                                                                                            | SLPP or PP found with ACWPi <> 0 (Dollars, Hours, or FTEs).                                                                                                                          |
| [9030072](/DIQs/DS03/9030072) | WP or PP Missing In FC Schedule                                   | Is this WP or PP missing in the FC Schedule?                                                                                  | WBS_ID_WP missing from DS04.WBS_ID list (where schedule_type = FC).                                                                                                                  |
| [9030074](/DIQs/DS03/9030074) | VAC without Root Cause Narrative (Unfavorable)                    | Is a root cause narrative missing for this CA where the VAC is tripping the unfavorable dollar threshold?                     |                                                                                                                                                                                      | BCWSi_dollars - ACWPi_dollars - ETCi_dollars                   | ) > | DS07.threshold_cost_VAC_dollar_unfav     | & DS11.narrative_overall is missing or blank where DS11.narrative_type = 120 (by DS03.WBS_ID_CA & DS11.WBS_ID). |
| [9030082](/DIQs/DS03/9030082) | CA Missing In WBS                                                 | Is this CA missing in the WBS (DS01)?                                                                                         | The CA WBS ID was not found in the WBS (DS01).                                                                                                                                       |
| [9030083](/DIQs/DS03/9030083) | CA Type Mismatched With WBS Dictionary                            | Is this Control Account WBS ID typed as something other than CA in the WBS Dictionary?                                        | WBS_ID_CA not in DS01.WBS_ID list where DS01.type = CA.                                                                                                                              |
| [9030096](/DIQs/DS03/9030096) | SLPP or PP Type Mismatch with DS01 (WBS)                          | Is this SLPP or PP mistyped in DS01 (WBS)?                                                                                    | EVT = K but DS01 (WBS) type is not SLPP or PP. (Note: This flag also appears if DS01 type = PP but no WP ID is missing and if type = SLPP but a WP ID was found.)                    |
| [9030100](/DIQs/DS03/9030100) | Cost Missing Resources                                            | Is this WP or PP missing accompanying Resources (DS06) by EOC?                                                                | WP or PP with BCWSi <> 0 (Dollars, Hours, or FTEs) is missing Resources (DS06) by EOC.                                                                                               |
| [9030101](/DIQs/DS03/9030101) | WP / PP Missing in WBS Dictionary                                 | Is this WP WBS / PP ID missing in the WBS Dictionary?                                                                         | WBS_ID_WP missing from DS01.WBS_ID list.                                                                                                                                             |
| [9030102](/DIQs/DS03/9030102) | WP or PP Missing In BL Schedule                                   | Is this WP or PP missing in the BL Schedule?                                                                                  | WBS_ID_WP missing from DS04.WBS_ID list (where schedule_type = BL).                                                                                                                  |
| [9030104](/DIQs/DS03/9030104) | WP or PP Type Mismatch with Type in WBS Dictionary                | Is this Work Package or Package typed as something other than WP or PP in the WBS Dictionary?                                 | WBS_ID_WP found DS01.WBS_ID where type <> PP or WP.                                                                                                                                  |
| [9030105](/DIQs/DS03/9030105) | WP or PP Parent Mismatched with DS01 (WBS) Parent                 | Is the parent ID of this WP or PP misaligned with what is in DS01 (WBS)?                                                      | The parent ID for this WP or PP does not align with the parent ID found in DS01 (WBS).                                                                                               |
| [9030311](/DIQs/DS03/9030311) | Incremental CV without Root Cause Narrative (Favorable)           | Is a root cause narrative missing for this CA where the incremental CV is tripping the favorable dollar threshold?            | DS03.CVi (                                                                                                                                                                           | BCWPi - ACWPi                                                  | ) > | DS07.threshold_cost_inc_dollar_fav       | & DS11.narrative_RC_CVi is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030312](/DIQs/DS03/9030312) | CV without Root Cause Narrative (Favorable)                       | Is a root cause narrative missing for this CA where the CV is tripping the favorable dollar threshold?                        | DS03.CVc (                                                                                                                                                                           | BCWP - ACWP                                                    | ) > | DS07.threshold_cost_cum_dollar_fav       | & DS11.narrative_RC_CVc is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030313](/DIQs/DS03/9030313) | CV without Root Cause Narrative (Unfavorable)                     | Is a root cause narrative missing for this CA where the CV is tripping the unfavorable dollar threshold?                      | DS03.CVc (                                                                                                                                                                           | BCWP - ACWP                                                    | ) > | DS07.threshold_cost_cum_dollar_unfav     | & DS11.narrative_RC_CVc is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030314](/DIQs/DS03/9030314) | CV Percent without Root Cause Narrative (Favorable)               | Is a root cause narrative missing for this CA where the CV percent is tripping the favorable percent threshold?               | DS03.CVc % (                                                                                                                                                                         | (BCWP - ACWP) / BCWP                                           | ) > | DS07.threshold_cost_cum_dollar_fav       | & DS11.narrative_RC_CVc is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030315](/DIQs/DS03/9030315) | CV Percent without Root Cause Narrative (Unfavorable)             | Is a root cause narrative missing for this CA where the CV percent is tripping the unfavorable percent threshold?             | DS03.CVc % (                                                                                                                                                                         | (BCWP - ACWP) / BCWP                                           | ) > | DS07.threshold_cost_cum_dollar_unfav     | & DS11.narrative_RC_CVc is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030316](/DIQs/DS03/9030316) | SV without Root Cause Narrative (Favorable)                       | Is a root cause narrative missing for this CA where the SV is tripping the favorable dollar threshold?                        | DS03.SVc (                                                                                                                                                                           | BCWP - BCWS                                                    | ) > | DS07.threshold_schedule_cum_dollar_fav   | & DS11.narrative_RC_SVc is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030317](/DIQs/DS03/9030317) | SV without Root Cause Narrative (Unfavorable)                     | Is a root cause narrative missing for this CA where the SV is tripping the unfavorable dollar threshold?                      | DS03.SVc (                                                                                                                                                                           | BCWP - BCWS                                                    | ) > | DS07.threshold_schedule_cum_dollar_unfav | & DS11.narrative_RC_SVc is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030318](/DIQs/DS03/9030318) | SV Percent without Root Cause Narrative (Favorable)               | Is a root cause narrative missing for this CA where the SV percent is tripping the favorable percent threshold?               | DS03.SVc % (                                                                                                                                                                         | (BCWP - BCWS) / BCWS                                           | ) > | DS07.threshold_schedule_cum_pct_fav      | & DS11.narrative_RC_SVc is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030319](/DIQs/DS03/9030319) | SV Percent without Root Cause Narrative (Unfavorable)             | Is a root cause narrative missing for this CA where the SV percent is tripping the unfavorable percent threshold?             | DS03.SVc % (                                                                                                                                                                         | (BCWP - BCWS) / BCWS                                           | ) > | DS07.threshold_schedule_cum_pct_unfav    | & DS11.narrative_RC_SVc is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030320](/DIQs/DS03/9030320) | VAC without Root Cause Narrative (Favorable)                      | Is a root cause narrative missing for this CA where the VAC % is tripping the favorable percent threshold?                    |                                                                                                                                                                                      | (BCWSi_dollars - ACWPi_dollars - ETCi_dollars) / BCWSi_dollars | >   | DS07.threshold_cost_VAC_pct_fav          | & DS11.narrative_overall is missing or blank where DS11.narrative_type = 120 (by DS03.WBS_ID_CA & DS11.WBS_ID). |
| [9030321](/DIQs/DS03/9030321) | Incremental CV without Root Cause Narrative (Unfavorable)         | Is a root cause narrative missing for this CA where the incremental CV is tripping the unfavorable dollar threshold?          | DS03.CVi (                                                                                                                                                                           | BCWPi - ACWPi                                                  | ) > | DS07.threshold_cost_inc_dollar_unfav     | & DS11.narrative_RC_CVi is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030322](/DIQs/DS03/9030322) | Incremental CV Percent without Root Cause Narrative (Favorable)   | Is a root cause narrative missing for this CA where the incremental CV percent is tripping the favorable percent threshold?   | DS03.CVi (                                                                                                                                                                           | (BCWPi - ACWPi) / BCWPi                                        | ) > | DS07.threshold_cost_inc_pct_fav          | & DS11.narrative_RC_CVi is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030323](/DIQs/DS03/9030323) | Incremental CV Percent without Root Cause Narrative (Unfavorable) | Is a root cause narrative missing for this CA where the incremental CV percent is tripping the unfavorable percent threshold? | DS03.CVi (                                                                                                                                                                           | (BCWPi - ACWPi) / BCWPi                                        | ) > | DS07.threshold_cost_inc_pct_unfav        | & DS11.narrative_RC_CVi is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030324](/DIQs/DS03/9030324) | WP / PP EVT Misaligned with WAD                                   | Is the EVT for this WP or PP misaligned with the EVT in the WAD?                                                              | DS03.EVT <> DS08.EVT (by WBS_ID_WP).                                                                                                                                                 |
| [9030325](/DIQs/DS03/9030325) | Incremental SV without Root Cause Narrative (Favorable)           | Is a root cause narrative missing for this CA where the incremental SV is tripping the favorable dollar threshold?            | DS03.SVi (                                                                                                                                                                           | BCWPi - BCWSi                                                  | ) > | DS07.threshold_schedule_inc_dollar_fav   | & DS11.narrative_RC_SVi is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030326](/DIQs/DS03/9030326) | Incremental SV without Root Cause Narrative (Unfavorable)         | Is a root cause narrative missing for this CA where the incremental SV is tripping the unfavorable dollar threshold?          | DS03.SVi (                                                                                                                                                                           | BCWPi - BCWSi                                                  | ) > | DS07.threshold_schedule_inc_dollar_unfav | & DS11.narrative_RC_SVi is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030327](/DIQs/DS03/9030327) | Incremental SV Percent without Root Cause Narrative (Favorable)   | Is a root cause narrative missing for this CA where the incremental SV percent is tripping the favorable percent threshold?   | DS03.SVi (                                                                                                                                                                           | (BCWPi - BCWSi) / BCWSi                                        | ) > | DS07.threshold_schedule_inc_pct_fav      | & DS11.narrative_RC_SVi is missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                  |
| [9030328](/DIQs/DS03/9030328) | Incremental SV Percent without Root Cause Narrative (Unfavorable) | Is a root cause narrative missing for this CA where the incremental SV percent is tripping the unfavorable percent threshold? | DS03.SVi (                                                                                                                                                                           | (BCWPi - BCWSi) / BCWSi                                        | ) > | DS07.threshold_schedule_inc_pct_unfav    | & DS11.narrative_RC_SVi ißs missing or blank (by DS03.WBS_ID_CA & DS11.WBS_ID).                                 |
| [9030329](/DIQs/DS03/9030329) | VAC Percent without Root Cause Narrative (Favorable)              | Is a root cause narrative missing for this CA where the VAC % is tripping the favorable percent threshold?                    |                                                                                                                                                                                      | (BCWSi_dollars - ACWPi_dollars - ETCi_dollars) / BCWSi_dollars | >   | DS07.threshold_cost_VAC_pct_fav          | & DS11.narrative_overall is missing or blank where DS11.narrative_type = 120 (by DS03.WBS_ID_CA & DS11.WBS_ID). |
| [9030330](/DIQs/DS03/9030330) | VAC Percent without Root Cause Narrative (Unfavorable)            | Is a root cause narrative missing for this CA where the VAC % is tripping the unfavorable percent threshold?                  |                                                                                                                                                                                      | (BCWSi_dollars - ACWPi_dollars - ETCi_dollars) / BCWSi_dollars | >   | DS07.threshold_cost_VAC_pct_unfav        | & DS11.narrative_overall is missing or blank where DS11.narrative_type = 120 (by DS03.WBS_ID_CA & DS11.WBS_ID). |
| [1030094](/DIQs/DS03/1030094) | Insufficient Indirect                                             | Is this WP or PP lacking sufficient Indirect? (Minimally 10% of the total budget by period)                                   | BCWSi_dollars/hours/FTEs for this WP or PP makes up less than 10% of total budget for this period (on Dollars, Hours, or FTEs).                                                      |
| [1030095](/DIQs/DS03/1030095) | Material Found Alongside Non-Overhead EOCs                        | Does this WP/PP comingle Material with other EOC types (excluding Indirect)?                                                  | EOC = Material & Subcontract, ODC, or Labor by WBS_ID_WP.                                                                                                                            |
| [1030098](/DIQs/DS03/1030098) | Indirect Not Mingled With Other EOCs                              | Does this CA, SLPP, PP, or WP have only Indirect EOCs?                                                                        | CA, SLPP, PP, or WP with only Indirect.                                                                                                                                              |
| [1030112](/DIQs/DS03/1030112) | Subcontract Found Alongside Non-Indirect EOC                      | Does this WP/PP mingle Subcontract with other EOC types (excluding Indirect)?                                                 | EOC = Subcontract & Material, ODC, or Labor by WBS_ID_WP.                                                                                                                            |
| [1030113](/DIQs/DS03/1030113) | ODC Found Alongside Non-Indirect EOC                              | Does this WP/PP mingle ODC with other EOC types (excluding Indirect)?                                                         | EOC = ODC & Material, Subcontract, or Labor by WBS_ID_WP.                                                                                                                            |
| [1030115](/DIQs/DS03/1030115) | Improper Collection of Indirect                                   | Is indirect collected at the CA level or via the EOC field (rather than using is_indirect)?                                   | EOC = Indirect, is_indirect missing, or is_indirect = Y/N found at the CA level (where WBS_ID_WP is blank).                                                                          |
| [1030117](/DIQs/DS03/1030117) | Labor Found Alongside Non-Indirect EOC                            | Does this WP/PP mingle Labor with other EOC types (excluding Indirect)?                                                       | EOC = Labor & Material, Subcontract, or ODC by WBS_ID_WP.                                                                                                                            |
| [1060269](/DIQs/DS03/1060269) | CA WBS Matches WP WBS                                             | Do the CA & WP WBS IDs match?                                                                                                 | WBS_ID_CA = WBS_ID_WP                                                                                                                                                                |

## ALERT

| UID                           | Title                                                     | Summary                                                                                                                                                           | Error Message                                                                                                                     |
| ----------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [1030046](/DIQs/DS03/1030046) | Incommensurate Future Budget & Estimates                  | Is there more than a 50% delta between future BCWS & ETC dollars for this chunk of work? (Or, if BCWS is missing, is there at least $1,000 of ETC without BCWSi?) | (BCWSi_dollars - ETCi_dollars) / BCWSi_dollars > .5 (or ETCi_dollars > 1000 where BCWSi = 0) where period_date > CPP_status_date. |
| [1030063](/DIQs/DS03/1030063) | CC Found Without CC Description                           | Is there are CC without an accompanying description?                                                                                                              | CC ID found without an accompanying CC description                                                                                |
| [1030066](/DIQs/DS03/1030066) | Estimates Found A Year or More After Last Recorded Budget | Does this WP or PP show estimates a year or more after the last recorded period of budget?                                                                        | Last period_date where ETCi <> 0 is twelve or more months after last period_date of BCWSi <> 0 (on Dollars, Hours, or FTEs).      |
| [1030076](/DIQs/DS03/1030076) | Negative Actuals                                          | Does this CA, WP, or PP have negative actuals?                                                                                                                    | CA, WP, or PP found with ACWPi < 0 (Dollars, Hours, or FTEs).                                                                     |
| [1030081](/DIQs/DS03/1030081) | Budget Missing                                            | Is this WP or PP missing budget?                                                                                                                                  | WP or PP found with BCWSi = 0 (on Dollars, or Hours / FTEs where EOC = Labor).                                                    |
| [1030085](/DIQs/DS03/1030085) | 100-0 EVT                                                 | Does this work use a 100-0 EVT?                                                                                                                                   | 100-0 EVT (EVT = G) used (This is not recommended).                                                                               |
| [1030088](/DIQs/DS03/1030088) | Labor Missing Actuals                                     | Is this Labor missing Actual Dollars, Hours, or FTEs?                                                                                                             | EOC = Labor with ACWPi <> 0 for either Dollars, Hours, or FTEs, but where at least one other ACWPi = 0.                           |
| [1030089](/DIQs/DS03/1030089) | Labor Missing Performance                                 | Is this Labor missing Performance Dollars, Hours, or FTEs?                                                                                                        | EOC = Labor with BCWPi <> 0 for either Dollars, Hours, or FTEs, but where at least one other BCWPi = 0.                           |
| [1030091](/DIQs/DS03/1030091) | Labor Missing Estimates                                   | Is this Labor missing Estimated Dollars, Hours, or FTEs?                                                                                                          | EOC = Labor with ETCi <> 0 for either Dollars, Hours, or FTEs, but where at least one other ETCi = 0.                             |
| [1030097](/DIQs/DS03/1030097) | Zero SPAEcum                                              | Is this WBS missing Budget, Performance, Actuals, and Estimates?                                                                                                  | Cumulative BCWS, BCWP, ACWP, and ETC are all equal to zero for this piece of work (Dollars, Hours, and FTEs).                     |
| [9030056](/DIQs/DS03/9030056) | Cost Estimates After PMB End                              | Is there estimated work after the PMB end?                                                                                                                        | Period_date of last recorded ETCi (Dollars, Hours, or FTEs) > DS04.ES_Date for milestone_level = 175.                             |
| [9030068](/DIQs/DS03/9030068) | PP Starting Within 4-6 Months                             | Is this PP scheduled to start within 4-6 months?                                                                                                                  | PP with BCWSi > 0 (Dollar, Hours, or FTEs) and period_date within 4-6 months of CPP Status Date.                                  |
| [9030070](/DIQs/DS03/9030070) | Reprogramming Without OTB/OTS Date                        | Is there BAC, CV, or SV repgrogramming but not OTB/OTS Date?                                                                                                      | BAC_rpg, CV_rpg, or SV_rpg <> 0 but without OTB_OTS_Date in DS07 (IPMR Header).                                                   |
| [9030073](/DIQs/DS03/9030073) | Cost Periods Found After CD-4 Approved                    | Are there period dates after CD-4 approved?                                                                                                                       | Period Dates found after CD-4 approved (DS04.milestone_level = 190).                                                              |
| [9030095](/DIQs/DS03/9030095) | Cost Period After PMB End                                 | Is this period date after PMB end?                                                                                                                                | Period_date > DS04.ES_Date for milestone_level = 175.                                                                             |
| [1030114](/DIQs/DS03/1030114) | Indirect With Hours and/or FTEs                           | Does this indirect have hours or FTEs?                                                                                                                            | EOC = 'Indirect' or is_indirect = 'Y' AND (BCWSi, BCWPi, ACWPi, or ETCi hours or FTEs > 0)                                        |
