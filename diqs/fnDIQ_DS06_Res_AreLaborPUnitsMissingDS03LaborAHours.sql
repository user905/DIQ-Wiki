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
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Resource Labor Performance without Cost Labor Actuals</title>
  <summary>Are there resource labor performance units recorded without labor actual hours in cost?</summary>
  <message>Resource labor performance units &gt; 0 (actual_units where EOC or type = Labor) while cost labor actuals hours = 0 (SUM of DS03.ACWPi_hours where EOC = Labor).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060288</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		UPDATE: October 2023. Replaced by DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursWP & DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursCA
		to cover when ACWP is collected at WP or at CA levels.

		This function looks for resources where resource labor performance units exist 
		(P6 calls this actual_units) but where DS03 cost labor actual hours do not.

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect WBS IDs with their ACWPc labor hours in a cte, CostWBS.

		Then, we join DS04 to DS06 by task_ID & subproject_ID to get labor performance by Schedule WBS ID, and
		insert that into another cte, ScheduleWBS, filtered for any WBSs with SUM(DS06.actual_units) > 0.
		(Note: We do this only for the forecast schedule.)

		In a third cte, FlagsByWBS, we left join ScheduleWBS to CostWBS by WBS ID and compare.
		Any result where CostWBS AHours = 0 or the right side of the join is missing is a flag.

		A fourth cte, FlagsByTask, joins the problem WBSs back to Schedule to get the list
		of tasks that make up each problem WBS.

		We then use this to return rows from DS06.
	*/

	with CostWBS as (
		--get Cost WP WBSs with ACWP labor hours
		SELECT WBS_ID_WP WBS, SUM(ISNULL(ACWPi_hours,0)) AHours
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		--get Schedule FC WP WBSs with resource labor units
		SELECT S.WBS_ID WBS, ISNULL(S.subproject_ID,'') SubP
		FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID 
																 AND ISNULL(S.subproject_ID,'') = ISNULL(R.subproject_ID,'')
		WHERE
				S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'FC'
			AND S.schedule_type = 'FC'
			AND (R.EOC = 'Labor' Or R.[type] = 'Labor')
		GROUP BY S.WBS_ID, ISNULL(S.subproject_ID,'')
		HAVING SUM(R.actual_units) > 0
	), FlagsByWBS as (
		--left join the Cost WPs with missing labor actual hours to
		--the Schedule WPs with labor actual hours.
		--we left join in case Labor EOC was missing entirely.
		--resulting rows are the problem WBSs
		SELECT S.WBS, SubP
		FROM ScheduleWBS S LEFT OUTER JOIN CostWBS C ON S.WBS = C.WBS
		WHERE C.AHours = 0 OR C.WBS IS NULL
	), FlagsByTask as (
		--join the problem WBSs to schedule to get the tasks that
		--make up those WBSs.
		SELECT S.task_ID, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)

	--Join back to Resources by task ID and filter for labor to get the final results.
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
	
)