/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>WBS Level Contiguity</title>
  <summary>Are the WBS Levels contiguous in the WBS hierarchy?</summary>
  <message>WBS level is not contiguous with prior levels in the WBS hierarchy.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010002</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_AreWBSLevelsNonContiguous] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		Child.*
	FROM 
		DS01_WBS Child INNER JOIN DS01_WBS as parent ON Child.parent_WBS_ID = parent.WBS_ID
	WHERE 
			Child.upload_ID = @upload_ID
		AND parent.upload_ID = @upload_ID
		AND parent.level <> Child.level - 1
)