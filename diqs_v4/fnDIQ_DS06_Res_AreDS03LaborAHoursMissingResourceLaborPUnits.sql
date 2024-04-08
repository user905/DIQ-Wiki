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
  <title>Cost Labor Actuals without Resource Labor Performance</title>
  <summary>Are there labor actual hours in cost without labor performance units in resources?</summary>
  <message>Resource labor performance units = 0 (actual_units where EOC or type = Labor) while cost labor actuals hours &gt; 0 (SUM of DS03.ACWPi_hours where EOC = Labor).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060289</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreDS03LaborAHoursMissingResourceLaborPUnits] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for resources where resource labor performance units do not exist
		(P6 calls this actual_units), but where DS03 cost labor actual hours do.

		Several steps are needed to do this, 
		but the main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id, 
		and that in both cases roll-ups (group bys) must occur. 

		First, collect DS03 WBS IDs with any ACWPc labor hours into a cte, CostWBS.

		Then collect DS06 labor performance by task_ID in Resources
		(in P6 actual_units = performance units)

		Left join DS04 to DS06 by task ID to get resource labor performance by Schedule WBS ID, 
		and filter for any missed joins or where the join did not occur 
		(in case labor actual units was missing)

		Insert into another cte, ScheduleWBS.

		Then create FlagsByWBS with a join between CostWBS & ScheduleWBS to get those WBS IDs 
		where a discrepancy exists.

		Create a final cte, FlagsByTask to join the tripped WBSs back to schedule to get the list of 
		tasks that make up the flagged WBSs.

		Finally, join back to DS06 resources to get the list of resources that are supposed to have 
		labor performance but don't.
	*/

	with CostWBS as (
		--cost WPs with A labor hours
		SELECT WBS_ID_WP WBS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_WP
		HAVING SUM(ACWPi_hours) > 0
	), Resources as (
		--resource labor performance by task_ID
		SELECT task_ID, SUM(ISNULL(actual_units,0)) ResLbrUnits
		FROM DS06_schedule_resources
		WHERE upload_ID = @upload_id AND schedule_type = 'FC' AND (EOC = 'Labor' Or [type] = 'Labor')
		GROUP BY task_ID
	), ScheduleWBS as (
		--schedule WPs missing labor resources
		--left join and filter for LbrUnits = 0 or where the join misses
		SELECT S.WBS_ID WBS
		FROM DS04_schedule S LEFT OUTER JOIN Resources R ON S.task_ID = R.task_ID
		WHERE S.upload_ID = @upload_id AND S.schedule_type = 'FC' AND (ResLbrUnits = 0 OR R.task_ID IS NULL)
		GROUP BY S.WBS_ID
	), FlagsByWBS as (
		--join CostWBS