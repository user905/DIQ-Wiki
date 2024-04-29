/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA WBS ID Missing in WAD List</title>
  <summary>Is this CA missing in the WAD list?</summary>
  <message>WBS_ID where DS01.type = CA not in DS08.WBS_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010030</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsCAMissingInDS08] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT	*
    FROM	DS01_WBS
    WHERE	upload_ID = @upload_id
			AND [external] = 'N'
			AND type = 'CA'
			AND WBS_ID NOT IN (
				SELECT	WBS_ID
				FROM	DS08_WAD
				WHERE	upload_ID = @upload_id AND TRIM(ISNULL(auth_PM_date,'')) <> ''
			)
)