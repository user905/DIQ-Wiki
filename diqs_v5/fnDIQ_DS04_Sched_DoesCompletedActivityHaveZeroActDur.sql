/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Completed Activity with Zero Actual Duration</title>
  <summary>Does this completed activity have an actual duration of zero?</summary>
  <message>Activity with AS_date and AF_date with duration_actual_days = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040119</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesCompletedActivityHaveZeroActDur] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND type NOT IN ('SM','FM')
		AND AS_date IS NOT NULL
		AND AF_date IS NOT NULL
		And duration_actual_days = 0
)