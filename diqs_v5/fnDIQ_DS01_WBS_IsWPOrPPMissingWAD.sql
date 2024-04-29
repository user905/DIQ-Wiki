/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP / PP Missing WAD</title>
  <summary>Is this WP / PP missing a WAD?</summary>
  <message>WBS_ID not in DS08.WBS_ID_WP list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010002</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWPOrPPMissingWAD] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT	*
    FROM	DS01_WBS
    WHERE	upload_ID = @upload_id
			AND [external] = 'N'
			AND type IN ('PP','WP')
			AND EXISTS (
				SELECT	1
				FROM	DS08_WAD
				WHERE	upload_ID = @upload_id
						AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
			)
			AND WBS_ID NOT IN (
				SELECT	WBS_ID_WP
				FROM	DS08_WAD
				WHERE	upload_ID = @upload_id
			)
)