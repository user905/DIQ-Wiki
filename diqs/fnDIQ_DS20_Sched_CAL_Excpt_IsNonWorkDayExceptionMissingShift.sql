/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS20 Sched CAL Exception</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Non-Workday Exception Missing Shift</title>
  <summary>Is this non-workday exception missing a shift?</summary>
  <message>exception_work_day = N &amp; no exception_shift_#_start_time or exception_shift_#_finish_time found.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1200597</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS20_Sched_CAL_Excpt_IsNonWorkDayExceptionMissingShift] (
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
	AND exception_work_day = 'N'
	AND exception_shift_A_start_time IS NULL
    AND exception_shift_A_stop_time IS NULL
    AND exception_shift_B_start_time IS NULL
    AND exception_shift_B_stop_time IS NULL
    AND exception_shift_C_start_time IS NULL
    AND exception_shift_C_stop_time IS NULL
)