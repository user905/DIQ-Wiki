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
  <severity>ALERT</severity>
  <title>Duplicate CD or BCP Entry</title>
  <summary>Does this CD or BCP appear more than once in the schedule?</summary>
  <message>CD or BCP (milestone_level = 1xx) appears more than once in either the FC or BL (or both) (by subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040160</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCDOrBCPDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CDs / BCPs (milestone_level = 1xx) that appear more than once in the schedule.
		It excludes checks on 138 / 139 (approve reprogramming / replan).

		Using the cte, we find the milestone_levels with duplicates by schedule_type, milestone_level, and subproject_ID (group by & having clauses)
		Returned rows in the cte represent milestone_levels that appear more than once (by schedule type & subproject_ID).

		Joining the results to DS04 by milestone_level, schedule_type, and subproject_ID returns the failed rows.

		EXAMPLE: https://www.db-fiddle.com/f/9Lh6nE1xxdkJFPvMRHv7u6/0
	*/

	with Fails AS (
		SELECT schedule_type, milestone_level, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE
				upload_ID = @upload_ID
			AND	milestone_level BETWEEN 100 AND 199
			AND milestone_level NOT IN (138,139)
		GROUP BY schedule_type, milestone_level, ISNULL(subproject_ID,'')
		HAVING COUNT(*) > 1
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Fails F  ON S.schedule_type = F.schedule_type
											AND S.milestone_level = F.milestone_level
											AND ISNULL(S.subproject_ID,'') = F.SubP
	WHERE
		upload_ID = @upload_ID
)