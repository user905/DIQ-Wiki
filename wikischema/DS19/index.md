# DS19
This data set should be populated with the project's contractor IMS tool standard work week calendar data for the entire span of the project (not the contract).<br/> Each weekday is limited to 3 shifts (A, B, and C) for breaks in between shifts, starting with shift A, half hour increments, and no overlaps.<br/> If more than 3 shifts, 3rd shift should be stretched to the last shift.<br/> There should be alignment between the BL and FC IMSs.

| ------------ | ----------- |
| calendar_name | Unique calendar name. |
| hours_per_day | Hours per day. |
| std_01_Mon_shift_A_start_time | Standard work week shift_A_start time, Monday. |
| std_01_Mon_shift_A_stop_time | Standard work week shift_A_stop time, Monday. |
| std_01_Mon_shift_B_start_time | Standard work week shift_B_start time, Monday. |
| std_01_Mon_shift_B_stop_time | Standard work week shift_B_stop time, Monday. |
| std_01_Mon_shift_C_start_time | Standard work week shift_C_start time, Monday. |
| std_01_Mon_shift_C_stop_time | Standard work week shift_C_stop time, Monday. |
| std_02_Tue_shift_A_start_time | Standard work week shift_A_start time, Tuesday. |
| std_02_Tue_shift_A_stop_time | Standard work week shift_A_stop time, Tuesday. |
| std_02_Tue_shift_B_start_time | Standard work week shift_B_start time, Tuesday. |
| std_02_Tue_shift_B_stop_time | Standard work week shift_B_stop time, Tuesday. |
| std_02_Tue_shift_C_start_time | Standard work week shift_C_start time, Tuesday. |
| std_02_Tue_shift_C_stop_time | Standard work week shift_C_stop time, Tuesday. |
| std_03_Wed_shift_A_start_time | Standard work week shift_A_start time, Wednesday. |
| std_03_Wed_shift_A_stop_time | Standard work week shift_A_stop time, Wednesday. |
| std_03_Wed_shift_B_start_time | Standard work week shift_B_start time, Wednesday. |
| std_03_Wed_shift_B_stop_time | Standard work week shift_B_stop time, Wednesday. |
| std_03_Wed_shift_C_start_time | Standard work week shift_C_start time, Wednesday. |
| std_03_Wed_shift_C_stop_time | Standard work week shift_C_stop time, Wednesday. |
| std_04_Thu_shift_A_start_time | Standard work week shift_A_start time, Thursday. |
| std_04_Thu_shift_A_stop_time | Standard work week shift_A_stop time, Thursday. |
| std_04_Thu_shift_B_start_time | Standard work week shift_B_start time, Thursday. |
| std_04_Thu_shift_B_stop_time | Standard work week shift_B_stop time, Thursday. |
| std_04_Thu_shift_C_start_time | Standard work week shift_C_start time, Thursday. |
| std_04_Thu_shift_C_stop_time | Standard work week shift_C_stop time, Thursday. |
| std_05_Fri_shift_A_start_time | Standard work week shift_A_start time, Friday. |
| std_05_Fri_shift_A_stop_time | Standard work week shift_A_stop time, Friday. |
| std_05_Fri_shift_B_start_time | Standard work week shift_B_start time, Friday. |
| std_05_Fri_shift_B_stop_time | Standard work week shift_B_stop time, Friday. |
| std_05_Fri_shift_C_start_time | Standard work week shift_C_start time, Friday. |
| std_05_Fri_shift_C_stop_time | Standard work week shift_C_stop time, Friday. |
| std_06_Sat_shift_A_start_time | Standard work week shift_A_start time, Saturday. |
| std_06_Sat_shift_A_stop_time | Standard work week shift_A_stop time, Saturday. |
| std_06_Sat_shift_B_start_time | Standard work week shift_B_start time, Saturday. |
| std_06_Sat_shift_B_stop_time | Standard work week shift_B_stop time, Saturday. |
| std_06_Sat_shift_C_start_time | Standard work week shift_C_start time, Saturday. |
| std_06_Sat_shift_C_stop_time | Standard work week shift_C_stop time, Saturday. |
| std_07_Sun_shift_A_start_time | Standard work week shift_A_start time, Sunday. |
| std_07_Sun_shift_A_stop_time | Standard work week shift_A_stop time, Sunday. |
| std_07_Sun_shift_B_start_time | Standard work week shift_B_start time, Sunday. |
| std_07_Sun_shift_B_stop_time | Standard work week shift_B_stop time, Sunday. |
| std_07_Sun_shift_C_start_time | Standard work week shift_C_start time, Sunday. |
| std_07_Sun_shift_C_stop_time | Standard work week shift_C_stop time, Sunday. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
