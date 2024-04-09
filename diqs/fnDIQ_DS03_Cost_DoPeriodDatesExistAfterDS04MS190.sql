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
  <severity>ALERT</severity>
  <title>Cost Periods Found After CD-4 Approved</title>
  <summary>Are there period dates after CD-4 approved?</summary>
  <message>Period Dates found after CD-4 approved (DS04.milestone_level = 190).</message>
  <grouping>period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030073</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoPeriodDatesExistAfterDS04MS190] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		The script filters for DS03 period_dates > ES or EF dates for milestone 190 (CD-4 approved) in the BL schedule.
		It uses coalesce to pick whichever date is available.
	*/

    -- Insert statements for procedure here
	SELECT 
		* 
	FROM 
		DS03_Cost C
	WHERE 
			upload_ID = @upload_ID
		AND period_date > (
			SELECT COALESCE(ES_Date,EF_Date) 
			FROM DS04_schedule 
			WHERE upload_ID = @upload_ID AND milestone_level = 190 AND schedule_type = 'BL'
		)
)