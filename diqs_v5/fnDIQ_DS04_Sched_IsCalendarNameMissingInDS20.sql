/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>DELETED</status>
  <severity>ALERT</severity>
  <title>Calendar Name Missing in DS20 (Schedule Calendar Exception)</title>
  <summary>Is this calendar name missing in DS20?</summary>
  <message>Calendar_name missing in DS20.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040147</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCalendarNameMissingInDS20] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
  with CALExcpt as (
    SELECT calendar_name 
    FROM DS20_schedule_calendar_exception 
    WHERE upload_ID = @upload_ID
  )
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND calendar_name NOT IN (SELECT calendar_name FROM CALExcpt)
    AND (SELECT COUNT(*) FROM CALExcpt) > 0 -- run only if there are any calendar exceptions
)