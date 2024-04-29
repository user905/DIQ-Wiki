/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Parent WBS ID Missing In WBS List</title>
  <summary>Is the Parent WBS ID missing in the WBS ID list?</summary>
  <message>Parent WBS ID not found in the WBS ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010039</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsParentWBSIDMissingFromWBSIDList] (
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
    AND [external] = 'N'
		AND parent_WBS_ID NOT IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID=@upload_ID)
)