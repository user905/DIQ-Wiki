/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Negative Performance</title>
  <summary>Does this WP or PP have negative performance?</summary>
  <message>WP or PP found with BCWPi &lt; 0 (Dollars, Hours, or FTEs).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030079</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsBCWPLessThanZero] (
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
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		AND (BCWPi_dollars < 0 OR BCWPi_FTEs < 0 OR BCWPi_hours < 0)
)