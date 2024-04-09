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
  <title>Resource Remaining Dollars Misaligned with Cost BCWR</title>
  <summary>Are the resource remaining dollars flowing up to the schedule WBS misaligned with the BCWR in cost (by WBS_ID &amp; EOC)?</summary>
  <message>Sum of resource remaining dollars rolled up into DS04.WBS_ID do not align with BCWR in DS03 (by WBS_ID &amp; EOC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060297</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreRemDollarsMisalignedWithDS03BCWR] (
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

		This function looks for discrepancies between the remaining dollars reported on resources 
		and the remaining work dollars reported in cost.

		Note: remaining work (BCWR) in cost is BAC - BCWPc, i.e. SUM(BCWSi_dollars) - SUM(BCWPi_Dollars). 

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect WBS IDs by EOC with each of their BCWRs into a cte, Cost WBS.

		Then get the remaining dollars from DS06 by task ID, subproject ID, & EOC, and collect this into a cte, Resources.

		Then, join Resources to DS04 by task ID & subproject ID to get remaining_dollars by WBS & EOC,
		and collect this into a cte, ScheduleWBS.

		A fourth cte, FlagsByWBS, joins CostWBS to ScheduleWBS by WBS ID & EOC, 
		and compares the aggregated DS06.remaining_dollars to the DS03.BCWR.

		Any discrepancies represent problematic WBSs (by subproject).

		A fifth cte, FlagsByTask, joins back to schedule to get the list of tasks that make up
		the problem WBSs.

		We then use this to return rows from DS06.
	*/
	with CostWBS as (
		--Cost WBSs with BCWR by EOC
		SELECT WBS_ID_WP WBS, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(BCWSi_dollars) - SUM(BCWPi_dollars) BCWR
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
	), Resources as (
		SELECT task_ID, EOC, IS