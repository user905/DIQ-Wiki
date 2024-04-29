/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS Summary With Resources</title>
  <summary>Is this WBS Summary resource-loaded?</summary>
  <message>WBS Summary task (task_ID where type = WS) was found in the resources dataset (DS06.task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040224</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsWBSSummaryResourceLoaded] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Rsrcs as (
		SELECT task_ID, schedule_type, ISNULL(subproject_ID,'') SubP
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Rsrcs R 	ON S.task_ID = R.task_ID 
											AND S.schedule_type = R.schedule_type
											AND ISNULL(S.subproject_ID,'') = R.SubP
	WHERE
			upload_id = @upload_ID
		AND type = 'WS'
)