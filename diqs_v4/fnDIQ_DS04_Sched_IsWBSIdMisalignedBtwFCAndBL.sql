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
  <severity>ERROR</severity>
  <title>WBS Misaligned Between FC &amp; BL</title>
  <summary>Is the WBS ID for this task misaligned between the FC &amp; BL schedules?</summary>
  <message>WBS_ID does not align between the FC &amp; BL schedules for this task_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040220</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsWBSIdMisalignedBtwFCAndBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for baseline and forecast tasks that do not share the same WBS_ID.
		The 'Flags' cte joins the FC to BL schedules by task_ID and makes the WBS_ID comparison.
		Any task_IDs that fail the comparison are returned and used to filter the final results in the 
		bottom select statement so that both the BL & FC tasks are reported to the user.

		Note: The CTE was used in favor of a subselect to increase code clarity.
	*/
	with Tasks as (
		SELECT schedule_type, WBS_ID, task_ID 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID
	), Flags as (
		SELECT F.task_ID
		FROM Tasks F INNER JOIN Tasks B ON F.task_ID = B.task_ID AND F.WBS_ID <> B.WBS_ID
		WHERE F.schedule_type = 'FC' AND B.schedule_type = 'BL'
	)


	SELECT
		*
	FROM
		DS04_schedule 
	WHERE
			upload_id = @upload_ID
		AND task_ID IN (SELECT task_ID FROM Flags)

)