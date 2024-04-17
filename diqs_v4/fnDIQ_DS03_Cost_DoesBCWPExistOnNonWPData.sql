/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Performance On SLPP, CA, or PP</title>
  <summary>Has this SLPP, CA, or PP collected performance?</summary>
  <message>SLPP, CA, or PP found with BCWPi &lt;&gt; 0 (Dollars, Hours, or FTEs).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030061</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesBCWPExistOnNonWPData] (
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
		AND (BCWPi_dollars <> 0 OR BCWPi_FTEs <> 0 OR BCWPi_hours <> 0)
		AND (TRIM(ISNULL(WBS_ID_WP,'')) = '' OR EVT = 'K')
)