/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS20 Sched CAL Exception</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Calendar Exception</title>
  <summary>Is this calendar exception duplicated by calendar name &amp; exception date?</summary>
  <message>Count of calendar_name &amp; exception_date combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1200595</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS20_Sched_CAL_Excpt_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT calendar_name, exception_date
		FROM DS20_schedule_calendar_exception
		WHERE upload_ID = @upload_ID
		GROUP BY calendar_name, exception_date
		HAVING COUNT(*) > 1
	)
	SELECT 
		S.*
	FROM 
		DS20_schedule_calendar_exception S INNER JOIN Dupes D ON S.calendar_name = D.calendar_name
															 AND S.exception_date = D.exception_date
	WHERE 
		upload_ID = @upload_ID
)