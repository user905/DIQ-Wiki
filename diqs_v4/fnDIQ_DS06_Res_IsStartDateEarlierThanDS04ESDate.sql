/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Starting Earlier Than Task</title>
  <summary>Is this resource scheduled to start before its parent task?</summary>
  <message>Start_date &lt; DS04.ES_date (by task_ID; BL schedule only).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060300</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsStartDateEarlierThanDS04ESDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BLTasks as (
		SELECT task_ID, ES_date 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN BLTasks S ON R.task_ID = S.task_ID
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'BL'
		AND R.start_date < S.ES_date
)