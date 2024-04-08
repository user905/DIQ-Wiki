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
  <title>Uneven Use of Overhead</title>
  <summary>Is Overhead EOC used for some tasks but not all?</summary>
  <message>Task lacking overhead EOC despite overhead use elsewhere (if overhead is used on tasks, it must be used for all tasks).</message>
  <grouping>task_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060240</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsOverheadUsedUnevenly] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see that, when Overhead is used as an EOC type, it is
		used on every task.

		To do this, first collect task_ids where Overhead exists by schedule type into a cte, Ovhd.
		Then select to see which task_ids are not found in that list.
	*/

	with Ovhd as (
		SELECT task_ID, schedule_type
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND EOC = 'Overhead'
	)

	SELECT
		*
	FROM
		DS06_schedule_resources
	WHERE
			upload_id = @upload_ID
		AND (
				schedule_type = 'FC' AND task_ID NOT IN (SELECT task_ID from Ovhd WHERE schedule_type = 'FC') OR
				schedule_type = 'BL' AND task_ID NOT IN (SELECT task_ID from Ovhd WHERE schedule_type = 'BL')
		)
	
)