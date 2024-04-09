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
  <table>DS20 Sched CAL Exception</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Shift Exception In Excess Of 12 Hours</title>
  <summary>Is this shift exception longer than 12 hours?</summary>
  <message>Delta between exception_shift_#_start_time &amp; exception_shift_#_finish_time found &gt; 12.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1200598</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS20_Sched_CAL_Excpt_IsShiftInExcessOf12Hours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for rows where the DS20 sched cal exception 
		shifts are > 12 hours
	*/
SELECT 
	*
FROM DS20_schedule_calendar_exception
WHERE 
		upload_ID = @upload_ID
	AND (
		ABS(DATEDIFF(hour, exception_shift_A_start_time, exception_shift_A_stop_time)) > 12 OR
		ABS(DATEDIFF(hour, exception_shift_B_start_time, exception_shift_B_stop_time)) > 12 OR
		ABS(DATEDIFF(hour, exception_shift_C_start_time, exception_shift_C_stop_time)) > 12
	)


)