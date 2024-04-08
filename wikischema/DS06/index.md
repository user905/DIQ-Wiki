# DS06
This data set should be populated with the project's contractor BL and FC IMS tool task role and resource data for the DS04 tasks.<br/>Provide the contractor BL and FC IMS tool task role and/or resource data by task.<br/>There should be alignment between the BL and FC IMSs.

| ------------ | ----------- |
| schedule_type | Schedule type selection:<br/> • BL = baseline<br/> • FC = forecast<br/> The data should be scheduled by the schedule tool. |
| task_ID | Unique task identifier. |
| resource_ID | Unique resource identifier. |
| resource_name | Unique resource name. |
| role_ID | Unique role identifier. |
| role_name | Unique role name. |
| type | Resource type selection:<br/> • labor where DS06.EOC = labor<br/> • nonlabor where DS06.EOC is not labor<br/> • material where DS06.EOC is not labor |
| EOC | EOC selection:<br/> • labor<br/> • material<br/> • subcontract <br/> • ODC<br/> • overhead (if overhead is utilized, other EOCs for the project should not include overhead) |
| start_date | Resource start date.<br/>For FC IMS, updated resource start or started date. |
| finish_date | Resource finish date.<br/>For FC IMS, updated resource start or started date. |
| budget_dollars | Total budget (dollars). |
| actual_dollars | Total actual (dollars). |
| remaining_dollars | Total remaining (dollars). |
| budget_units | Total budget (units).<br/>Units of measure are specified in UOM field. |
| actual_units | Total actual (units).<br/>Units of measure are specified in UOM field. |
| remaining_units | Total remaining (units).<br/>Units of measure are specified in UOM field. |
| UOM | Unit of measure.<br/>If resource_type is labor or non-labor, it is h.<br/>If it is material it is a string. |
| lag_remaining_days | Task relationship remaining lag (work days) based on predecessor's calendar.<br/> The data is positive if lag.<br/> The data is negative if lead. |
| lag_planned_days | Task relationship planned lag (work days) based on predecessor's calendar.<br/> The data is positive if lag.<br/> The data is negative if lead. |
| calendar_name | Calendar name for resource.<br/> Align with DS19.calendar_name and DS20.calender_name. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
