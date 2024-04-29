/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP / PP Missing in WBS Dictionary</title>
  <summary>Is this WP WBS / PP ID missing in the WBS Dictionary?</summary>
  <message>WBS_ID_WP missing from DS01.WBS_ID list.</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030101</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPOrPPMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost C
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		AND WBS_ID_WP NOT IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID)
)