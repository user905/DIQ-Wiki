/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EVT Mismatch</title>
  <summary>Is this task's EVT mismatched with what is in cost?</summary>
  <message>Task EVT does not match what is in DS03 cost (by WBS ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040278</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsEVTMismatchedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ScheduleWBS as (
		SELECT 
			schedule_type, 
			WBS_ID,
			task_ID,
			CASE 
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT = 'K' THEN 'PP'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
			END AS EVTCat
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), CostWBS as (
		SELECT
			WBS_ID_WP,
			CASE 
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT = 'K' THEN 'PP'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
			END AS EVTCat
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	),
	ToFlag as (
		SELECT
			S.schedule_type,
			S.WBS_ID,
			S.task_ID
		FROM
			ScheduleWBS S INNER JOIN CostWBS C ON S.WBS_ID = C.WBS_ID_WP AND S.EVTCat <> C.EVTCat
		GROUP BY S.schedule_type, S.WBS_ID, S.task_ID
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN ToFlag F ON S.schedule_type = F.schedule_type
											AND S.WBS_ID = F.WBS_ID
											AND S.task_ID = F.task_ID
	WHERE
		upload_ID = @upload_ID
)