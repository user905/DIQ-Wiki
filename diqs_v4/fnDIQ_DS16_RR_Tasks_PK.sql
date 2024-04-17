/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS16 Risk Register Tasks</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Risk Task</title>
  <summary>Is this risk task duplicated by risk ID &amp; task ID?</summary>
  <message>Count of combo of risk_ID &amp; task_ID &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1160569</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS16_RR_Tasks_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT risk_id, task_id
		FROM DS16_risk_register_tasks
		WHERE upload_ID = @upload_ID
		GROUP BY risk_id, task_id
		HAVING COUNT(*) > 1
	)
	SELECT 
		R.*
	FROM 
		DS16_risk_register_tasks R INNER JOIN Dupes D ON R.risk_ID = D.risk_ID 
													 AND R.task_ID = D.task_ID
	WHERE 
		upload_ID = @upload_ID
)