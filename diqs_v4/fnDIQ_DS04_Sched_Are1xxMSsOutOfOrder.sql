/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CD / BCP Milestones Out of Sequence</title>
  <summary>Is this CD or BCP out of sequence chronologically in the milestone list?</summary>
  <message>CD or BCP milestone (milestone_level = 1xx) occurs out of sequence with successive milestone (ES_date &gt; ES_date of the successive milestone).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040107</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_Are1xxMSsOutOfOrder] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
		with MSList as (
			SELECT ES_date, LEAD(ES_date,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextES, schedule_type, task_ID
			FROM DS04_schedule
			WHERE 
					upload_ID = @upload_ID 
				AND (
						milestone_level BETWEEN 100 AND 139
					OR milestone_level = 150
					OR milestone_level BETWEEN 170 AND 199
				)
			UNION		
			SELECT ES_date, LEAD(ES_date,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextES, schedule_type, task_ID
			FROM DS04_schedule
			WHERE 
					upload_ID = @upload_ID 
				AND milestone_level BETWEEN 140 AND 145
			UNION
			SELECT ES_date, LEAD(ES_date,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextES, schedule_type, task_ID
			FROM DS04_schedule
			WHERE 
					upload_ID = @upload_ID 
				AND milestone_level BETWEEN 160 AND 165
		)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN MSList M ON S.task_ID = M.task_ID
											AND S.schedule_type = M.schedule_type
											AND M.ES_date >= M.NextES		
	WHERE
		upload_id = @upload_ID
)