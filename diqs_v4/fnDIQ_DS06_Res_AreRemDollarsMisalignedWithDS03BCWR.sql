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
		This function looks for discrepancies between the remaining dollars reported on resources 
		and the remaining work dollars reported in cost.

		Note: remaining work (BCWR) in cost is BAC - BCWPc, 
		i.e. SUM(BCWSi_dollars) - SUM(BCWPi_Dollars). 

		Several steps are needed to do this. 
		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect WBS IDs by EOC with each of their BCWRs into a cte, Cost WBS.

		Then get the remaining dollars from DS06 by task ID & EOC, and collect this into a cte, Resources.

		Then, join Resources to DS04 by task ID to get remaining_dollars by WBS & EOC,
		and collect this into a cte, ScheduleWBS.

		A third cte, FlagsByWBS, joins CostWBS to ScheduleWBS by WBS ID & EOC, 
		and compares the aggregated DS06.remaining_dollars to the DS03.BCWR.
		Any discrepancies represent problematic WBSs.

		A fourth cte, FlagsByTask, joins back to schedule to get the list of tasks that make up
		the problem WBSs.

		We then use this to return rows from DS06.
	*/
	with CostWBS as (
		--Cost WBSs with BCWR by EOC
		SELECT WBS_ID_WP WBS, EOC, SUM(BCWSi_dollars) - SUM(BCWPi_dollars) BCWR
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, EOC
	), Resources as (
		SELECT task_ID, EOC, SUM(remaining_dollars) RemDollars 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
		GROUP BY task_ID, EOC
	), ScheduleWBS as (
		--Schedule WBS with resource remaining dollars by EOC
		SELECT S.WBS_ID WBS, R.EOC, SUM(R.RemDollars) RemDollars
		FROM DS04_schedule S INNER JOIN Resources R ON S.task_ID = R.task_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC
	), FlagsByWBS as (
		--Problem WBSs where cost BCWR <> resource rem dollars, by EOC
		SELECT S.WBS,S.EOC
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.EOC = S.EOC 
												AND C.WBS = S.WBS 
												AND C.BCWR <> S.RemDollars
	),