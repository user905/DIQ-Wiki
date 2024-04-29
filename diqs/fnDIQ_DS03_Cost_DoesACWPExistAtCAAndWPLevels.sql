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
	/*
		This DIQ looks to see whether Actuals (ACWP) are collected at both the CA and WP levels.

		Update: April, 2024. Scenario D, which allowed for mixing of actuals at the CA & WP levels, has been removed.

		Step 1. Collect data into two ctes: 
		1. One with A at the CA level (WP ID IS NULL) by CA ID (Name: AtCA, for Actuals *at* the CA level)
		2. One with A at the WP level (WP ID IS NOT NULL) by WP ID (Name: AtWP, for Actuals *at* the WP level)

		Step 2. Return the CAs and WPs that have Actuals
	*/

	with AtCA as (
		-- CAs with Actuals
		SELECT WBS_ID_CA
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		AND (ACWPi_Dollars <> 0 OR ACWPi_Hours <> 0 OR ACWPi_FTEs <> 0)
		GROUP BY WBS_ID_CA
	), AtWP as (
		-- WPs with Actuals
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