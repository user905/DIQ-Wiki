/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Future Performance</title>
  <summary>For this WP, was performance collected in the future?</summary>
  <message>WP found with BCWPi &lt;&gt; 0 (Dollars, Hours, or FTEs) and period_date &gt; cpp_status_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030060</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesBCWPExistInTheFuture] (
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
		AND period_date > CPP_status_date
)