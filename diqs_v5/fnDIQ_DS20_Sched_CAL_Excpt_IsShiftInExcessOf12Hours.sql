/*
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