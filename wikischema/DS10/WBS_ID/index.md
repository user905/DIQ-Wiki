# WBS_ID
| Detail | Value |
| ------ | ----- |
| type | string |
| description | WBS identifier.<br/>Project level required for UB, MR, CNT. <br/> CA or lower level required if transaction type is DB. |
| minLength | 1 |
| maxLength | 150 |
| $comment | WBS ID is has a max length of 50 for all new projects. Max length of 150 is enforced here to support specific legacy projects only. |
