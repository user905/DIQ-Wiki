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
  <title>EVT Misaligned Between BL &amp; FC</title>
  <summary>Is the EVT for this task misaligned between BL &amp; FC schedules?</summary>
  <message>Task EVT where schedule_type = FC &lt;&gt; EVT where schedule_type = BL.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040177</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsEVTMisalignedBtwBLAndFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for tasks where the BL & FC EVTs are not the same.
		It uses a CTE to find the list of task_ids that fail this test
		and then returns both the BL & FC tasks matching those IDs.
	*/
	with Tasks as (
		SELECT schedule_type, task_ID, ISNULL(EVT,'') EVT, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), Trips as (
		SELECT F.Task_ID, F.SubP
		FROM Tasks F INNER JOIN Tasks B ON F.task_ID = B.task_ID AND F.SubP = B.SubP AND F.EVT <> B.EVT
		WHERE F.schedule_type = 'FC' AND B.schedule_type = 'BL'
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Trips T ON S.task_ID = T.task_ID AND ISNULL(S.subproject_ID,'') = T.SubP
	WHERE
		upload_id = @upload_ID
)