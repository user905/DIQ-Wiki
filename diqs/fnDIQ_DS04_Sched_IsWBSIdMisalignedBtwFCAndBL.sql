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
  <severity>ERROR</severity>
  <title>WBS Misaligned Between FC &amp; BL</title>
  <summary>Is the WBS ID for this task misaligned between the FC &amp; BL schedules?</summary>
  <message>WBS_ID does not align between the FC &amp; BL schedules for this task_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040220</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsWBSIdMisalignedBtwFCAndBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		Nov 2023 Update: Did v5 introduced subproject_id, which is now used as part of the primary key for a task.
		Task_ids can be duplicated across subprojects, which is why this has been done.
		
		This function looks for baseline and forecast tasks that do not share the same WBS_ID.

		Step 1. Collect all tasks by schedule_type, WBS_ID, task_ID, and subproject_ID in a cte, Tasks.
		Step 2. Join the FC to BL tasks by task_ID & subproject_ID and compare WBS_IDs in another cte, Flags.
		
		Any task_IDs that fail the comparison are problem tasks. 
		
		Step 3. Join Flags back to DS04 by task_ID and subproject_ID to get the results 
		(don't join by schedule_type because tasks in both schedules are part of the problem)
	*/
	with Tasks as (
		SELECT schedule_type, WBS_ID, task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID
	), Flags as (
		SELECT F.task_ID, F.SubP
		FROM Tasks F INNER JOIN Tasks B ON F.task_ID = B.task_ID AND F.SubP = B.SubP AND F.WBS_ID <> B.WBS_ID
		WHERE F.schedule_type = 'FC' AND B.schedule_type = 'BL'
	)


	SELECT S.*
	FROM DS04_schedule S INNER JOIN Flags F ON S.task_ID = F.task_ID AND ISNULL(subproject_ID,'') = F.SubP
	WHERE upload_id = @upload_ID

)