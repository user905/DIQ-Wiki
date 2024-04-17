/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>WP or PP At Level 1 or 2</title>
  <summary>Is the WP or PP at Level 1 or 2 in the WBS hierarchy?</summary>
  <message>WP or PP at Level 1 or 2 in the WBS hierarchy</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010036</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWPorPPAtLevelOneOrTwo] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS01_WBS
	WHERE 
			upload_ID = @upload_ID
		AND type IN ('WP', 'PP') 
		AND level IN (1,2)
)