/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Cost Missing Resources</title>
  <summary>Is this WP or PP missing accompanying Resources (DS06) by EOC?</summary>
  <message>WP or PP with BCWSi &lt;&gt; 0 (Dollars, Hours, or FTEs) is missing Resources (DS06) by EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030100</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWorkMissingResourcesInDS06] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Resources As (
		SELECT S.WBS_ID, R.EOC
		FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID
			AND R.upload_ID = @upload_ID
			AND S.schedule_type = 'BL'
			AND R.schedule_type = 'BL'
			AND (R.budget_dollars > 0 OR R.budget_units > 0)
		GROUP BY S.WBS_ID, R.EOC
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C LEFT OUTER JOIN Resources R ON C.WBS_ID_WP = R.WBS_ID 
												AND C.EOC = R.EOC
	WHERE
			upload_ID = @upload_ID
		AND (BCWSi_dollars <> 0 OR BCWSi_FTEs <> 0 AND BCWSi_hours <> 0)
		AND R.wbs_ID IS NULL
)