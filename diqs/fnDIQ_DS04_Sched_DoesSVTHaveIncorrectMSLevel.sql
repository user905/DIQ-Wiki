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
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SVT Not Of Allowed Milestone Type</title>
  <summary>Is this non-milestone task marked as an SVT?</summary>
  <message>Task marked as SVT (subtype = SVT), but is not of the appropriate milestone level (milestone_level = 100-135, 140-175, 190-199, 3xx, or 7xx).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040133</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesSVTHaveIncorrectMSLevel] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for tasks marked SVT that are not:
		1. project start/DOE O 413.3B/CD/BCP milestones (ms_level: 100-135, 140-170, 190-199)
		2. customer driven milestones (3xx)
		3. external driven milestones (7xx)
	*/

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND ISNULL(subtype,'') = 'SVT'
		AND NOT (
			milestone_level BETWEEN 100 AND 135 OR 
			milestone_level BETWEEN 140 AND 170 OR
			milestone_level BETWEEN 190 AND 199 OR
			milestone_level BETWEEN 300 AND 399 OR
			milestone_level BETWEEN 700 AND 799
		)

)