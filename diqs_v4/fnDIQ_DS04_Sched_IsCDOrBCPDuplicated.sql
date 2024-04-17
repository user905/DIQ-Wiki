/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Duplicate CD or BCP Entry</title>
  <summary>Does this CD or BCP appear more than once in the schedule?</summary>
  <message>CD or BCP (milestone_level = 1xx) appears more than once in either the FC or BL (or both).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040160</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCDOrBCPDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Fails AS (
		SELECT schedule_type, milestone_level
		FROM DS04_schedule
		WHERE
				upload_ID = @upload_ID
			AND	milestone_level BETWEEN 100 AND 199
			AND milestone_level NOT IN (138,139)
		GROUP BY schedule_type, milestone_level
		HAVING COUNT(*) > 1
	)
	SELECT
		S.*
	FROM
		DS04_schedule S,
		Fails F
	WHERE
			upload_ID = @upload_ID
		AND S.schedule_type = F.schedule_type
		AND S.milestone_level = F.milestone_level
)