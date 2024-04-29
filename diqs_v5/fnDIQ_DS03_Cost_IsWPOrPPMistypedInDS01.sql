/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP or PP Type Mismatch with Type in WBS Dictionary</title>
  <summary>Is this Work Package or Package typed as something other than WP or PP in the WBS Dictionary?</summary>
  <message>WBS_ID_WP found DS01.WBS_ID where type &lt;&gt; PP or WP.</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030104</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPOrPPMistypedInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonWPPP as (
		SELECT WBS_ID 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND [type] NOT IN ('WP','PP')
	)
	SELECT 
		* 
	FROM 
		DS03_Cost C INNER JOIN NonWPPP N ON C.WBS_ID_WP = N.WBS_ID
	WHERE 
		upload_ID = @upload_ID
)