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
  <title>Resource Labor Performance without Cost Labor Actuals (WP)</title>
  <summary>Are there resource labor performance units recorded without labor actual hours in cost at the WP level?</summary>
  <message>Resource labor performance units &gt; 0 (actual_units where EOC or type = Labor) while cost labor actuals hours = 0 (SUM of DS03.ACWPi_hours where EOC = Labor) by WBS_ID_WP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060302</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 rows can exist with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		These have been excluded from the test using ISNULL(is_indirect,'') <> 'Y'.

		Update: October 2023. Due to actuals now being allowed to be collected at both the CA & WP level,
		this test runs ONLY if actuals are collected at the WP level. Otherwise, the CA level version of this test runs.

		This function looks for resources where resource labor performance units exist 
		(P6 calls this actual_units) but where DS03 cost labor actual hours do not (at the WP level).

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		Step 1. Collect DS03 WPs with their ACWPc labor hours in a cte, CostWBS.

		Step 2. Create cte, ScheduleWBS, with Forecast DS04 tasks joined to DS06 resources by task_ID & subproject_ID, 
		and filtered for WBSs with SUM(actual_units) > 0.

		Step 3. Create cte, FlagsByWBS, by left joining ScheduleWBS to CostWBS by WBS ID, and filtering for
		missed joins or where CostWBS AHours = 0.

		These are your problem WBSs.

		Step 4. Create cte, FlagsByTask, by joining the problem WBSs back to Schedule to get the list
		of tasks that make up each problem WBS.

		We then use this to return rows from DS06.
	*/

	with CostWBS as (
		--Cost WP WBSs with ACWP labor hours
		SELECT WBS_ID_WP WBS, SUM(ISNULL(ACWPi_hours,0)) AHours
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y' AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		--Schedule FC WP WBSs with resource labor units
		SELECT S.WBS_ID WBS, ISNULL(S.subproject_ID,'') SubP
		FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID 
																 AND ISNULL(S.subproject_ID,'') = ISNULL(R.subproject_ID,'')
		WHERE	S.upload_ID = @upload_ID 
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
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE 	R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
		--run test only if actuals are collected at the WP level
		AND NOT EXISTS (
			SELECT 1 
			FROM DS03_cost 
			WHERE upload_ID = @upload_id AND TRIM(ISNULL(WBS_ID_WP,'')) = '' AND (ACWPi_dollars > 0 OR ACWPi_hours > 0 OR ACWPi_FTEs > 0)
		)
	
)