/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EVT Missing Justification</title>
  <summary>Is this task missing a required justification for the selected EVT?</summary>
  <message>Task found with EVT = B, G, H, J, L, M, N, O, or P but no justification (justification_EVT = null or blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040176</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsEVTJustificationMissing] (
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
		AND EVT in ('B', 'G', 'H', 'J', 'L', 'M', 'N', 'O', 'P')
		AND TRIM(ISNULL(justification_EVT,'')) = ''
)