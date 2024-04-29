/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Lag Missing Justification</title>
  <summary>Is the lag for this task missing a justification?</summary>
  <message>Lag_days &lt;&gt; 0 and lacking a justification in DS04 schedule (justification_lag is null or blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9050280</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsLagMissingJustification] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		L.*
	FROM
		DS05_schedule_logic L INNER JOIN DS04_schedule S ON L.schedule_type = S.schedule_type 
														AND L.task_ID = S.task_ID
														AND ISNULL(L.subproject_ID,'') = ISNULL(S.subproject_ID,'')
	WHERE
			L.upload_id = @upload_ID
		AND S.upload_ID = @upload_ID
		AND lag_days <> 0
		AND TRIM(ISNULL(justification_lag,''))=''
)