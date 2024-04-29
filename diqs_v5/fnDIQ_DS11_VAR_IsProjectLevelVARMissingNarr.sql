/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Project-Level VAR Without Overall Narrative</title>
  <summary>Is this project-level VAR missing an overall narrative?</summary>
  <message>narrative_type &lt; 200 &amp; narrative_overall is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110491</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsProjectLevelVARMissingNarr] (
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
		AND TRIM(ISNULL(narrative_overall,'')) = ''
)