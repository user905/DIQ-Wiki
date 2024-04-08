# type
| Detail | Value |
| ------ | ----- |
| type | string |
| description | WBS type selection: <br/> • WBS = summary level<br/> • SLPP = summary level planning package (assigned to project manager not to a CAM; thus, is not a CA and does not have any WP, PP, or lower DS01.WBS_level<br/> • CA = control account<br/> • PP = planning package<br/> • WP = work package<br/> MR, UB, contingency, and SM tasks should be associated with DS01.type = WBS.<br/> Should be set to PP or SLPP if DS03.EVT = K.<br/> BCWS, BCWP, ACWP, and ETC are roll-ups where DS01.type = CA or WBS.<br/> BCWS, BCWP, ACWP, and ETC are accounted for where DS01.type = WP or PP.<br/> While not preferred, ACWP may be collected at the CA level, i.e. where DS01.type = CA. However, the level ACWP is collected must be uniform across the dataset, i.e., all at CA or all at WP. |
| enum | * WBS<br/>* SLPP<br/>* CA<br/>* PP<br/>* WP |
