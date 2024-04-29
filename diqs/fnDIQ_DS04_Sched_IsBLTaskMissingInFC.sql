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
  <title>Baseline Task Missing In Forecast</title>
  <summary>Is this task missing in the forecast schedule?</summary>
  <message>Task found in baseline schedule (schedule_type = BL) but not in forecast (schedule_type = FC) (by subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040145</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsBLTaskMissingInFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		This function looks for BL tasks not in the FC (by subproject ID)
	*/

	--FC Tasks
	with FCTasks as (
		SELECT task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)

	SELECT
		B.*
	FROM
		DS04_schedule B LEFT OUTER JOIN FCTasks F ON B.task_ID = F.task_ID AND ISNULL(B.subproject_ID,'') = F.SubP
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'BL' -- Baseline Tasks
		AND F.task_ID IS NULL --Any missed joins fail

)