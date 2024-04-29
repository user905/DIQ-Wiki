/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Parent WBS ID Missing From Child WBS ID</title>
  <summary>Is the Parent WBS ID missing from the Child WBS ID?</summary>
  <message>Parent WBS ID was not not found in the Child WBS ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010027</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsParentWBSIDMissingFromChildWBSID] (
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
		AND WBS_ID NOT LIKE '%' + parent_WBS_ID + '%'
)