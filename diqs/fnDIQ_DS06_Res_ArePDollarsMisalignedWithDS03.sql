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
  <title>Resource Performance Misaligned with Cost</title>
  <summary>Is the performance recorded for this task misaligned with what is in cost (by EOC)?</summary>
  <message>Resource performance (actual_dollars) &lt;&gt; DS03.BCWPc (BCWPi_dollars) by EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060284</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_ArePDollarsMisalignedWithDS03] (
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
		
		This function looks for resources where DS06 actual_dollars (P6's version of BCWP)
		do not align with DS03 BCWP.

		Several steps are needed to do this. 

		The main thing is to know that Cost data joins to Schedule by WBS ID,
		that Schedule joins to Resources by task_id & subproject_ID, 
		and that in both cases roll-ups (group bys) must occur. 

		First, in DS03, we collect BCWPc, grouped by WBS & EOC, into a cte, CostWBS.

		Then collect DS06 FC resources by task ID & EOC, into a cte, Resources, along with 
		their P6 Actual Dollars (Performance).

		Then, join Resources to DS04 by task ID to get resource performance by EOC & WBS,
		inserted into another cte, ScheduleWBS.
		(Note: We do this only for the forecast schedule.)

		A third cte, FlagsByWBS, joins CostWBS to ScheduleWBS by WBS ID & EOC, 
		and compares the Performance.
		
		Resulting rows represent WBS IDs by EOC & subproject IDs that are problematic, 
		i.e. where the Cost BCWPc <> Resource Actual Dollars (Performance).

		A fourth cte, FlagsByTask, then joins back to DS04 to get the tasks that make up each of
		the flagged WBSs by EOC.

		We then use this to return rows from DS06.
	*/

	with CostWBS as (
		SELECT WBS_ID_WP WBS, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(BCWPi_dollars) BCWP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
	), Resources as (
		SELECT task_ID, EOC, SUM(actual_dollars) Performance, ISNULL(subproject_ID,'') SubP
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
		GROUP BY task_ID, EOC, ISNULL(subproject_ID,'')
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, SUM(R.Performance) Performance, R.EOC, R.SubP
		FROM DS04_schedule S INNER JOIN Resources R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = R.SubP
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC, R.SubP
	), FlagsByWBS as (
		SELECT S.WBS, S.EOC, S.SubP
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.EOC = S.EOC
												AND C.WBS = S.WBS
												AND C.BCWP <> S.Performance				
	), FlagsByTask as (
		SELECT S.task_ID, F.EOC, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)

	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F 	ON R.task_ID = F.task_ID 
															AND R.EOC = F.EOC
															AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
)