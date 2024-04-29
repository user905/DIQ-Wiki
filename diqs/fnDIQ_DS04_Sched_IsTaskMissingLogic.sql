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
  <title>Missing Logic</title>
  <summary>Is this task missing logic?</summary>
  <message>Task_ID missing from DS05.task_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040216</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsTaskMissingLogic] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for tasks missing in the logic file (almost every task should have logic).
		It does this by left joining schedule to logic by task_ID, schedule type, and subproject id.
		
		Any row where the logic task id is missing (DS05.task_ID is null) is a flag.

		Exceptions: 
		1. The very first task, the approve start project MS (milestone_level = 100), 
		has no predecessors, i.e. it will not appear in DS05.task_ID. 
		2. SVT subtypes have no predecessors
		3. WBS summary types have no logic (type = WS)

		Other Exceptions, which are not implemented here explicitly because they are accounted for by the
		direction of the join:
		4. last MSs of the project (ms_level = 199) has no successor;
		5. LOE activities (type = LOE or EVT = A) must have at least two preds (one is SS, one FF) and no successor;
	*/

    with Logic as (
        SELECT schedule_type, task_ID, subproject_ID
        FROM DS05_schedule_logic
        WHERE upload_ID = @upload_ID
    )

	SELECT
		S.*
	FROM
		DS04_schedule S LEFT OUTER JOIN Logic L ON S.schedule_type = L.schedule_type 
                                                AND S.task_ID = L.task_ID
												AND ISNULL(S.subproject_ID,'') = ISNULL(L.subproject_ID,'')
	WHERE
			S.upload_id = @upload_ID
		AND ISNULL(S.milestone_level,0) <> 100
		AND ISNULL(S.subtype,'') <> 'SVT'
		AND S.type <> 'WS'
		AND L.task_ID IS NULL

)