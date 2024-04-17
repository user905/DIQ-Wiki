/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>OBS ID Missing in DS02 OBS List</title>
  <summary>Is the OBS ID missing in DS02 OBS?</summary>
  <message>OBS ID missing in the DS02 OBS ID list</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010023</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsOBSIDMissingInDS02OBSIDList] (
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
		AND OBS_ID IS NOT NULL
		and OBS_ID NOT IN (SELECT OBS_ID FROM DS02_OBS WHERE upload_ID = @upload_ID)
)