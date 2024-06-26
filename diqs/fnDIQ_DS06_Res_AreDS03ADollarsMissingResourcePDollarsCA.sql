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
  <title>Cost Actuals without Resource Performance (CA)</title>
  <summary>Are there actuals in cost without performance in resources (by CA WBS &amp; EOC)?</summary>
  <message>Resource performance (actual_dollars) = 0 even though DS03.ACWPc &gt; 0 (SUM of ACWSi_dollars) by WBS_ID_CA &amp; EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060306</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreDS03ADollarsMissingResourcePDollarsCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 & DS06 EOC fields cannot be joined directly, since rows can exist in DS03 with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		The workaround is to use a CASE statemend on DS03.EOC: CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC.
		This returns 'Indirect' for any row where is_indirect = Y, and the EOC for any other row.

		This function looks for resources where resource performance (P6 calls this actual_dollars)
		is missing when DS03 CA actuals (ACWP) are not. It runs when Actuals (ACWP) are collected 
		at the CA level.

		Several steps are needed to do this. 
		
		The main thing is to know that WP Cost data joins to Schedule by WP WBS ID,
		that Schedule joins to Resources by task id & subproject id, 
		and that in both cases roll-ups (group bys) must occur. 

		First, we collect DS03.ACWPc dollars (where it exists), grouped by WBS & EOC, 
		into a new cte table, CostWBS.

		Then, we collect DS06.task_ID & EOC where DS06.actual_dollars = 0 (actual_dollars is the P6 version of Performance) 
		into cte, Resources.

		Then, in ScheduleWBS, we join DS04 FC to Resources by task ID & subproject ID to get the DS04.WBSs & DS06.EOCs that do not have any Performance. 

		Using a third cte, FlagsByWBS, join CostWBS to ScheduleWBS by WBS ID & EOC.
		Any resulting rows represent WBS IDs by EOC & subproject ID where the Cost ACWPc exists 
		but Resource Actual Dollars (Performance) does not.

		Finally, a fourth cte gets flags by task_ID, subproject, and EOC by joining back to DS04. 
		
		We then use this to return rows from DS06 (this last step is explained in detail below)
	*/

	with CostWBS as (
		--get Cost ACWP by WBS & EOC
		SELECT WBS_ID_CA CAWBS, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(ACWPi_dollars) ACWP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		GROUP BY WBS_ID_CA, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
		HAVING SUM(ACWPi_dollars) > 0
	), Resources as (
		--get DS06 Resources by task_ID, EOC, and subproject
		SELECT task_ID, EOC, ISNULL(subproject_ID,'') SubP, SUM(ISNULL(actual_dollars,0)) Performance 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
		GROUP BY task_ID, EOC, ISNULL(subproject_ID,'')
	), ScheduleWBS as (
		--get DS04 WP WBS IDs, DS06 Subproject IDs, and DS06 EOCs where the resource Performance = 0 (by EOC)
		SELECT S.WBS_ID WBS, R.EOC, R.SubP
		FROM DS04_schedule S INNER JOIN Resources R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = R.SubP
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC, R.SubP
        HAVING SUM(R.Performance) = 0
	), WBSHierarchy as (
		--get the WBS Hierarchy
		SELECT WBS_ID, Ancestor_WBS_ID
		FROM dbo.AncestryTree_Get(@upload_id)
		WHERE [Type] = 'WP' AND Ancestor_Type = 'CA'
	), ScheduleCAs as (
		--get the schedule data without resource performance by CA WBS ID, subproject, and EOC
		SELECT W.Ancestor_WBS_ID CAWBS, SubP, EOC
		FROM ScheduleWBS S INNER JOIN WBSHierarchy W ON S.WBS = W.WBS_ID
		GROUP BY W.Ancestor_WBS_ID, SubP, EOC
	), FlagsByCAWBS as (
		--join to the Cost CAs 
		--any rows are problem CAs on the schedule side
		SELECT S.CAWBS, SubP
		FROM ScheduleCAs S INNER JOIN CostWBS C ON S.CAWBS = C.CAWBS AND S.EOC = C.EOC
	), FlagsByWPWBS as (
		--Get the WPs that make up the problem CA WBSs by subproject & EOC
		--subproject join isn't needed because WBS IDs are unique across subprojects
		SELECT S.WBS, S.SubP, S.EOC
		FROM WBSHierarchy W INNER JOIN ScheduleWBS S ON W.WBS_ID = S.WBS
		WHERE W.Ancestor_WBS_ID IN (SELECT CAWBS FROM FlagsByCAWBS)
	), FlagsByTaskID as (
		--join back to schedule to get flags by *task ID* which is needed to join back to Resources.
		SELECT S.task_ID, F.EOC, F.SubP
		FROM FlagsByWPWBS F INNER JOIN DS04_schedule S ON F.WBS = S.WBS_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
	)

	/*
		Join the last cte to ds06 by task IDs, subproject IDs, and EOC
	*/
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN FlagsByTaskID F ON R.task_ID = F.task_ID
															AND ISNULL(subproject_ID,'') = F.SubP
															AND R.EOC = F.EOC
	WHERE R.upload_id = @upload_ID AND R.schedule_type = 'FC'
	
)