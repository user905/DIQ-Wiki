/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>CA or SLPP with WP Ancestor</title>
  <summary>Is this CA or SLPP at a lower level in the WBS hierarchy than a WP in the same branch?</summary>
  <message>CA or SLPP found at a lower level in the WBS hierarchy than a WP in the same branch.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010016</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsCAorSLPPAtLowerLevelThanWP] (
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
	AND	WBS_ID IN (
			SELECT WBS_ID 
			FROM AncestryTree_Get(@upload_ID) A 
			WHERE type IN ('SLPP','CA') AND Ancestor_Type = 'WP'
		)
)