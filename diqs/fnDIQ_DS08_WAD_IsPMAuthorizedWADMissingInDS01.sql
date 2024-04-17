/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WAD Missing In WBS Dictionary</title>
  <summary>Is this PM-authorized WAD missing in the WBS Dictionary (by either WP WBS ID if it exists, or the CA WBS ID)?</summary>
  <message>WBS_ID_CA or WBS_ID_WP missing from DS01.WBS_ID list (where DS08.auth_PM_date is populated).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080610</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthorizedWADMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WBSDict as (
		SELECT WBS_ID
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID  
		AND auth_PM_date IS NOT NULL
		AND (
				TRIM(ISNULL(WBS_ID_WP,'')) <> '' AND WBS_ID_WP NOT IN (SELECT WBS_ID FROM WBSDict) 
			OR 	WBS_ID NOT IN (SELECT WBS_ID FROM WBSDict)
		)
)