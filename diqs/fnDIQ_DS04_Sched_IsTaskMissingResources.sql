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
  <title>Missing Resources</title>
  <summary>Is this task missing resources (DS06)?</summary>
  <message>Task_ID is missing in resources (DS06).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040217</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsTaskMissingResources] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		This function looks for tasks missing in the resources file (less SVTs & ZBAs, and by subproject_ID).
		Left join schedule (where subtype NOT IN SVT/ZBA and type NOT IN SM/FM/WS) to resources (DS06) by task_ID, schedule type, and subproject_ID.
		Any row where the resource task id is missing (DS06.task_ID is null) is a flag.
	*/

	with Resources as (
		SELECT task_ID, schedule_type, ISNULL(subproject_ID,'') SubP
		FROM DS06_schedule_resources
		WHERE upload_ID = @upload_ID
	)

	SELECT
		S.*
	FROM
		DS04_schedule S LEFT OUTER JOIN Resources R ON S.schedule_type = R.schedule_type 
													AND S.task_ID = R.task_ID
													AND ISNULL(S.subproject_ID,'') = R.SubP
	WHERE
			S.upload_id = @upload_ID
		AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA')
		AND S.type NOT IN ('SM','FM', 'WS')
		AND R.task_ID IS NULL

)