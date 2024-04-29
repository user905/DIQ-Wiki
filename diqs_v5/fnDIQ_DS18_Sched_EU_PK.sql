/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS18 Sched EU</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Schedule EU Task</title>
  <summary>Is this schedule EU task duplicated by task ID &amp; schedule type?</summary>
  <message>Count of task_ID &amp; schedule_type combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1180590</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS18_Sched_EU_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT task_ID, schedule_type
		FROM DS18_schedule_EU
		WHERE upload_ID = @upload_ID
		GROUP BY task_ID, schedule_type
		HAVING COUNT(*) > 1
	)
	SELECT 
		E.*
	FROM 
		DS18_schedule_EU E INNER JOIN Dupes D ON E.task_ID = D.task_ID 
											 AND E.schedule_type = D.schedule_type
	WHERE 
		upload_ID = @upload_ID
)