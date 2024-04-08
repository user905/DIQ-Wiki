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
  <title>Resource Remaining Units Misaligned with Cost BCWR Hours</title>
  <summary>Are the resource remaining units flowing up to the schedule WBS misaligned with the BCWR hours in cost (by WBS_ID &amp; EOC)?</summary>
  <message>Sum of resource remaining hours rolled up into DS04.WBS_ID do not align with BCWR hours in DS03 (by WBS_ID &amp; EOC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060298</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreRemUnitsMisalignedWithDS03BCWRHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for discrepancies between the remaining labor units reported on resources and the 
		remaining labor work hours reported in cost.

		Note: remaining work (BCWR) in cost is BAC - BCWPc, i.e. SUM(BCWSi_hours) - SUM(BCWPi_hours).

		Several steps are needed to do this. 
		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect WBS IDs by EOC with each of their BCWRs into a cte, CostWBS.

		Then, we join DS04 to DS06 by task ID to get DS06.remaining_dollars by WBS & EOC,
		which we will use to compare to DS03, and place them in another cte, ScheduleWBS.

		A third cte, FlagsByWBS, joins CostWBS to ScheduleWBS and compares 
		the aggregated DS06.remaining_dollars to the DS03.BCWR.
		The rows returned represent the problem WBS IDs.

		A fourth cte, FlagsByTask, joins back to schedule to get the list of tasks that make 
		up those problem WBS.

		We then use this to return rows from DS06.
	*/

	with CostWBS as (
		--Cost Labor WPs with BCWR hours.
		SELECT WBS_ID_WP WBS, SUM(BCWSi_hours) - SUM(BCWPi_hours) BCWR
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		--Schedule WPs with labor remaining units
		SELECT S.WBS_ID WBS, SUM(R.RemUnits) RemUnits
		FROM 
			DS04_schedule S INNER JOIN 
			(
				SELECT task_ID, SUM(remaining_units) RemUnits 
				FROM DS06_schedule_resources 
				WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND (EOC = 'Labor' OR type = 'Labor')
				GROUP BY task_ID
			) R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID 
			AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID
	), FlagsByWBS as (
		--Problem WBSs
		SELECT S.WBS
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS AND C.BCWR <> S.RemUnits
	), FlagsByTask as (
		--Problem tasks
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WHERE upload_ID = @upload_ID AND sc