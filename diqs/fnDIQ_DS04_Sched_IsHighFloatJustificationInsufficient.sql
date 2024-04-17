/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Insufficient High Float Justification</title>
  <summary>Is a sufficient justification lacking for this task with high float?</summary>
  <message>High float justification was insufficient (lacking at least two words).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040183</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsHighFloatJustificationInsufficient] (
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
			upload_ID = @upload_ID
		AND justification_float_high IS NOT NULL
		AND CHARINDEX(' ',TRIM([justification_float_high])) = 0
)