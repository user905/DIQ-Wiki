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
  <title>Forecast Task Missing In Baseline</title>
  <summary>Is this task missing in the baseline schedule?</summary>
  <message>Task found in forecast schedule (schedule_type = FC) but not in baseline (schedule_type = BL) (by subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040178</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsFCTaskMissingInBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for FC tasks not in the BL (by subproject ID)
	*/

	--BL Tasks
	with BLTasks as (
		SELECT task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)

	SELECT
		F.*
	FROM
		DS04_schedule F LEFT OUTER JOIN BLTasks B ON F.task_ID = B.task_ID AND ISNULL(F.subproject_ID,'') = B.SubP
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'FC' -- Forecast Tasks
		AND B.task_ID IS NULL --Any missed joins fail
)