/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Milestone With Resources</title>
  <summary>Is this milestone resource-loaded?</summary>
  <message>Milestone task_ID (task_ID where type = SM/FM) was found in the resources dataset (DS06.task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040196</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMSResourceLoaded] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Resources as (
		SELECT task_ID, schedule_type 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Resources R ON S.task_ID = R.task_ID
											  AND S.schedule_type = R.schedule_type
	WHERE
			S.upload_id = @upload_ID
		AND S.type IN ('SM','FM')
)