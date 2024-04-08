# DS11
This data set should be populated with the project's contractor variance data. Provide the contractor variance data by WBS identifier; for project, use the project level WBS identifier.

| ------------ | ----------- |
| WBS_ID | WBS identifier. |
| narrative_type | Narrative type selection:<br/> • 100 PRJ = project level summary<br/> • 110 RPG = project level formal reprogramming analysis<br/> • 120 VAC = project level VAC analysis<br/> • 130 EAC = project level EAC analysis<br/> • 140 UB = project level UB analysis<br/> • 150 MR = project level MR analysis<br/> • 160 IMS = project level IMS discussion<br/> • 170 F3 = project level IPMR F3 discussion<br/> • 180 F4 = project level IPMR F4 discusion<br/> • 200 SLPP = summary level planning package (The data should not have SV or CV.)<br/> • 300 CA = control account<br/> • 400 PP = planning package (The data should not have SV or CV.)<br/> • 500 WP = work package |
| narrative_overall | Overall narrative.<br/> Provide if DS11.narrative_type <200 |
| narrative_RC_SVi | Root cause narrative for incremental schedule variance. |
| narrative_RC_CVi | Root cause narrative for incremental cost variance. |
| narrative_RC_SVc | Root cause narrative for cumulative schedule variance. |
| narrative_RC_CVc | Root cause narrative for cumulative cost variance. |
| narrative_impact_technical | Impact narrative for technical variance. |
| narrative_impact_schedule | Impact narrative for schedule variance. |
| narrative_impact_cost | Impact narrative for cost variance. |
| CAL_ID | Unique corrective action log identifier(s).<br/>If multiple identifiers, separate with semicolons. |
| approved_date | Approved date by CAM. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
