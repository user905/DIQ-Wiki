/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP WBS ID Missing in WBS Dictionary</title>
  <summary>Is this WP WBS ID missing in the WBS dictionary?</summary>
  <message>WBS_ID_WP not in DS01.WBS_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080622</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsWPWBSMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID
		AND auth_PM_date IS NOT NULL
		AND WBS_ID_WP NOT IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID)
)