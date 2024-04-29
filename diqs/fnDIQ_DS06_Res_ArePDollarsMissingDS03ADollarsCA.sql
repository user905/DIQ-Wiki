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
  <title>Resource Performance without Cost Actuals (CA)</title>
  <summary>Has this resource recorded performance even though actuals are not recorded in cost (by EOC, at the CA level)?</summary>
  <message>Resource performance (actual_dollars) &gt; 0 even though DS03.ACWPc = 0 (SUM of ACWSi_dollars) by EOC (CA level).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060304</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		UPDATE: Nov 2023. This DIQ, along with fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsWP, replaced fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollars.
		Note that with Scenario D, this will flag for all rows that should tie out to WPs in DS03 with is_indirect = N. This is because Scenario D
		has Indirect Actuals at the CA level and Direct Actuals at the WP level, and testing them together is exceedingly difficult.

		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 & DS06 EOC fields cannot be joined directly, since rows can exist in DS03 with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		The workaround is to use a CASE statemend on DS03.EOC: CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC.
		This returns 'Indirect' for any row where is_indirect = Y, and the EOC for any other row.

		This function looks for resources where resource performance (P6 calls this actual_dollars) exists but Actuals (ACWP) have not been recorded in DS03 at the CA level.

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		Step 1. Collect DS03 Control Account data with ACWPi in cte, CostCAs.

		Step 2. In cte, ScheduleWBS, join DS04 to DS06 by task ID & subproject ID to get resource performance, broken out by EOC and by Schedule WBS ID, 
		and filter for SUM(performance) > 0 (Forecast only)

		Step 3. In cte, WBSHierarchy, collect the WBS Hierarchy.

		Step 4. In cte, ScheduleCAs, join ScheduleWBS to WBSHierarchy to get the schedule data by CA WBS.

		Step 5. In cte, FlagsByCAWBS, join the cost CA data to the Schedule CA data and filter for any missed joins or where the Cost CAs
		are missing ACWPi dollars.

		These are the problem CAs.

		Step 6. In cte, FlagsByWPWBS, take the problem CAs and join back to WBSHierarchy to get the problem WPs

		Step 7. In cte, FlagsByTask, join back to DS04 schedule to get the list of tasks that make up the problem WPs.

		We then use this to return rows from DS06.
	*/

	with Cost as (
		--Cost WBSs with ACWP dollars
		SELECT WBS_ID_CA CA, TRIM(ISNULL(WBS_ID_WP,'')) WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(ACWPi_dollars) ACWPc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID 
		GROUP BY WBS_ID_CA, TRIM(ISNULL(WBS_ID_WP,'')), CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
	), CostCAs as (
		--Cost CAs without ACWP dollars
		SELECT CA, EOC, SUM(ACWPc) ACWPc
		FROM Cost
		GROUP BY CA, EOC
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
	), WBSHierarchy as (
		--WBS Hierarchy
		SELECT WBS_ID, Ancestor_WBS_ID 
		FROM dbo.AncestryTree_Get(@upload_id)
		WHERE [Type] = 'WP' AND Ancestor_Type = 'CA'
	), ScheduleByCAs as (
		--Schedule data by CA WBS ID, WP WBS, EOC, & SubP
		SELECT W.Ancestor_WBS_ID CAWBS, S.WBS, SubP, S.EOC
		FROM ScheduleWBS S INNER JOIN WBSHierarchy W ON S.WBS = W.WBS_ID
	), FlagsByWPWBS as (
		--left join the Cost CAs to the Schedule CAs by CA & EOC
		--any missed join or where ACWPc = 0 is a problem CA
		SELECT S.WBS, SubP, S.EOC
		FROM ScheduleByCAs S LEFT OUTER JOIN CostCAs C ON S.CAWBS = C.CA AND S.EOC = C.EOC
		WHERE C.CA IS NULL OR C.ACWPc = 0
	), FlagsByWPWBS_WithoutScenarioDWPs as (
		--exclude Scenario D WPs that have ACWPc
		SELECT F.*
		FROM FlagsByWPWBS F INNER JOIN Cost C ON F.WBS = C.WP AND F.EOC = C.EOC
		WHERE C.WP <> '' AND C.ACWPc = 0
	), FlagsByTask as (
		--join the problem WP WBSs to schedule to get the tasks that make up those WBSs.
		SELECT S.task_ID, F.SubP, F.EOC
		FROM DS04_schedule S INNER JOIN FlagsByWPWBS_WithoutScenarioDWPs F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
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
		AND EXISTS (SELECT 1 FROM Cost WHERE WP = '' AND ACWPc > 0) --run only if Actuals are collected at the CA level
	
)