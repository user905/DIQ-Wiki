# DS21
This data set should be populated with the project's contractor EVMS cost tool resource rates.<br/>Provide the contractor EVMS cost tool resource rates by WP WBS level, resource identifier, and applicable FYs.<br/>The data may be UCNI.

| ------------ | ----------- |
| resource_ID | Resource identifier. |
| EOC | EOC selection aligned with DS03.EOC:<br/> • labor<br/> • material<br/> • subcontract<br/> • ODC<br/> • overhead (if overhead is utilized, other EOCs for the project should not include overhead) |
| burden_ID | Burden identifier (or overhead key) from accounting system, used to calculate indirect rate. |
| type | Rate type:<br/> • D = direct rate<br/> • I = indirect rate |
| rate_start_date | Start date for which the rate is applicable. |
| rate_dollars | Rate (dollars). |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
