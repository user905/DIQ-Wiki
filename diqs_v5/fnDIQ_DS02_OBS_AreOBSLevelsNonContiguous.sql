/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>OBS Levels Not Contiguous</title>
  <summary>Are the OBS levels contiguous in the OBS hierarchy?</summary>
  <message>OBS level is not contiguous with prior levels in the OBS hierarchy.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020039</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_AreOBSLevelsNonContiguous] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		Child.*
	FROM 
		DS02_OBS Child INNER JOIN DS02_OBS Parent ON Child.parent_OBS_ID = parent.OBS_ID
	WHERE 
			Child.upload_ID = @upload_ID
		AND parent.upload_ID = @upload_ID
		AND parent.level <> Child.level - 1
)