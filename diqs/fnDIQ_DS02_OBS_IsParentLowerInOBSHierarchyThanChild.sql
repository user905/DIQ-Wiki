/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Parent Lower in OBS Hierarchy than Child</title>
  <summary>Is the parent lower in the OBS hierarchy than its child?</summary>
  <message>Parent found at a lower level in the OBS hierarchy than its child, i.e. Parent Level &gt; Child Level.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020048</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsParentLowerInOBSHierarchyThanChild] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		Child.* 
	FROM 
		DS02_OBS Child,
		(SELECT OBS_ID, [Level] FROM DS02_OBS WHERE upload_ID=@upload_ID) Parent
	WHERE 
			upload_ID = @upload_ID
		AND Child.parent_OBS_ID=Parent.OBS_ID
		AND Child.[Level]<=Parent.[Level]
)