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
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Completed Milestone with Non-Zero Actual Duration</title>
  <summary>Does this completed milestone have an actual duration greater than zero?</summary>
  <message>Milestone with AS_date and AF_date with duration_actual_days &gt; 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040120</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesCompletedMSHaveNonZeroActDur] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		NOTE: THIS TEST WAS DELETED BECAUSE THE LOGIC WAS INCLUDED IN DS04_Sched_DoesMSHaveNonZeroDur.

		This function looks for milestones that have finished, 
		but that have an actual duration not equal to zero.

		It does this by limiting to start and finish milestones (i.e. type = SM or FM)
		and filtering for anything with AS & AF dates.
		Finally, anything with actual duration <> 0 fails.
	*/

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND type IN ('SM','FM')
		AND AS_date IS NOT NULL
		AND AF_date IS NOT NULL
		And duration_actual_days <> 0
)