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
  <title>Resource Performance without Cost Actuals</title>
  <summary>Has this resource recorded performance even though actuals are not recorded in cost (by EOC)?</summary>
  <message>Resource performance (actual_dollars) &gt; 0 even though DS03.ACWPc = 0 (SUM of ACWSi_dollars) by EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060286</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollars] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for resources where resource performance (P6 calls this actual_dollars)
		exists but Actuals (ACWP) have not been recorded in DS03.

		Several steps are needed to do this. 
		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect WBS IDs & EOC without ACWPc (dollars) into a cte, CostWBS.

		Then, we join DS04 to DS06 by task ID to get resource performance, broken out into EOC, 
		by Schedule WBS ID, inserted into another cte, ScheduleWBS, and filtered
		for SUM(performance) > 0
		(Note: We do this only for the forecast schedule.)

		A third cte, FlagsByWBS, joins the two to get WBS by EOC where 
		the Cost ACWPc is missing but Resource actual_dollars (Performance) are not.
		These represent WBSs with a problem.

		A fourthe cte, FlagsByTask, then joins back to schedule to get the list of tasks 
		that constitute the problem WBSs.

		We then use this to return rows from DS06.
	*/

	with CostWBS as (
		--Cost WBSs without ACWP dollars
		SELECT WBS_ID_WP WBS, EOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, EOC
		HAVING SUM(ACWPi_dollars) = 0
	), ScheduleWBS as (
		--FC Schedule WBSs with performance resource dollars
		SELECT
			S.WBS_ID WBS,
			SUM(R.Performance) Performance,
			R.EOC
		FROM 
			DS04_schedule S 
			INNER JOIN (
				SELECT task_ID, EOC, SUM(actual_dollars) Performance 
				FROM DS06_schedule_resources 
				WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
				GROUP BY task_ID, EOC
			) R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID 
			AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC
		HAVING SUM(R.Performance) > 0
	), FlagsByWBS as (
		--The problem WBSs
		SELECT
			S.WBS,
			S.EOC
		FROM
			ScheduleWBS S INNER JOIN  CostWBS C ON C.EOC = S.EOC
												AND C.WBS = S.WBS
	), FlagsByTask as (
		--The problem tasks making up the above WBSs
		SELECT S.task_ID, F.EOC
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WH