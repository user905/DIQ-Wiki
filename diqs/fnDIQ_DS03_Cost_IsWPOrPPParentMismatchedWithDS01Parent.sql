/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP or PP Parent Mismatched with DS01 (WBS) Parent</title>
  <summary>Is the parent ID of this WP or PP misaligned with what is in DS01 (WBS)?</summary>
  <message>The parent ID for this WP or PP does not align with the parent ID found in DS01 (WBS).</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030105</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPOrPPParentMismatchedWithDS01Parent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WBSDict as (
		SELECT WBS_ID Child, parent_WBS_ID Parent
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN WBSdict W ON C.WBS_ID_WP = W.Child
										AND C.WBS_ID_CA <> W.Parent
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
)