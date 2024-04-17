/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WP or PP Missing CA Ancestor</title>
  <summary>Is a CA missing from the ancestry tree of this WP or PP?</summary>
  <message>WP or PP missing CA ancestry tree</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010037</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWPorPPLackingCAAncestor] (
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
		AND type IN ('WP','PP')
		AND WBS_ID NOT IN (
				SELECT WBS_ID 
				FROM AncestryTree_Get(@upload_ID)
				WHERE Ancestor_Type = 'CA'
			)
)