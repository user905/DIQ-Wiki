# DS01
This data set should be populated with the project's contractor WBS identifiers for the entire span of the project (not the contract).<br/> Provide the contractor WBS identifiers in a hierarchical structure from the project (not the contract) level to the CA WBS level and to the WP and PP WBS levels. The data set should include all WBS identifiers in all other DSs in the same format.

| ------------ | ----------- |
| WBS_ID | Unique contractor WBS identifier. |
| title | Unique WBS identifier title. |
| level | WBS identifier hierarchical level relative to the project.<br/> The data is > 0, starting with 1 and increments by 1.<br/> The dataset should have only one level 1 WBS identifier that represents the entire project. |
| parent_WBS_ID | WBS identifier of the immediate hierarchical parent.<br/> Required unless level = 1. |
| type | WBS type selection: <br/> • WBS = summary level<br/> • SLPP = summary level planning package (assigned to project manager not to a CAM; thus, is not a CA and does not have any WP, PP, or lower DS01.WBS_level<br/> • CA = control account<br/> • PP = planning package<br/> • WP = work package<br/> MR, UB, contingency, and SM tasks should be associated with DS01.type = WBS.<br/> Should be set to PP or SLPP if DS03.EVT = K.<br/> BCWS, BCWP, ACWP, and ETC are roll-ups where DS01.type = CA or WBS.<br/> BCWS, BCWP, ACWP, and ETC are accounted for where DS01.type = WP or PP.<br/> While not preferred, ACWP may be collected at the CA level, i.e. where DS01.type = CA. However, the level ACWP is collected must be uniform across the dataset, i.e., all at CA or all at WP. |
| OBS_ID | Unique contractor OBS identifier that should be aligned with the associated CA and DS02.OBS.<br/> If DS01.type is above the CA, the associated or higher level OBS identifier. |
| CAM | CAM selection:<br/> • CAM name for DS01.type = CA, WP, PP.<br/> • Project manager name for DS01.type = SLPP.<br/> • Project or appropriate manager name for DS01.type = WBS.<br/> Format: [last name] space [first name] space [middle initial, optional]. |
| WPM | WP manager.<br/> Required if and only if DS01.type is WP or PP.<br/> Format: [last name] space [first name] space [middle initial, optional]. |
| subproject_ID | Unique subproject identifier aligned with DS04.subproject_ID.<br/> Required if DS01.WBS_external = Y. |
| IMP_ID | Unique IMP identifier. |
| external | WBS is external to the project (Y or N). |
| exit_criteria | Criteria to determine completion of the WBS scope. |
| narrative | WBS identifier description from the EVMS cost tool; the scope statement or a short paragraph based on the WBS dictionary and aligned with DS08.narrative.<br/>Align with DS08.narrative. |
| K_ref | Contractual basis: contract number, section(s), and paragraph(s). |
| BWC_ID | Unique base work construct identifier.<br/> Level 3 BWC where DS01.type = SLPP, WP, or PP.<br/> Level 2 and 3 BWC:<br/> • W.01 support<br/> • ​	W.01.01 project<br/> • ​	W.01.02 closeout<br/> • ​	W.01.03 operations<br/> • W.02 engineering<br/> • ​	W.02.01 R&D<br/> • ​	W.02.02 conceptual<br/> • ​	W.02.03 preliminary<br/> • ​	W.02.04 final<br/> • ​	W.02.05 general<br/> • W.03 procurement<br/> • ​	W.03.01 general<br/> • W.04 construction<br/> • ​	W.04.01 engineering support<br/> • ​	W.04.02 demolition<br/> • ​	W.04.03 site preparation<br/> • ​	W.04.04 construction<br/> • W.05 SU-Cx<br/> • ​	W.05.01 SU<br/> • ​	W.05.02 cold cx<br/> • ​	W.05.03 hot cx |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
