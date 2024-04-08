# WBS_ID_CA
| Detail | Value |
| ------ | ----- |
| type | string |
| key | True |
| description | Unique contractor WBS identifier for following:<br/> • DS01.type = CA and ACWP is collected at CA level. DS01.WBS_ID_WP is omitted.<br/> • DS01.type = SLPP. DS01.WBS_ID_WP is omitted.<br/> • DS01.type = CA and associated with DS01.WBS_ID_WP. |
| minLength | 1 |
| maxLength | 150 |
| examples | ['1.42.27.2'] |
| $comment | WBS ID is has a max length of 50 for all new projects. Max length of 150 is enforced here to support specific legacy projects only. |
| notes | CPP-1.DS03.WBS_ID_CA = prior CPP_status_date |
