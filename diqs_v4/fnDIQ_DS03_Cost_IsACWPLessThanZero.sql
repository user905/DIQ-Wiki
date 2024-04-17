/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Negative Actuals</title>
  <summary>Does this CA, WP, or PP have negative actuals?</summary>
  <message>CA, WP, or PP found with ACWPi &lt; 0 (Dollars, Hours, or FTEs).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030076</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsACWPLessThanZero] (
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
		AND (ACWPi_dollars < -10 OR ACWPi_FTEs < 0 OR ACWPi_hours < 0)
)