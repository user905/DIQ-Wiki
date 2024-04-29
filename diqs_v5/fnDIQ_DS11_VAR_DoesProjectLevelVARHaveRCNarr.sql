/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Project-Level VAR With Root Cause Narrative</title>
  <summary>Does this project-level VAR have a root cause narrative?</summary>
  <message>narrative_type &lt; 200 &amp; narrative_RC_SVi, narrative_RC_SVc, narrative_RC_CVi, or narrative_RC_CVc.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110480</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_DoesProjectLevelVARHaveRCNarr] (
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
		AND CAST(ISNULL(narrative_type,'1000') as int) < 200 
		AND (
				TRIM(ISNULL(narrative_RC_SVi,'')) <> '' 
			OR TRIM(ISNULL(narrative_RC_CVi,'')) <> ''
			OR TRIM(ISNULL(narrative_RC_SVc,'')) <> ''
			OR TRIM(ISNULL(narrative_RC_CVc,'')) <> ''
		)
)