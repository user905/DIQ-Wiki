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
  <title>Cost Labor Actuals without Resource Labor Performance (CA)</title>
  <summary>Are there labor actual hours in cost without labor performance units in resources? (CA)</summary>
  <message>Resource labor performance units = 0 (actual_units where EOC or type = Labor) while cost labor actuals hours &gt; 0 (SUM of DS03.ACWPi_hours where EOC = Labor) (Test runs at CA level).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060307</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreDS03LaborAHoursMissingResourceLaborPUnitsCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/* 
		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This means DS03 rows can exist with EOC = Labor & is_indirect = Y, which are defined as indirect rows.
		These have been excluded from the test using ISNULL(is_indirect,'') <> 'Y'.

		This function looks for resources where resource labor performance units do not exist
		(P6 calls this actual_units), but where DS03 cost labor actual hours do (at the CA level).

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
		--cost CAs with A labor hours
		SELECT WBS_ID_CA CAWBS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y' AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		GROUP BY WBS_ID_CA
		HAVING SUM(ACWPi_hours) > 0
	), Resources as (
		--resource labor performance by task_ID
		SELECT task_ID, ISNULL(subproject_ID,'') SubP, SUM(ISNULL(actual_units,0)) ResLbrUnits
		FROM DS06_schedule_resources
		WHERE upload_ID =