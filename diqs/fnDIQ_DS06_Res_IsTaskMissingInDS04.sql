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
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Resource Task Missing in Schedule</title>
  <summary>Is the task this resource is assigned to missing in the schedule?</summary>
  <message>Task_ID missing in DS04.task_ID list (by schedule_type &amp; subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060301</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsTaskMissingInDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for resources where the task_ID is not in DS04.
		We do this with a left join from DS06 to DS04 by schedule type, task ID, and subproject ID
		and filter out any missed joins (DS04.task_ID is null)
	*/
	with Tasks as (
		SELECT schedule_type, task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	)

	SELECT R.*
	FROM DS06_schedule_resources R LEFT OUTER JOIN Tasks T ON R.schedule_type = T.schedule_type 
														 	AND R.task_ID = T.task_ID
															AND ISNULL(R.subproject_ID,'') = T.SubP
		
	WHERE 	R.upload_id = @upload_ID
		AND TRIM(ISNULL(R.task_ID,'')) <> ''
		AND T.task_ID IS NULL
	
)