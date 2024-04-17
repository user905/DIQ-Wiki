/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WBS Of Non-WP or PP Type</title>
  <summary>Is this WBS of a type other than WP or PP?</summary>
  <message>WBS_ID not in DS01.WBS_ID where type = WP or PP.</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9170584</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsWBSNotWPOrPP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		E.*
	FROM 
		DS17_WBS_EU E INNER JOIN DS01_WBS W ON E.WBS_ID = W.WBS_ID
	WHERE 
			E.upload_ID = @upload_ID
		AND W.upload_ID = @upload_ID
		AND W.[type] NOT IN ('WP','PP')
)