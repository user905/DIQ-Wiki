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
  <table>DS16 Risk Register Tasks</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Impact Schedule Day Spread Missing</title>
  <summary>Are the minimum, likely, and max impact schedule days all equivalent?</summary>
  <message>impact_schedule_minimum_days = impact_schedule_likely_days = impact_schedule_max_days.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1160568</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS16_RR_Tasks_IsImptSchedMissingSpread] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for risk tasks where 
		impact_schedule_min_days = impact_schedule_likely_days = impact_schedule_max_days
	*/
	SELECT 
		*
	FROM 
		DS16_risk_register_tasks
	WHERE 
			upload_ID = @upload_ID
		AND impact_schedule_min_days = impact_schedule_likely_days
		AND impact_schedule_likely_days = impact_schedule_max_days


)