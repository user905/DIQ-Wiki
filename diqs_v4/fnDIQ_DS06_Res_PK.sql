/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Non-Unique Resource or Role</title>
  <summary>Is this resource / role duplicated by schedule type, task ID, and resource or role ID?</summary>
  <message>Count of schedule_type, task_ID, (resource_ID or role_id) combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060259</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT schedule_type, task_ID, ISNULL(resource_ID,'') resource_ID, ISNULL(role_id,'') role_id
		FROM DS06_schedule_resources
		WHERE upload_id = @upload_ID
		GROUP BY schedule_type, task_ID, ISNULL(resource_ID,''), ISNULL(role_id,'')
		HAVING COUNT(*) > 1
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN Dupes D ON R.schedule_type = D.schedule_type 
													AND R.task_ID = D.task_ID 
													AND ISNULL(R.resource_ID,'') = D.resource_ID 
													AND ISNULL(R.role_id,'') = D.role_id
	WHERE
		upload_id = @upload_ID
)