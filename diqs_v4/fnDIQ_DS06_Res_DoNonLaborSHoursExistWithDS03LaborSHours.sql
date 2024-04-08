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
  <title>Resource Non-Labor Hours Recorded Alongside Cost Labor Hours</title>
  <summary>Are there non-labor budget hours in resources recorded in the same WBS as labor budget hours in cost?</summary>
  <message>Resource labor budget hours &gt; 0 (Sum of budget_units where type &lt;&gt; Labor and UOM = h) and cost labor DB hours &gt; 0 (Sum of DS03.BCWSi_dollars where EOC = Labor) by WBS_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060292</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_DoNonLaborSHoursExistWithDS03LaborSHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for resources where resource non-labor budget units recorded in hours (UOM = h)
		are recorded alongside DS03 cost labor budget hours.

		Several steps are needed to do this. 
		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect WBS IDs with any labor budget (DB, or SUM(BCWSi_hours) 
		where EOC = labor) into a cte, CostWBS.

		Then, we join DS04 to DS06 by task ID to get non-labor budgets recorded in hours 
		by Schedule WBS ID (type <> Labor AND UOM = h), and insert into a cte, ScheduleWBS.
		(Note: We do this only for the BL schedule.)

		A third, cte, FlagsByWBS, join CostWBS to ScheduleWBS by WBS ID and compares.
		Any join is a problem WBS.

		A fourth cte, FlagsByTask, then joins back to schedule to get the tasks that make up 
		the problem WBSs.

		We then use this to return rows from DS06.
	*/

	with CostWBS as (
		--Cost WPs with BCWS labor hours.
		SELECT WBS_ID_WP WBS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_WP
		HAVING SUM(BCWSi_hours) > 0
	), ScheduleWBS as (
		--Schedule BL WPs with non-labor budget hours.
		SELECT S.WBS_ID WBS
		FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'BL'
			AND S.schedule_type = 'BL'
			AND R.[type] <> 'labor'
			AND R.UOM = 'h'
		GROUP BY S.WBS_ID
		HAVING SUM(R.budget_units) > 0
	), FlagsByWBS as (
		--Problem WBSs that have both
		SELECT S.WBS
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS
	), FlagsByTask as (
		--The problem tasks that make up the above WBSs.
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)

	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN Fla