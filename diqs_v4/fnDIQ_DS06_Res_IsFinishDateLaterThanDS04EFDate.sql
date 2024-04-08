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
  <title>Resource Finishing Later Than Task</title>
  <summary>Is this resource scheduled to finish after its parent task?</summary>
  <message>Resource finish (finish_date) &gt; DS04.EF_date (by task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060296</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsFinishDateLaterThanDS04EFDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for resources that finish after the task is scheduled to complete.
		It does this by joining DS06 to DS04 by task_ID, filtering for only BL resources and tasks,
		and comparing the DS06.finish_date to the DS04.EF_date.
	*/
	SELECT
		R.*
	FROM
		DS06_schedule_resources R,
		(SELECT task_ID, EF_date FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'BL') S
	WHERE
			R.upload_id = @upload_ID
		AND R.task_ID = S.task_ID
		AND R.schedule_type = 'BL'
		AND R.finish_date > S.EF_date
	
)