/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>CA with Budget</title>
  <summary>Does this CA have budget?</summary>
  <message>CA found with BCWSi &gt; 0 (Dollars, Hours, or FTEs).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030062</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesCAHaveBCWS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
		AND WBS_ID_CA IN (
			SELECT WBS_ID
			FROM DS01_WBS
			WHERE upload_ID = @upload_ID AND type = 'CA'
		)
)