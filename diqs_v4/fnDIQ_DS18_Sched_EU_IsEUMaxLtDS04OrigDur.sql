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
  <table>DS18 Sched EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EU Maximum Days Less Than Original Duration</title>
  <summary>Are the EU maximum days for this task less than the original duration?</summary>
  <message>EU_max_days &lt; DS04.duration_original_days by schedule_type &amp; task_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9180588</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS18_Sched_EU_IsEUMaxLtDS04OrigDur] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for schedule EU rows where 
		EU_max_days < BL DS04.original_duration (by task_ID by schedule_type)
	*/
	SELECT 
		E.*
	FROM 
		DS18_schedule_EU E INNER JOIN DS04_schedule S ON E.task_ID = S.task_ID AND E.schedule_type = S.schedule_type
	WHERE 
			E.upload_ID = @upload_ID
		AND S.upload_ID = @upload_ID
		AND EU_max_days < duration_original_days


)