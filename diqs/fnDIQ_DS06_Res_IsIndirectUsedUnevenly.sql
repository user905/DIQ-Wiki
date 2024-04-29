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
  <title>Uneven Use of Indirect</title>
  <summary>Is Indirect EOC used for some tasks but not all?</summary>
  <message>Task lacking Indirect EOC despite Indirect use elsewhere (if Indirect is used on tasks, it must be used for all tasks).</message>
  <grouping>task_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060262</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsIndirectUsedUnevenly] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see that, when Indirect is used as an EOC type, it is
		used on every task.

		Step 1. collect DS06 indirect task_ids by schedule type and subproject into a cte, Ovhd.
		Step 2. Join back to DS06 non-indirect resources by task_id, schedule_type, and subproject.

		Any missed joins are problematic.
	*/

	with Ovhd as (
		SELECT task_ID, schedule_type, TRIM(ISNULL(subproject_ID,'')) SubP
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND EOC = 'Indirect'
	)

	SELECT R.*
	FROM DS06_schedule_resources R LEFT OUTER JOIN Ovhd O ON R.task_ID = O.task_ID AND R.schedule_type = O.schedule_type AND TRIM(ISNULL(R.subproject_ID,'')) = O.SubP
	WHERE upload_id = @upload_ID
        AND EXISTS (SELECT 1 FROM Ovhd)
		AND O.task_ID IS NULL
		AND R.EOC <> 'Indirect'
)