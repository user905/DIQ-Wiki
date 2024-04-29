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
  <title>Resource Labor Units Misaligned with Cost</title>
  <summary>Are the labor budget units in resources misaligned with the labor budget hours in cost?</summary>
  <message>Resource labor budget units (budget_units where EOC or type = Labor) &lt;&gt; cost labor DB (SUM of DS03.BCWSi_dollars where EOC = Labor) by WBS_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060291</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborSUnitsMisalignedWithDS03LaborSHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 rows can exist with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		These have been excluded from the test using ISNULL(is_indirect,'') <> 'Y'.

		This function looks for resources where resource labor budget units
		do not align with DS03 cost labor budget units.

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect the labor budget (DB, or SUM(BCWSi_hours) where EOC = labor) 
		for each WBS into a cte, CostWBS.

		Then, we join DS04 to DS06 by task ID & subproject ID to get resource budgets by WBS ID,
		filter by EOC = labor or type = Labor, and then insert into another cte, ScheduleWBS.
		(Note: We do this only for the BL schedule.)

		A third cte, FlagsByWBS, joins CostWBS to ScheduleWBS by WBS ID to compare.
		Any results from this cte represent problem WBS.

		A fourth cte, FlagsByTask, joins back to schedule to get the tasks that make up the
		problem WBSs.

		We then use this to return rows from DS06.
	*/

	with CostWBS as (
		--Cost WPs with Labor DB.
		SELECT WBS_ID_WP WBS, SUM(BCWSi_hours) DB
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y'
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		--Schedule BL WPs with labor resource units.
		SELECT S.WBS_ID WBS, ISNULL(S.subproject_ID,'') SubP, SUM(R.budget_units) Budget
		FROM  DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = ISNULL(R.subproject_ID,'')
		WHERE
				S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'BL'
			AND S.schedule_type = 'BL'
			AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
		GROUP BY S.WBS_ID, ISNULL(S.subproject_ID,'')
	), FlagsByWBS as (
		--The problem WPs where Cost DB <> Schedule DB.
		SELECT S.WBS, S.SubP
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS AND C.DB <> S.Budget
	), FlagsByTask as (
		--The problem tasks
		SELECT S.task_ID, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)

	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'BL'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
	
)