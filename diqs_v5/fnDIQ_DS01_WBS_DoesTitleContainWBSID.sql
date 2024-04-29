/*
<documentation>
  <author>Elias Cooper</author>
  <id>6</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WBS ID contained in Title</title>
  <summary>Is the WBS ID contained in the title?</summary>
  <message>WBS Titles should not contain the WBS ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010008</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesTitleContainWBSID] (
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
		AND Title like '%' + WbS_ID + '%'
)