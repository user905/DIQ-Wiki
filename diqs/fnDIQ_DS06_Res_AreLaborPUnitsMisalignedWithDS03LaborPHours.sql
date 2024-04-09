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
  <title>Resource Labor Performance Misaligned with Cost</title>
  <summary>Are the resource labor performance units misaligned with the cost labor performance hours?</summary>
  <message>Resource labor performance units (actual_units where EOC or type = Labor) &lt;&gt; cost labor performance hours (SUM of DS03.BCWPi_dollars where EOC = Labor).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060287</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborPUnitsMisalignedWithDS03LaborPHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 rows can exist with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		These have been excluded from the test using ISNULL(is_indirect,'') <> 'Y'.

		This function looks for resources where resource labor performance units 
		(P6 calls this actual_units) do not align with DS03 cost labor performance hours.

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect WBS IDs with their BCWPc labor hours, into a cte, CostWBS.

		Then, we join DS04 to DS06 by task ID & subproject ID to get labor performance units by Schedule WBS ID, and
		insert into another cte, ScheduleWBS. (Note: We do this only for the forecast schedule.)

		Using a third cte, FlagsByWBS, we join CostWBS to ScheduleWBS by WBS ID and compare.
		Resulting rows are the WBS IDs at issue (by subproject).

		A fourth cte, FlagsByTask, rejoins back to DS04 to get the list of tasks within the problem
		WBSs.

		We then use this final cte to return rows from DS06.
	*/

	with CostWBS as (
		SELECT WBS_ID_WP WBS, SUM(BCWPi_hours) BCWP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y'
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, ISNULL(S.subproject_ID,'') SubP, SUM(R.actual_units) Performance
		FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = ISNULL(R.subproject_ID,'')
		WHERE	S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'FC'
			AND S.schedule_type = 'FC'
			AND (R.EOC = 'Labor' Or R.[type] = 'Labor')
		GROUP BY S.WBS_ID, ISNULL(S.subproject_ID,'')
	), FlagsByWBS as (
		SELECT S.WBS, S.SubP
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS AND C.BCWP <>