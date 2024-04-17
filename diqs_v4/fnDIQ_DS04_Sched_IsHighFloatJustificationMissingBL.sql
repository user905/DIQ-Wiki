/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>High Float Missing Justification (BL)</title>
  <summary>Is this task with high float missing a justification in the baseline schedule?</summary>
  <message>BL Task with high float (float_total_days &gt; 10% of project remaining duration) is lacking a justification (justification_high_float is blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040603</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsHighFloatJustificationMissingBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with RemDur as (
		SELECT MAX(DATEDIFF(d,CPP_status_date,EF_date)) RemDur
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND milestone_level = 175
	)
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'BL'
		AND float_total_days / NULLIF((SELECT TOP 1 RemDur FROM RemDur),0) >= .1
		AND TRIM(ISNULL(justification_float_high,''))=''
		AND (SELECT TOP 1 RemDur FROM RemDur) > 0
)