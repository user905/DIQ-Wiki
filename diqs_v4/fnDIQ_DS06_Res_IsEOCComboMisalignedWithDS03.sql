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
  <title>EOC Combo Misaligned with Cost</title>
  <summary>Is the combo of resource EOCs for this task/WBS misaligned with what is in cost?</summary>
  <message>Combo of resource EOCs for this DS04.task's WBS ID do not align with combo of DS03 EOCs.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060294</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsEOCComboMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for combos of task resource EOC that don't align with cost. 

		Several steps are needed to do this. 
		The main thing is to know that Cost data joins to Schedule by WBS ID, and
		that Schedule joins to Resources by task id. 
		It is these two joins that allow us to compare the combo of EOCs
		in DS03 cost with DS06 resources.

		First, in DS03, we collect unique WBSs with their unique list of EOCs within a cte, CostEOCs.
		The list of distinct EOCs is pulled from a sub-select with a group by, 
		and then concatenated in alphabetical order with commas using the STRING_AGG function.

		Similarly, we join DS04 to DS06 by task_ID to get schedule WBSs with their list of resource EOCs. 
		As before, we use a sub-select with a group by to collect unique EOCs, and then use that result in
		the STRING_AGG to get WBS IDs side-by-side with the distinct list of EOCs.
		We insert this into a cte, ScheduleEOCs.

		A third cte, FlagsByWBS, joins Cost & Schedule by WBS IDs & compares the EOC lists.
		Any returned rows are problematic WBSs.

		A fourth cte, FlagsByTask, joins back to schedule to get the list of task IDs that make up these WBSs.

		We then use the Flags table to return rows from DS06.

		Example: http://sqlfiddle.com/#!18/fa53ed/10
	*/

	with CostEOCs as (
		--Cost WP WBSs with their distinct list of EOCs (comma-delimited)
		SELECT C.WBS, STRING_AGG (C.EOC, ',') WITHIN GROUP (ORDER BY C.EOC) AS EOC
		FROM (
			SELECT WBS_ID_WP WBS, EOC
			FROM DS03_cost
			WHERE upload_ID = @upload_ID
			GROUP BY WBS_ID_WP, EOC
		) C
		GROUP BY C.WBS
	), ScheduleEOCs as (
		--Schedule WP WBSs with their distinct list of resource EOCs, also comma-delimited
		SELECT S.WBS, STRING_AGG (S.EOC, ',') WITHIN GROUP (ORDER BY S.EOC) AS EOC
		FROM (
			SELECT S.WBS_ID WBS, R.EOC
			FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
			WHERE 
					S.upload_ID = @upload_ID 
				AND R.upload_ID = @upload_ID
				AND R.schedule_type = 'BL'
				AND S.schedule_type = 'BL'
			GROUP BY S.WBS_ID, R.EOC
		) S
		GROUP BY S.WBS
	), FlagsByWBS as (
		--Problem WBSs
		SELECT S.WBS
		FROM ScheduleEOCs S INNER JOIN Cos