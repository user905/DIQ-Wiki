# type
| Detail | Value |
| ------ | ----- |
| type | string |
| description | Task type selection:<br/> • TD = task dependent. Task is scheduled using its task calendar.<br/> • RD = resource dependent. Task is scheduled using its resource calendar(s).<br/> • LOE = level of effort. Task duration by its dependent taks. Used for administration type tasks. Use should be limited. Likely DS04.EVT = A (level of effort) but could be different.<br/> • SM = start milestone. Tasks with 0 duration and no resources. <br/> • FM = finish milestone. Task with 0 duration and no resources. <br/> • WS = WBS summary. Task of aggregated tasks with common DS04.WBS_ID. Use should be limited. |
| enum | * TD<br/>* RD<br/>* LOE<br/>* SM<br/>* FM<br/>* WS |
| notes | CPP-1.DS04.type = prior CPP_status_date |
