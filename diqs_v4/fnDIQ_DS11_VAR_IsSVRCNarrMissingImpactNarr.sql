/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Schedule Variance Root Cause Narrative Missing Impact</title>
  <summary>Is there a schedule variance root cause narrative without an impact statement?</summary>
  <message>narrative_RC_SVi or narrative_RC_SVc found but narrative_impact_schedule is blank or missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110493</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsSVRCNarrMissingImpactNarr] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		AND (
			TRIM(ISNULL(narrative_RC_SVi,'')) <> '' OR 
			TRIM(ISNULL(narrative_RC_SVc,'')) <> '')
		AND TRIM(ISNULL(narrative_impact_schedule,'')) = ''
)