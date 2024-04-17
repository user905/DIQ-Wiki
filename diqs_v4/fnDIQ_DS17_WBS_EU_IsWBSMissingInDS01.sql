/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WBS Missing in WBS Hierarchy</title>
  <summary>Is this WBS missing in the WBS hierarchy?</summary>
  <message>WBS missing in DS01.WBS_ID list.</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9170583</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsWBSMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS17_WBS_EU
	WHERE 
			upload_ID = @upload_ID
		AND WBS_ID NOT IN  (
			SELECT WBS_ID
			FROM DS01_WBS
			WHERE upload_ID = @upload_ID
		)
)