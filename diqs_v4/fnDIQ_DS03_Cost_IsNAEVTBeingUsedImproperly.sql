/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Invalid Use of NA EVT</title>
  <summary>Has EVT of type NA been selected for non-Control Account data?</summary>
  <message>EVT = NA on WP row or CA row not marked as type 'CA' in DS01 (WBS).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030109</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsNAEVTBeingUsedImproperly] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND EVT = 'NA'
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
)