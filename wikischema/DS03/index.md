# DS03
This data set should be populated with the project's contractor EVMS cost tool time-phased data for the entire span of the project (not the contract).<br/> Provide the contractor EVMS cost tool time-phased data at the WP and PP WBS level by EOC.<br/> The data should be provided at the WP, PP, and SLPP WBS levels only with one period_date/WBS/EOC record; however, provide at CA WBS level for only those CAs where ACWP (DS03.ACWPi_dollars and DS03.ACWPi_units) is reported for entire project.

| ------------ | ----------- |
| period_date | Time-phased period end dates.<br/> The data should align with the the CPP_status_dates, and not change during the span of the project. |
| WBS_ID_WP | WP or PP WBS identifier if DS01.type = WP or PP. |
| WBS_ID_CA | Unique contractor WBS identifier for following:<br/> • DS01.type = CA and ACWP is collected at CA level. DS01.WBS_ID_WP is omitted.<br/> • DS01.type = SLPP. DS01.WBS_ID_WP is omitted.<br/> • DS01.type = CA and associated with DS01.WBS_ID_WP. |
| EOC | EOC selection:<br/> • labor<br/> • material<br/> • subcontract<br/> • ODC<br/> • overhead (if overhead is utilized, other EOCs for the project should not include overhead) |
| EVT | EVT selection that should be aligned with DS04.EVT (explanations should go in DS03.justification_EVT): <br/> • A = LOE<br/> • B = weighted milestones (explain if utilized)<br/> • C = percent complete<br/> • D = units complete or for use in DS03 only, discrete (combination of discrete DS03.EVT excluding A, J, K, M, or NA)<br/> • E = 50-50<br/> • F = 0-100<br/> • G = 100-0 (explain if utilized)<br/> • H = variation of 50-50 (explain if utilized)<br/> • J = apportioned (explain if utilized)<br/> • K = planning package (overrides where DS01.type = PP or SLPP)<br/> • L = assignment percent complete (explain if utilized)<br/> • M = calculated apportionment (explain if utilized)<br/> • N = steps (explain if utilized)<br/> • O = earned as spent (explain if utilized)<br/> • P = percent manual entry (explain if utilized)<br/> • NA = only for DS01.type = CA where ACWP is reported for the entire project.<br/> Discrete EVTs for metrics consists of B, C, D, E, F, G, H, L, N, O, P. |
| justification_EVT | Justification narrative where DS03.EVT = B, G, H, J, L, M, N, O, or P. |
| EVT_J_to_WBS_ID | WBS_ID apportioned to, if DS03.EVT = J or M. |
| EVT_J_pct | Percent apportioned, if apportioned from another DS03.WBS_ID. |
| BCWSi_dollars | BCWS incremental (dollars). |
| BCWPi_dollars | BCWP incremental (dollars). |
| ACWPi_dollars | ACWP incremental (dollars). |
| ETCi_dollars | ETC incremental (dollars). |
| BCWSi_hours | BCWS incremental (hours) where DS03.EOC = labor only. |
| BCWPi_hours | BCWP incremental (hours) where DS03.EOC = labor only. |
| ACWPi_hours | ACWP incremental (hours) where DS03.EOC = labor only. |
| ETCi_hours | ETC incremental (hours) where DS03.EOC = labor only. |
| BCWSi_FTEs | BCWS incremental (FTE) where DS03.EOC = labor only. |
| BCWPi_FTEs | BCWP incremental (FTE) where DS03.EOC = labor only. |
| ACWPi_FTEs | ACWP incremental (FTE) where DS03.EOC = labor only. |
| ETCi_FTEs | ETC incremental (FTE) where DS03.EOC = labor only. |
| CV_rpg | Reprogramming CV. Reprogramming adjustment, cost variance. |
| SV_rpg | Reprogramming SV. Reprogramming adjustment, schedule variance. |
| BAC_rpg | Reprogramming BAC. Reprogramming adjustment, DB variance. |
| CC_ID | Charge code identifier. |
| CC_description | Charge code description. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
