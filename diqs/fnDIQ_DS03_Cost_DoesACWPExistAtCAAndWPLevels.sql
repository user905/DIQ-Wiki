/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Actuals At CA and WP Level</title>
  <summary>Are actuals collected at both the CA and WP level?</summary>
  <message>CAs and WPs found with ACWPi &lt;&gt; 0 (Dollars, Hours, or FTEs)</message>
  <grouping>WBS_ID_CA,WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030058</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesACWPExistAtCAAndWPLevels] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with AtCA as (
		SELECT WBS_ID_CA
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		AND (ACWPi_Dollars <> 0 OR ACWPi_Hours <> 0 OR ACWPi_FTEs <> 0)
		GROUP BY WBS_ID_CA
	), AtWP as (
		SELECT WBS_ID_WP
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		AND (ACWPi_Dollars <> 0 OR ACWPi_Hours <> 0 OR ACWPi_FTEs <> 0)
		GROUP BY WBS_ID_WP
	)
	SELECT 
		*
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND (ACWPi_dollars <> 0 OR ACWPi_FTEs <> 0 OR ACWPi_hours <> 0) -- Only rows with Actuals
		AND (SELECT COUNT(*) FROM AtCA) > 0 -- Only if AtCA has rows
		AND (SELECT COUNT(*) FROM AtWP) > 0 -- Only if AtWP has rows
)