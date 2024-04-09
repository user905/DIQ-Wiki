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
  <severity>WARNING</severity>
  <title>Resource Loaded CA or WBS</title>
  <summary>Is this WBS of type CA or WBS resource loaded?</summary>
  <message>WBS ID of type CA or WBS (DS01.type = CA or WBS) found with resources (task_ID found in DS06.task_ID list by subproject).</message>
  <grouping>task_ID,schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060283</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsCAOrWBSResourceLoaded] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for CA or WBS type WBS IDs with resources.

		First, collect any DS04 tasks with DS01.WBS type CA or WBS.

		Then, join those tasks to the DS06 resources.

		Any joins are a flag.
	*/
	with Task as (
		SELECT WBS_ID, task_ID, schedule_type, ISNULL(subproject_ID,'') SubP 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND WBS_ID IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_id AND type IN ('CA','WBS'))
	)
	
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN Task T ON R.task_ID = T.task_ID AND R.schedule_type = T.schedule_type AND ISNULL(R.subproject_ID,'') = T.SubP
	WHERE upload_id = @upload_ID
	
)