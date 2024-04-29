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
  <severity>ALERT</severity>
  <title>Labor Overlap</title>
  <summary>Is this labor resource scheduled to work on multiple tasks at the same time?</summary>
  <message>Labor resource start/finish dates overlap across multiple task_IDs.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060246</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_DoLaborDatesOverlap] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for overlapping start/finish dates for any given resource.
		E.g. When a resource A is scheduled to work a task A from 1 Jan 2022 - 1 Feb 2022,
		then it should not also be working a task B from 15 Jan 2022 - 15 Feb 2022.
		
		To do this, we join DS06 to itself by resource ID, subproject, and schedule type.
		We then filter for any rows where the left task IDs <> right tasks IDs,
		and where left start <= right end and right start <= left end.
		
		See here for overlap logic: https://stackoverflow.com/a/325939/2264225

		Doing this in a cte gets us our flags.
	*/

	with Flags as (
		SELECT R1.task_ID, R1.resource_ID, R1.schedule_type, ISNULL(R1.subproject_ID,'') SubP
		FROM DS06_schedule_resources R1 INNER JOIN DS06_schedule_resources R2 ON R1.schedule_type = R2.schedule_type
																			 AND R1.resource_ID = R2.resource_ID
																			 AND ISNULL(R1.subproject_ID, '') = ISNULL(R2.subproject_ID, '')
																			 AND R1.task_ID <> R2.task_ID
																			 AND R1.start_date <= R2.finish_date
																			 AND R2.start_date <= R1.finish_date
		WHERE	R1.upload_ID = @upload_ID
			AND R2.upload_ID = @upload_ID
			AND (R1.EOC = 'Labor' OR R1.[type] = 'Labor')
			AND (R2.EOC = 'Labor' OR R2.[type] = 'Labor')
		GROUP BY R1.task_ID, R1.resource_ID, R1.schedule_type, ISNULL(R1.subproject_ID,'')
	)

	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN Flags F ON R.schedule_type = F.schedule_type
													AND R.task_ID = F.task_ID
													AND R.resource_ID = F.resource_ID
													AND ISNULL(R.subproject_ID, '') = F.SubP
	WHERE upload_ID = @upload_ID AND (EOC = 'Labor' OR [type] = 'Labor')
	

	
)