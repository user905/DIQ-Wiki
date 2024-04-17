/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>SLPP or PP VAR With Root Cause Narrative</title>
  <summary>Is there a root cause SV or CV narrative for this SLPP or PP VAR?</summary>
  <message>narrative_type = 200 or 400 &amp; narrative_RC_SVi, narrative_RC_SVc, narrative_RC_CVi, or narrative_RC_CVc.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110481</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_DoesSLPPorPPVARHaveRCNarr] (
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
		AND narrative_type IN ('200','400')
		AND (
			TRIM(ISNULL(narrative_RC_SVi,'')) <> '' 
			OR TRIM(ISNULL(narrative_RC_CVi,'')) <> ''
			OR TRIM(ISNULL(narrative_RC_SVc,'')) <> ''
			OR TRIM(ISNULL(narrative_RC_CVc,'')) <> ''
		)
)