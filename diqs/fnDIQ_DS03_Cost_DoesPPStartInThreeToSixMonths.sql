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
  <status>DELETED</status>
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



	/*
		This test looks for PPs with work projected to start within 3-6 months.
		It filters for BCWSi > 0 and period_date within 3-6 months (using the dateadd functions)
	*/

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