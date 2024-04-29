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
  <status>DELETED</status>
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
		UPDATE: Dec 2023. This has been replaced by one WP level check and one CA level check

		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 rows can exist with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		These have been excluded from the test using ISNULL(is_indirect,'') <> 'Y'.

		This function looks for resources where resource labor performance units do not exist
		(P6 calls this actual_units), but where DS03 cost labor actual hours do.

		Several steps are needed to do this.

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task id & subproject ID, 
		and that in both cases roll-ups (group bys) must occur. 

		First, collect DS03 WBS IDs with any ACWPc labor hours into a cte, CostWBS.

		Then collect DS06 labor performance by task_ID & subproject_ID in Resources
		(in P6 actual_units = performance units)

		Left join DS04 to DS06 by task ID & subproject ID to get resource labor performance by Schedule WBS ID, 
		and filter for any missed joins or where the join did not occur 
		(in case labor actual units was missing)

		Insert into another cte, ScheduleWBS.

		Then create FlagsByWBS with a join between CostWBS & ScheduleWBS to get those WBS IDs 
		where a discrepancy exists.

		Create a final cte, FlagsByTask, to join the tripped WBSs back to schedule to get the list of 
		tasks that make up the flagged WBSs.

		Finally, join back to DS06 resources to get the list of resources that are supposed to have 
		labor performance but don't.
	*/

	with CostWBS as (
		--cost WPs with A labor hours
		SELECT WBS_ID_WP WBS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y'
		GROUP BY WBS_ID_WP
		HAVING SUM(ACWPi_hours) > 0
	), Resources as (
		--resource labor performance by task_ID
		SELECT task_ID, ISNULL(subproject_ID,'') SubP, SUM(ISNULL(actual_units,0)) ResLbrUnits
		FROM DS06_schedule_resources
		WHERE upload_ID = @upload_id AND schedule_type = 'FC' AND (EOC = 'Labor' Or [type] = 'Labor')
		GROUP BY task_ID, ISNULL(subproject_ID,'')
	), ScheduleWBS as (
		--schedule WPs with their labor resources
		--left join to include WPs with no resources
		SELECT S.WBS_ID WBS, ISNULL(S.subproject_ID,'') SubP, SUM(ISNULL(ResLbrUnits,0)) LbrUnits
		FROM DS04_schedule S LEFT OUTER JOIN Resources R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = R.SubP
		WHERE S.upload_ID = @upload_id AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, ISNULL(S.subproject_ID,'')
	), FlagsByWBS as (
		--join CostWBS to ScheduleWBS
		--any joins are failures 
		SELECT S.WBS, S.SubP
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS
        WHERE S.LbrUnits = 0
	), FlagsByTaskID as (
		--get tasks that failed using FlagsByWBS
		SELECT S.task_ID, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)

	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTaskID F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
	
)