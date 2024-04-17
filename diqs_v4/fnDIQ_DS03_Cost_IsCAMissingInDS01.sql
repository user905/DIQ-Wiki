/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA Missing In WBS</title>
  <summary>Is this CA missing in the WBS (DS01)?</summary>
  <message>The CA WBS ID was not found in the WBS (DS01).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030082</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsCAMissingInDS01] (
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
		AND WBS_ID_CA NOT IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID)
)