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
  <title>Task with Overhead EOC Only</title>
  <summary>Is this task resource-loaded with only Overhead EOC resources?</summary>
  <message>Task lacking EOC other than Overhead (task_ID where EOC = Overhead only).</message>
  <grouping>task_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060241</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsOverheadOnItsOwn] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for tasks where the only resource EOC is Overhead.
		
		We do this by first getting a list of all overhead resources for both BL & FC schedules in cte Ovhd.
		Then we get a list of all non-overhead resources for both BL & FC schedules in cte NonO.
		Finally, we join the two together and look for any rows where the overhead resource is not joined to a non-overhead resource in cte Flags.

		We then join back to DS06 by task & resource ID to get our flagged rows.
	*/
	with Ovhd as (
		select task_ID, schedule_type
		from DS06_schedule_resources
		where upload_ID = @upload_ID and EOC = 'Overhead'
	), NonO as (
		select task_ID, schedule_type
		from DS06_schedule_resources
		where upload_ID = @upload_ID and EOC <> 'Overhead'
	), Flags as (
		select Ovhd.task_ID, Ovhd.schedule_type
		from Ovhd left outer join NonO on Ovhd.task_ID = NonO.task_ID AND Ovhd.schedule_type = NonO.schedule_type
		where NonO.task_ID is null
	)

	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN Flags F 
									ON R.task_ID = F.task_ID 
									AND R.schedule_type = F.schedule_type
	WHERE
			R.upload_id = @upload_ID
		AND R.EOC = 'Overhead'
)