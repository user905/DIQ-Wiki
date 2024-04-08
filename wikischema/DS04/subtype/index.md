# subtype
| Detail | Value |
| ------ | ----- |
| type | string |
| description | Task subtype selection:<br/> • SVT = A non-PMB task for visibility/functionality to charactarize potential impacts to the logic-driven network. Generally based on another project as a predecessor with a finish-to-start relationship. Generally constrained based on programmatic schedule with DS04.constraint_type = CS.MSOA or DS04.constraint_type = CS.MEOA but may be a hard constraint; DS04.constraint_type = M; not resource loaded. <br/> • ZBA = zero budget activity. For subK payment tasks. Used on a limited basis; not resource loaded. Align with DS04.milestone_level = 8xx. |
| enum | * SVT<br/>* ZBA |
