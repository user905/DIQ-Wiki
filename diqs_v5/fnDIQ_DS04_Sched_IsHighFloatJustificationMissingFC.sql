/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>High Float Missing Justification (FC)</title>
  <summary>Is this FC task with high float missing a justification in the forecast schedule?</summary>
  <message>justification_high_float is blank where task schedule_type = FC and float_total_days &gt; 10% of project remaining duration.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040184</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsHighFloatJustificationMissingFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with RemDur as (
		SELECT MAX(DATEDIFF(d,CPP_status_date,EF_date)) RemDur
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND milestone_level = 175
	)
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'FC' --FC tasks only
		AND float_total_days / NULLIF((SELECT TOP 1 RemDur FROM RemDur),0) >= .1 --float > 10% of remaining duration
		AND TRIM(ISNULL(justification_float_high,''))='' --no justification
		AND (SELECT TOP 1 RemDur FROM RemDur) > 0 -- remaining duration > 0 days
)