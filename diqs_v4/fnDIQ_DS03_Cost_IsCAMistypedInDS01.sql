/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA Type Mismatched With WBS Dictionary</title>
  <summary>Is this Control Account WBS ID typed as something other than CA in the WBS Dictionary?</summary>
  <message>WBS_ID_CA not in DS01.WBS_ID list where DS01.type = CA.</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030083</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsCAMistypedInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN DS01_WBS W ON C.WBS_ID_CA = W.WBS_ID
	WHERE 
			C.upload_ID = @upload_ID
		AND	W.upload_ID = @upload_ID
		AND W.[type] <> 'CA'
		AND ISNULL(EVT,'') <> 'K'
)