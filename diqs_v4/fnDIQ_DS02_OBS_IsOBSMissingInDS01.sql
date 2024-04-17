/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>OBS ID Missing in DS01 OBS List</title>
  <summary>Is the OBS ID missing in the DS01 OBS List?</summary>
  <message>OBS ID is missing in the DS02 OBS ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9020046</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsOBSMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS02_OBS
	WHERE
			upload_ID = @upload_ID
		AND TRIM(ISNULL(OBS_ID,'')) <> ''
		and OBS_ID NOT IN (SELECT OBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID)
)