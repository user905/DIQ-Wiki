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
  <title>Task with Indirect EOC Only</title>
  <summary>Is this task resource-loaded with only Indirect EOC resources?</summary>
  <message>Task lacking EOC other than Indirect (task_ID where EOC = Indirect only).</message>
  <grouping>task_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060241</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsIndirectOnItsOwn] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		Update: October 2023. Because of DID v5 transition of Overhead to Indirect, this has replaced fnDIQ_DS06_Res_IsOverheadOnItsOwn

		This function looks for tasks where the only resource EOC is Indirect.
		
		Step 1. Get a list of all Indirect resources for both BL & FC schedules in cte Ind.
		Step 2. Get a list of all non-Indirect resources for both BL & FC schedules in cte NonI.
		Step 3. Join the two together and look for any rows where the Indirect resource is not joined to a non-Indirect resource in cte Flags.
		Step 4. Join back to DS06 by task & resource ID to get our flagged rows.
	*/
	with Ind as (
		select task_ID, schedule_type, TRIM(ISNULL(subproject_ID,'')) SubP
		from DS06_schedule_resources
		where upload_ID = @upload_ID and EOC = 'Indirect'
	), NonI as (
		select task_ID, schedule_type, TRIM(ISNULL(subproject_ID,'')) SubP
		from DS06_schedule_resources
		where upload_ID = @upload_ID and EOC <> 'Indirect' AND EOC IS NOT NULL
	), Flags as (
		select Ind.task_ID, Ind.schedule_type, Ind.SubP
		from Ind left outer join NonI on Ind.task_ID = NonI.task_ID AND Ind.schedule_type = NonI.schedule_type AND Ind.SubP = NonI.SubP
		where NonI.task_ID is null
	)

	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN Flags F ON R.task_ID = F.task_ID AND R.schedule_type = F.schedule_type AND TRIM(ISNULL(R.subproject_ID,'')) = F.SubP
	WHERE R.upload_id = @upload_ID AND R.EOC = 'Indirect'
)