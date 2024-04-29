/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Root Cause And/Or Impact Narrative Missing</title>
  <summary>Is this VAR missing either a root cause or an impact narrative (or both)?</summary>
  <message>VAR is missing either a RC SV or CV narrative or an impact narrative (or both).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110494</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsVARMissingRCOrImpactNarr] (
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
		AND NOT (
				TRIM(ISNULL(narrative_RC_CVc,'')) <> ''
			OR	TRIM(ISNULL(narrative_RC_CVi,'')) <> ''
			OR	TRIM(ISNULL(narrative_RC_SVc,'')) <> ''
			OR	TRIM(ISNULL(narrative_RC_SVi,'')) <> ''
			OR	TRIM(ISNULL(narrative_overall,'')) <> ''
		)
		AND (
				TRIM(ISNULL(narrative_impact_cost,'')) <> ''
			OR 	TRIM(ISNULL(narrative_impact_schedule,'')) <> ''
			OR 	TRIM(ISNULL(narrative_impact_technical,'')) <> ''
		)
)