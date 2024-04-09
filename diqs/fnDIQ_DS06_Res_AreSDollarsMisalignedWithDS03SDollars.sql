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
  <title>Resource Budgets Misaligned with Cost</title>
  <summary>Are the resource budget dollars misaligned with what is in cost?</summary>
  <message>Resource budget_dollars &lt;&gt; cost DB (SUM of DS03.BCWSi_dollars) by WBS_ID &amp; EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060290</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreSDollarsMisalignedWithDS03SDollars] (
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

		This function looks for resources where resource budget dollars
		do not align with DS03 cost budgets.

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject id, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect budget (DB, or SUM(BCWSi_dollars)) for each WBS by EOC, 
		into a cte, CostWBS.

		Then, we join DS04 to DS06 by task ID & subproject ID to get budgets by Schedule WBS ID,
		and insert into a cte, ScheduleWBS.

		(Note: We do this only for the BL schedule.)

		A third cte, FlagsByWBS, joins these together by WBS & EOC, and compares the cost budget
		to the resource budget. 

		Returned rows are problem WBS (by subproject).

		A fourth cte, FlagsByTask, joins back to schedule to get the tasks that make up these
		problem WBSs.

		We then use this to return rows from DS06
	*/

	with CostWBS as (
		--Cost WPs with DB
		SELECT WBS_ID_WP WBS, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(BCWSi_dollars) DB
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
	), ScheduleWBS as (
		--BL Schedule WPs with resource budgets
		SELECT S.WBS_ID WBS, R.EOC, ISNULL(S.subproject_ID,'') SubP, SUM(R.budget_dollars) Budget
		FROM 	DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID AND ISNULL(S.task_ID,'') = ISNULL(R.task_ID,'') AND ISNULL(S.subproject_ID,'') = ISNULL(R.subproject_ID,'')
		WHERE 	S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.sch