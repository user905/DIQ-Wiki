/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS Type WAD</title>
  <summary>Is this WAD a WBS type WBS element in the WBS dictionary?</summary>
  <message>WBS_ID or WBS_ID_WP in DS01.WBS_ID list where DS01.type = WBS.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080620</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsWADOfDS01TypeWBS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WBSTypes as (
		SELECT WBS_ID 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND type = 'WBS'
	)
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID
		AND (
				WBS_ID_WP IN (SELECT WBS_ID FROM WBSTypes) OR
				WBS_ID IN (SELECT WBS_ID FROM WBSTypes)
		)
)