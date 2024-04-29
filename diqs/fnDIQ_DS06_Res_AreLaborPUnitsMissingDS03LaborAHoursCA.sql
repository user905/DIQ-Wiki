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
  <title>Resource Labor Performance without Cost Labor Actuals (CA)</title>
  <summary>Are there resource labor performance units recorded without labor actual hours in cost at the CA level?</summary>
  <message>Resource labor performance units &gt; 0 (actual_units where EOC or type = Labor) while cost labor actuals hours = 0 (SUM of DS03.ACWPi_hours where EOC = Labor) by WBS_ID_CA.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060303</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursCA] (
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
		this test runs ONLY if actuals are collected at the CA level. Otherwise, the WP level version of this test runs.

		This function looks for resources where resource labor performance units exist 
		(P6 calls this actual_units) but where DS03 cost labor actual hours do not (at the CA level).

		Several steps are needed to do this. 

		The main thing is to know that to join Cost WBS_ID_CA to Schedule (DS04), we need to go through DS01, 
		because DS04 contains WP level data, and DS01 contains the WBS hierarchy.
		We also join Schedule to Resources (DS06) by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		Step 1. Collect DS03 CAs with their ACWPc labor hours in a cte, CostWBS.

		Step 2. Create cte, ScheduleWBS, with Forecast DS04 tasks joined to DS06 resources by task_ID & subproject_ID, 
		and filtered for WBSs with SUM(actual_units) > 0.

		Step 3. Create cte, WBSHierarchy, to get all WP and CA ancestor WBS IDs.

		Step 4. Create cte, ScheduleCAs, and join WBSHierarchy to ScheduleWBS to get data at the CA level.

		Step 5. Create cte, FlagsByCAWBS, by left joining ScheduleCAs to CostWBS by CA WBS ID, and filtering for
		missed joins or where CostWBS AHours = 0.

		These are your problem Control Accounts.

		Step 6. Create cte, FlagsByWPWBS, by joining FlagsByCAWBS to WBS Hierarchy to get the WPs that comprise the CA WBS.
		
		These are your problem WPs.

		Step 7. Create cte, FlagsByTask, by joining the problem WP WBSs back to Schedule to get the list
		of tasks that comprise the problem WPs.

		These are the problem tasks that we then join back to DS06 to get our output.
	*/

	with CostWBS as (
		--Cost WP WBSs with ACWP labor hours
		SELECT WBS_ID_CA WBS, SUM(ISNULL(ACWPi_hours,0)) AHours
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y'
		GROUP BY WBS_ID_CA
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
	), WBSHierarchy as (
		--WBS Hierarchy
		SELECT WBS_ID, Ancestor_WBS_ID 
		FROM dbo.AncestryTree_Get(@upload_id)
		WHERE [Type] = 'WP' AND Ancestor_Type = 'CA'
	), ScheduleCAs as (
		--Schedule data by CA WBS ID
		SELECT W.Ancestor_WBS_ID CAWBS, SubP
		FROM ScheduleWBS S INNER JOIN WBSHierarchy W ON S.WBS = W.WBS_ID
		GROUP BY W.Ancestor_WBS_ID, SubP
	), FlagsByCAWBS as (
		--left join the Cost CAs with missing labor actual hours to
		--the Schedule CAs with labor actual hours.
		--we left join in case Labor EOC was missing entirely.
		--resulting rows are the problem CA WBSs
		SELECT S.CAWBS, SubP
		FROM ScheduleCAs S LEFT OUTER JOIN CostWBS C ON S.CAWBS = C.WBS
		WHERE C.AHours = 0 OR C.WBS IS NULL
	), FlagsByWPWBS as (
		--Get the WPs that make up the problem CA WBSs
		SELECT S.WBS, S.SubP
		FROM WBSHierarchy W INNER JOIN ScheduleWBS S ON W.WBS_ID = S.WBS
		WHERE W.Ancestor_WBS_ID IN (SELECT CAWBS FROM FlagsByCAWBS)
	), FlagsByTask as (
		--join the problem WP WBSs to schedule to get the tasks that make up those WBSs.
		SELECT S.task_ID, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWPWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)

	--Join back to Resources by task ID & subproject and filter for labor to get the final results.
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE 	R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
		--run test only if actuals are collected at the CA level
		AND EXISTS (
			SELECT 1 
			FROM DS03_cost 
			WHERE upload_ID = @upload_id AND TRIM(ISNULL(WBS_ID_WP,'')) = '' AND (ACWPi_dollars > 0 OR ACWPi_hours > 0 OR ACWPi_FTEs > 0)
		)
	
)