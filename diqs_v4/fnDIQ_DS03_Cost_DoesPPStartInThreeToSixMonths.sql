/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>PP Starting Within 3-6 Months</title>
  <summary>Is this PP scheduled to start within 3-6 months?</summary>
  <message>PP with BCWSi &gt; 0 (Dollar, Hours, or FTEs) and period_date within 3-6 months of CPP Status Date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030068</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesPPStartInThreeToSixMonths] (
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
		AND	(EVT = 'K' OR WBS_ID_WP IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID AND type = 'PP'))
		AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
		AND period_date <= DATEADD(month,6,CPP_status_date)
		AND period_date > DATEADD(month,3,CPP_status_date)
)