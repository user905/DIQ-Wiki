/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Calendar Name Missing in DS19 (Schedule Calendar STD)</title>
  <summary>Is this calendar name missing in DS19?</summary>
  <message>Calendar_name missing in DS19.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040146</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCalendarNameMissingInDS19] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CALs as (
		SELECT calendar_name 
		FROM DS19_schedule_calendar_std 
		WHERE upload_ID = @upload_ID
	)
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND TRIM(ISNULL(calendar_name,'')) <> ''
		AND calendar_name NOT IN (SELECT calendar_name FROM CALs)
		AND (SELECT COUNT(*) FROM CALs) > 0 --run only if DS19 has data
)