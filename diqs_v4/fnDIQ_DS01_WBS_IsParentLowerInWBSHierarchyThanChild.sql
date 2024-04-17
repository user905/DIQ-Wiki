/*
<documentation>
  <author>Elias Cooper</author>
  <id>10</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Parent Lower in WBS Hierarchy than Child</title>
  <summary>Is the parent lower in the WBS hierarchy than its child?</summary>
  <message>Parent found at a lower level in the WBS hierarchy than its child, i.e. Parent Level &gt; Child Level.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010025</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsParentLowerInWBSHierarchyThanChild] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		Child.* 
	FROM 
		DS01_WBS Child,
		(SELECT WBS_ID, [Level] FROM DS01_WBS WHERE upload_ID=@upload_ID) Parent
	WHERE 
			upload_ID = @upload_ID
		AND Child.parent_WBS_ID=Parent.WBS_ID
		AND Child.[Level]<=Parent.[Level]
)