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
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Task Missing in Schedule</title>
  <summary>Is this task missing in the schedule?</summary>
  <message>task_ID not found in DS04 task_ID list (by schedule_type).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9050282</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsTaskMissingInDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for tasks that do not exist in the DS04 schedule.
		It does this by left joining DS05 to DS04 by schedule type, task ID, and subproject_ID,
		and then filtering for any missing join (DS04.task_ID is null).
	*/
	with Tasks as (
		SELECT schedule_type, task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	)


	SELECT
		L.*
	FROM
		DS05_schedule_logic L LEFT OUTER JOIN Tasks T ON L.schedule_type = T.schedule_type 
													 AND L.task_ID = T.task_ID
													 AND ISNULL(L.subproject_ID,'') = ISNULL(T.SubP,'')
	WHERE
			upload_id = @upload_ID
		AND T.task_ID IS NULL --missed joins means that a task is missing in DS04 for this piece of logic
)