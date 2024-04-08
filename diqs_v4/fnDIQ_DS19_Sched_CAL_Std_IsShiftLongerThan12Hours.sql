/*

The name of the function should include the ID and a short title, for example: DIQ0001_WBS_Pkey or DIQ0003_WBS_Single_Level_1

author is your name.

id is the unique DIQ ID of this test. Should be an integer increasing from 1.

table is the table name (flat file) against which this test runs, for example: "FF01_WBS" or "FF26_WBS_EU".
DIQ tests might pull data from multiple tables but should only return rows from one table (split up the tests if needed).
This value is the table from which this row returns tests.

status should be set to TEST, LIVE, SKIP.
TEST indicates the test should be run on test/development DIQ checks.
LIVE indicates the test should run on live/production DIQ checks.
SKIP indicates this isn't a test and should be skipped.

severity should be set to WARNING or ERROR. ERROR indicates a blocking check that prevents further data processing.

summary is a summary of the check for a technical audience.

message is the error message displayed to the user for the check.

<documentation>
  <author>Elias Cooper</author>
  <table>DS19 Sched CAL Std</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Shift Exceeds 12 Hours</title>
  <summary>Are the hours of any of your shifts in excess of 12 hours?</summary>
  <message>Hours delta between std_##_DDD_shift_#_start_time &amp; std_##_DDD_shift_#_stop_time &gt; 12.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1190594</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS19_Sched_CAL_Std_IsShiftLongerThan12Hours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for rows where the DS19 schedule 
		ABS(start_time - stop_time) > 12 hours (for all shift start/stop times)
	*/
SELECT 
	*
FROM DS19_schedule_calendar_std
WHERE 
		upload_ID = @upload_ID
	AND (
		 ABS(DATEDIFF(hour, std_01_Mon_shift_A_start_time, std_01_Mon_shift_A_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_01_Mon_shift_B_start_time, std_01_Mon_shift_B_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_01_Mon_shift_C_start_time, std_01_Mon_shift_C_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_02_Tue_shift_A_start_time, std_02_Tue_shift_A_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_02_Tue_shift_B_start_time, std_02_Tue_shift_B_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_02_Tue_shift_C_start_time, std_02_Tue_shift_C_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_03_Wed_shift_A_start_time, std_03_Wed_shift_A_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_03_Wed_shift_B_start_time, std_03_Wed_shift_B_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_03_Wed_shift_C_start_time, std_03_Wed_shift_C_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_04_Thu_shift_A_start_time, std_04_Thu_shift_A_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_04_Thu_shift_B_start_time, std_04_Thu_shift_B_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_04_Thu_shift_C_start_time, std_04_Thu_shift_C_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_05_Fri_shift_A_start_time, std_05_Fri_shift_A_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_05_Fri_shift_B_start_time, std_05_Fri_shift_B_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_05_Fri_shift_C_start_time, std_05_Fri_shift_C_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_06_Sat_shift_A_start_time, std_06_Sat_shift_A_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_06_Sat_shift_B_start_time, std_06_Sat_shift_B_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_06_Sat_shift_C_start_time, std_06_Sat_shift_C_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_07_Sun_shift_A_start_time, std_07_Sun_shift_A_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_07_Sun_shift_B_start_time, std_07_Sun_shift_B_stop_time)) > 12
		OR ABS(DATEDIFF(hour, std_07_Sun_shift_C_start_time, std_07_Sun_shift_C_stop_time)) > 12
)



)