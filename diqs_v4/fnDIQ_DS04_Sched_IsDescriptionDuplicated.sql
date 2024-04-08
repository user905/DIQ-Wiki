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
  <severity>ALERT</severity>
  <title>Duplicate Description</title>
  <summary>Is the description for this task duplicated?</summary>
  <message>Desription is repeated across task IDs (task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040164</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsDescriptionDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for descriptions that are not unique within a schedule (BL or FC).
		It uses a cte to find the descriptions by schedule type that appear more than once.
		It then joins to the schedule by schedule type and description to return the result rows.
	*/

	with ToFlag As (
		SELECT schedule_type, description
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
		GROUP BY schedule_type, [description]
		HAVING COUNT(*) > 1
	)

	SELECT 
		S.*
	FROM
		DS04_schedule S INNER JOIN ToFlag F ON S.schedule_type = F.schedule_type
											AND S.[description] = F.[description]
	WHERE
		upload_ID = @upload_ID

)