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
  <title>Cost Actuals without Resource Performance</title>
  <summary>Are there actuals in cost without performance in resources (by EOC)?</summary>
  <message>Resource performance (actual_dollars) = 0 even though DS03.ACWPc &gt; 0 (SUM of ACWSi_dollars) by EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060285</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreDS03ADollarsMissingResourcePDollars] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for resources where resource performance (P6 calls this actual_dollars)
		is missing when DS03 actuals (ACWP) are not.

		Several steps are needed to do this. 
		
		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id, and that in both cases roll-ups (group bys) must occur. 

		First, we collect DS03.ACWPc dollars (where it exists), grouped by WBS & EOC, 
		into a new cte table, CostWBS.

		Then, we collect DS06.task_ID & EOC where DS06.actual_dollars = 0 (actual_dollars is the P6 version of Performance) 
		into cte, Resources.

		Then, in ScheduleWBS, we join DS04 FC to Resources by task ID to get the DS04.WBSs & DS06.EOCs that do not have any Performance. 

		Using a third cte, FlagsByWBS, join CostWBS to ScheduleWBS by WBS ID & EOC.
		Any resulting rows represent WBS IDs by EOC where the Cost ACWPc exists 
		but Resource Actual Dollars (Performance) does not.

		Finally, a fourth cte gets flags by task_ID & EOC by joining back to DS04. 
		
		We then use this to return rows from DS06 (this last step is explained in detail below)
	*/

	with CostWBS as (
		--get Cost ACWP by WBS & ECO
		SELECT WBS_ID_WP WBS, EOC, SUM(ACWPi_dollars) ACWP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, EOC
		HAVING SUM(ACWPi_dollars) > 0
	), Resources as (
		--get DS06 Resources by task_ID & EOC where performance = 0
		SELECT task_ID, EOC, SUM(ISNULL(actual_dollars,0)) Performance 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
		GROUP BY task_ID, EOC
		HAVING SUM(ISNULL(actual_dollars,0)) = 0
	), ScheduleWBS as (
		--get DS04 WBS IDs & DS06 EOCs where the resource Performance = 0
		SELECT S.WBS_ID WBS, R.EOC
		FROM DS04_schedule S INNER JOIN Resources R ON S.task_ID = R.task_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC
	), FlagsByWBS as (
		--join cost to schedule by WBS & EOC
		--any rows here represent flags *by WBS*
		SELECT S.WBS,S.EOC
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.EOC = S.EOC AND C.WBS = S.WBS
	), FlagsByTa