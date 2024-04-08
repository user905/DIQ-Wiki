# DS08
This data set should be populated with the approved project's contractor WAD data for the entire span of the project (not the contract) to include from initial and all revisions.<br/>The contractor WAD data by CA and SLPP WBS level and optional by PP and WP WBS levels.

| ------------ | ----------- |
| WAD_ID | WAD identifier. |
| revision | WAD version. |
| title | WAD title. |
| WBS_ID | CA or SLPP WBS level identifier. |
| WBS_ID_WP | WP or PP. |
| auth_PM_date | Date WAD was last signed by contractor project manager. |
| auth_CAM_date | Date WAD was last signed by CAM. |
| auth_WPM_date | Date WAD was last signed by WPM. |
| initial_auth_date | Date WAD was inititally signed by contractor project manager. |
| EVT | Provide if WBS_ID_WP is provided.<br/> EVT selection that should be aligned with DS03.EVT and DS04.EVT: <br/> • A = LOE<br/> • B = weighted milestones<br/> • C = percent complete<br/> • D = units complete or for use in DS03 only, discrete<br/> • E = 50-50<br/> • F = 0-100<br/> • G = 100-0<br/> • H = variation of 50-50<br/> • J = apportioned <br/> • K = planning package (overrides where DS01.type = PP or SLPP)<br/> • L = assignment percent complete<br/> • M = calculated apportionment<br/> • N = steps<br/> • O = earned as spent<br/> • P = percent manual entry<br/> • NA = only for DS01.type = CA where ACWP.<br/> Discrete EVTs for metrics consists of B, C, D, E, F, G, H, L, N, O, P. |
| budget_labor_dollars | Total budget for EOC labor (dollars). |
| budget_material_dollars | Total budget for EOC material (dollars). |
| budget_ODC_dollars | Total budget for EOC ODC (dollars). |
| budget_overhead_dollars | Total budget for EOC overhead (dollars). |
| budget_subcontract_dollars | Total budget for EOC subcontract (dollars). |
| budget_labor_hours | Total labor budget (hours). |
| POP_start_date | WBS POP start date, as defined by the latest approved baseline change.<br/> Not required if DS10.transaction_ID is not DB. |
| POP_finish_date | WBS POP finish date, as defined by the latest approved baseline change.<br/> Not required if DS10.transaction_ID is not DB. |
| CAM | CAM who signed WAD.<br/>Format: [last name] space [first name] space [middle initial, optional] |
| WPM | PP or WP WBS level manager.<br/>Optional if DS01.type = PP or WP.<br/>Format: [last name] space [first name] space [middle initial, optional] |
| PM | Contractor project manager.<br/>Format: [last name] space [first name] space [middle initial, optional] |
| narrative | CA WBS scope statement (not title) encompassing all scope per WAD and aligned with DS01.narrative and DS02.narrative. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
