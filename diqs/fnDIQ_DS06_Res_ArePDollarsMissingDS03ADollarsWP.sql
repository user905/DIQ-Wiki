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
  <title>Resource Performance without Cost Actuals (WP)</title>
  <summary>Has this resource recorded performance even though actuals are not recorded in cost (by EOC, at the WP level)?</summary>
  <message>Resource performance (actual_dollars) &gt; 0 even though DS03.ACWPc = 0 (SUM of ACWSi_dollars) by EOC (WP level).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060305</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		UPDATE: Nov 2023. This DIQ, along with fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsCA, replaced fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollars.

		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 & DS06 EOC fields cannot be joined directly, since rows can exist in DS03 with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		The workaround is to use a CASE statemend on DS03.EOC: CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC.
		This returns 'Indirect' for any row where is_indirect = Y, and the EOC for any other row.

		This function looks for resources where resource performance (P6 calls this actual_dollars) exists but Actuals (ACWP) have not been recorded in DS03 at the WP level.

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		Step 1. Collect Cost data in cte, Cost. 
		
		Step 2. In cte, CostWPs, collect WPs with their ACWP

		Step 3. Create cte, ScheduleWBS, with Forecast DS04 tasks joined to DS06 resources by task_ID & subproject_ID, 
		and filtered for WBSs with SUM(actual_dollars) > 0.

		Step 4. Create cte, FlagsByWBS, by left joining ScheduleWBS to CostWBS by WBS ID, and filtering for
		missed joins or where CostWBS ADollars = 0.

		These are your problem WBSs.

		Step 5. Create cte, FlagsByTask, by joining the problem WBSs back to Schedule to get the list
		of tasks that make up each problem WBS.

		We then use this to return rows from DS06, excluding results if Actuals are collected at the CA level.
	*/

	with Cost as (
		--Cost data with ACWP dollars (we collect Cost data at all levels because we re-use it in various places at different levels)
		SELECT WBS_ID_CA CA, TRIM(ISNULL(WBS_ID_WP,'')) WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(ACWPi_dollars) ACWPc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
	), CostWPs as (
		--Cost WP WBSs with ACWP dollars
		SELECT WP, EOC, SUM(ACWPc) ACWPc
		FROM Cost
		WHERE WP <> ''
		GROUP BY WP, EOC
	), ScheduleWBS as (
		--FC Schedule WP WBSs (by subproject) with performance resource dollars
		SELECT S.WBS_ID WBS, R.SubP, SUM(R.Performance) Performance, R.EOC
		FROM DS04_schedule S 
				INNER JOIN (
					SELECT task_ID, ISNULL(subproject_ID,'') SubP, EOC, SUM(actual_dollars) Performance 
					FROM DS06_schedule_resources 
					WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
					GROUP BY task_ID, EOC, ISNULL(subproject_ID,'')
				) R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = R.SubP
		WHERE
				S.upload_ID = @upload_ID 
			AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC, R.SubP
		HAVING SUM(R.Performance) > 0
	), FlagsByWBS as (
		--left join the Cost WPs to the Schedule WPs and filter for any missed joins or where Cost ACWP = 0
		--resulting rows are the problem WPs
		SELECT S.WBS, SubP, S.EOC
		FROM ScheduleWBS S LEFT OUTER JOIN CostWPs C ON S.WBS = C.WP AND S.EOC = C.EOC
		WHERE C.ACWPc = 0 OR C.WP IS NULL
	), FlagsByTask as (
		--join the problem WP WBSs to schedule to get the tasks that make up those WBSs.
		SELECT S.task_ID, F.SubP, F.EOC
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)

	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F 	ON R.task_ID = F.task_ID 
															AND ISNULL(R.subproject_ID,'') = F.SubP
															AND R.EOC = F.EOC
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND actual_dollars > 0
		AND NOT EXISTS (SELECT 1 FROM Cost WHERE WP = '' GROUP BY CA HAVING SUM(ACWPc) > 0) --run only if Actuals are not collected at the CA level
	
)