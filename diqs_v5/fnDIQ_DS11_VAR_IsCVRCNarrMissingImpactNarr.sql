/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Cost Variance Root Cause Narrative Missing Impact</title>
  <summary>Is there a cost variance root cause narrative without an impact statement?</summary>
  <message>narrative_RC_CVi or narrative_RC_CVc found but narrative_impact_cost is blank or missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110487</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsCVRCNarrMissingImpactNarr] (
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
			TRIM(ISNULL(narrative_RC_CVi,'')) <> '' OR 
			TRIM(ISNULL(narrative_RC_CVc,'')) <> '')
		AND TRIM(ISNULL(narrative_impact_cost,'')) = ''
)