/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Planned/Estimated Completion Misaligned with End of PMB</title>
  <summary>Are the start/finish dates between the Planned/Estimated Completion and End of PMB milestones misaligned?</summary>
  <message>ES_date &amp; EF_date misaligned between Planned/Estimated Completion and End of PMB milestones (milestone_level = 170 and milestone_level = 175, respectively).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040202</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPlannedCompletionAlignedWithEndOfPMB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with PCompl as (
		SELECT task_ID, ES_date, EF_date, schedule_type 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 170
	), EOPMB as (
		SELECT task_ID, ES_date, EF_date, schedule_type 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 175
	), ToFlag as (
		SELECT P.task_ID 'CompTask', E.task_ID 'EOPTask', P.schedule_type
		FROM PCompl P INNER JOIN EOPMB E ON P.schedule_type = E.schedule_type
		WHERE P.ES_date <> E.ES_date OR P.EF_date <> E.EF_date
	)
	SELECT
		S.*
	FROM
		DS04_schedule S LEFT JOIN ToFlag F 	ON  S.task_ID = F.CompTask
										   	AND S.schedule_type = F.schedule_type
						LEFT JOIN ToFlag F2 ON 	S.task_ID = F2.EOPTask
										 	AND S.schedule_type = F2.schedule_type
	WHERE
			upload_id = @upload_ID
		AND F.CompTask IS NOT NULL
		AND F2.EOPTask IS NOT NULL
)