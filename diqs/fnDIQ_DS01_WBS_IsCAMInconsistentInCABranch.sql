/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CAM Not Consistent in CA Branch</title>
  <summary>Does the CA have a different CAM from its descendants?</summary>
  <message>CA and its descendents do not share the same CAM.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010014</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsCAMInconsistentInCABranch] (
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
		AND WBS_ID IN (
			SELECT WBS_ID
			FROM AncestryTree_Get(@upload_ID)
			WHERE Ancestor_Type = 'CA' AND CAM <> Ancestor_CAM
		)
)