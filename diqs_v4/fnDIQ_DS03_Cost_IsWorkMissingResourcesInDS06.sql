/*

The name of the function should include the ID and a short title, for example: DIQ0001_WBS_Pkey or DIQ0003_WBS_Single_Level_1

author is your name.

id is the unique DIQ ID of this test. Should be an integer increasing from 1.

table is the table name (flat file) against which this test runs, for example: "FF01_WBS" or "FF26_WBS_EU".
DIQ tests might pull data from multiple tables but should only return rows from one table (split up the tests if needed).
This value is the table from which this row returns tests.

status should be set to TEST, LIVE, SKIP.
TEST indicates the test should be run on test/development DIQ checks.
LIVE indicates the test should run on live/production DIQ checks.
SKIP indicates this isn't a test and should be skipped.

severity should be set to WARNING or ERROR. ERROR indicates a blocking check that prevents further data processing.

summary is a summary of the check for a technical audience.

message is the error message displayed to the user for the check.

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



	/*
		This test looks for cost data with no accompanying resources (DS06).

		The test first creates a CTE, Resources, that joins DS04 Task IDs to DS06 Task IDs 
		where there is budget, and groups by DS04 WBS ID & DS06 EOC. 
		
		Left joining this back to DS03, we then get a list of WBS IDs alongside their EOCs
		(where there is budget).

		Any missing joins are our failed rows.
	*/

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