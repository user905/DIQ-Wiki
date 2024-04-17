/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Planned/Estimated Completion &amp; End of PMB Delta Is Less Than UB</title>
  <summary>Is the delta between the Planned/Estimated Completion &amp; End of PMB milestones less than or equal to the UB days?</summary>
  <message>Delta between Planned/Estimated Completion ES_date (milestone_level = 170) &amp; End of PMB EF_date (milestone_level = 175) &lt;= UB bgt days (DS07.UB_bgt_days).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040203</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPlannedCompletionAndEndOfPMBDeltaLtEqToUB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BLSched as (
		SELECT COALESCE(ES_date, EF_date) MSDate, milestone_level
		FROM DS04_schedule
		WHERE upload_id = @upload_ID AND schedule_type = 'BL' AND milestone_level IN (170, 175)
	), Delta as (
		SELECT DATEDIFF(d, MS170.MSDate, MS175.MSDate) Delta
		FROM BLSched MS170 INNER JOIN BLSched MS175 ON MS170.milestone_level <> MS175.milestone_level
		WHERE MS170.milestone_level = 170 AND MS175.milestone_level = 175
	), UBBgtDays as (
		SELECT UB_bgt_days UB 
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	)
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'BL'
		AND milestone_level IN (170, 175)
		AND (SELECT TOP 1 Delta FROM Delta) <= (SELECT TOP 1 UB FROM UBBgtDays)
)