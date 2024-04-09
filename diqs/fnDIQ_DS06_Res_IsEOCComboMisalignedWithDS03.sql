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
		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect in DS03. 
		This means DS03 & DS06 EOC fields cannot be joined directly, since rows can exist in DS03 with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		The workaround is to use a CASE statemend on DS03.EOC: CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC.
		This returns 'Indirect' for any row where is_indirect = Y, and the EOC for any other row.

		UPDATE 2: Nov 2023. DS06.EOC is now optional for Roles (i.e. where Resource_ID is null). However, EOC is not optional for DS03. 
		If a blank is used in DS06, it will be treated as a flag, since blanks will never exist in DS03.

		This function looks for combos of task resource EOC that don't align with cost. 

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID, and
		that Schedule joins to Resources by task id & subproject id. 

		It is these two joins that allow us to compare the combo of EOCs
		in DS03 cost with DS06 resources.

		First, in DS03, we collect unique WBSs with their unique list of EOCs within a cte, CostEOCs.
		The list of distinct EOCs is pulled from a sub-select with a group by, 
		and then concatenated in alphabetical order with commas using the STRING_AGG function.

		Similarly, we join DS04 to DS06 by task_ID & subproject ID to get schedule WBSs with their list of resource EOCs (by subproject). 
		As before, we use a sub-select with a group by to collect unique EOCs, and then use that result in
		the STRING_AGG to get WBS IDs side-by-side with the distinct list of EOCs (and subproject).
		We insert this into a cte, ScheduleEOCs.

		A third cte, FlagsByWBS, joins Cost & Schedule by WBS IDs & compares the EOC lists.
		Any returned rows are problematic WBSs.

		A fourth cte, FlagsByTask, joins back to schedule to get the list of task IDs that make up these WBSs (by subproject).

		We then use the Flags table to return rows from DS06.

		Example: http://sqlfiddle.com/#!18/fa53ed/10
	*/

	with CostEOCs as (
		--Cost WP WBSs with their distinct list of EOCs (comma-deli