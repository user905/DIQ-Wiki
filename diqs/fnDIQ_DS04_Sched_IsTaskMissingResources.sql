/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Missing Resources</title>
  <summary>Is this task missing resources (DS06)?</summary>
  <message>Task_ID is missing in resources (DS06).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040217</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsTaskMissingResources] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Resources as (
		SELECT task_ID, schedule_type, ISNULL(subproject_ID,'') SubP
		FROM DS06_schedule_resources
		WHERE upload_ID = @upload_ID
	)
	SELECT
		S.*
	FROM
		DS04_schedule S LEFT OUTER JOIN Resources R ON S.schedule_type = R.schedule_type 
													AND S.task_ID = R.task_ID
													AND ISNULL(S.subproject_ID,'') = R.SubP
	WHERE
			S.upload_id = @upload_ID
		AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA')
		AND S.type NOT IN ('SM','FM', 'WS')
		AND R.task_ID IS NULL
)