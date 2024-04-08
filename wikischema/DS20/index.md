# DS20
This data set should be populated with the project's contractor IMS tool calendar exception data for the entire span of the project (not the contract).<br/> Exception day is limited to 3 shifts (A, B, and C) for breaks in between shifts, starting with shift A, half hour increments, and no overlaps.<br/> If more than 3 shifts, 3rd shift should be stretched to the last shift.<br/> There should be alignment between the BL and FC IMSs.

| ------------ | ----------- |
| calendar_name | Calendar name.<br/> Align with DS19.calendar_name. |
| exception_date | Date of exception. |
| exception_work_day | Exception is a work day (Y or N).<br/> If Y then all day is exception and shift times do not need to be provided.<br/> If N then provide shift times. |
| exception_shift_A_start_time | Exception shift_A_start time. |
| exception_shift_A_stop_time | Exception shift_A_stop time. |
| exception_shift_B_start_time | Exception shift_B_start time. |
| exception_shift_B_stop_time | Exception shift_B_stop time. |
| exception_shift_C_start_time | Exception shift_C_start time. |
| exception_shift_C_stop_time | Exception shift_C_stop time. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
