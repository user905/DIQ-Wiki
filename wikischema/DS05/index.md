# DS05
This data set should be populated with the project's contractor BL and FC IMS tool task relationship data for the DS04 tasks. The contractor BL and FC IMS tool task relationship data by task and predecessor. There should be alignment between the BL and FC IMSs.

| ------------ | ----------- |
| schedule_type | Schedule type selection:<br/> • BL = baseline<br/> • FC = forecast<br/> The data should be scheduled by the schedule tool. |
| task_ID | Unique task identifier. |
| predecessor_task_ID | Task identifier of the predecessor task.<br/>The data should align with DS04.task_ID. |
| type | Task relationship (task to its predecessor) selection:<br/> • FS = finish to start <br/> • SS = start to start <br/> • SF = start to finish <br/> • FF = finish to finish |
| lag_days | Task relationship lag (work days) based on predecessor's calendar.<br/> The data is positive if lag.<br/> The data is negative if lead. |
| subproject_ID | Unique subproject identifier.<br/>Tasks not in project scope should be associated with that task's primary project, not this project's primary project. This includes SVTs, tasks pre-CD-0, and tasks post DS04.milestone_level = 170, 175, or 180. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
