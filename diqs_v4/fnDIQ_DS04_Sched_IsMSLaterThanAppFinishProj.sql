/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Milestone After Approve Finish Project</title>
  <summary>Is this milestone after the approve finish project milestone?</summary>
  <message>Milestone has an early finish date (EF_Date) later than the approve finish project milestone (milestone_level = 199).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040193</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMSLaterThanAppFinishProj] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with MS199 as (
		SELECT EF_Date, schedule_type 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 199
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN MS199 M 	ON S.schedule_type = M.schedule_type
											AND S.EF_date > M.EF_date
	WHERE
			upload_id = @upload_ID
		AND S.milestone_level <> 199
		AND S.milestone_level IS NOT NULL
)