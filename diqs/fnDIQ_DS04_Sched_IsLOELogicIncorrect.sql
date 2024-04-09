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
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>LOE Task With Improper Logic</title>
  <summary>Is this LOE task missing at least one FF and SS predecessor (both discrete)?</summary>
  <message>DS04.type = LOE or DS04.EVT = A without DS05.type = FF and SS relationships.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040187</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsLOELogicIncorrect] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		NOTE: DIQ update, NOV 2023. DIQ now flags the following LOE & apportioned tasks (EVT = A, J, M or type = LOE):
		1. Those without two predecessors (one SS, one FF)
		2. Those with successors
		3. Those without immediate, discrete predecessors

		Step 1. Fill cte Tasks with DS04 tasks by schedule type, task_id, type, EVT, and subproject id.
		Step 2. Fill cte Logic with all DS05 data
		Step 3. Fill cte LOELogic with logic for LOE & apportioned tasks
		Step 4. Fill cte LOEsWithDisPreds with the logic for LOE & apportioned tasks with discrete predecessors
		Step 5. Return DS04 data using the above, stacking the results using UNIONs.
	*/
	with Tasks as (
		-- all tasks
		SELECT schedule_type, task_ID, type, ISNULL(EVT,'') EVT, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), Logic as (
		-- all logic
		SELECT schedule_type, task_ID, predecessor_task_ID, type, ISNULL(subproject_ID,'') SubP, ISNULL(predecessor_subproject_ID,'') PSubP FROM DS05_schedule_logic WHERE upload_ID = @upload_id
	), LOELogic as (
		-- logic for LOE & apportioned tasks
		SELECT L.*
		FROM Logic L INNER JOIN Tasks LOE ON L.schedule_type = LOE.schedule_type
										AND L.task_ID = LOE.task_ID
										AND L.SubP = LOE.SubP
		WHERE LOE.[type] = 'LOE' OR LOE.EVT IN ('A', 'J', 'M')
	), LOEsWithDisPreds as (
		-- collect LOE & apportioned tasks (LOELogic CTE) with their discrete predecessors (Tasks CTE filtered for discrete) (discrete: EVT <> A, J, M and type = TD or RD)
		--(STRING_AGG allows for the use of NOT LIKE to find missing combinations of SS/FF or FF/SS)
		SELECT L.schedule_type, L.task_ID, L.SubP, STRING_AGG(L.type, ',') WITHIN GROUP (ORDER BY L.type) Type
		FROM LOELogic L INNER JOIN Tasks Discrete ON L.schedule_type = Discrete.schedule_type
												 AND L.predecessor_task_ID = Discrete.task_ID --join to predecessor task id
												 AND L.PSubP = Discrete.SubP -- join to predecessor subproject id
		WHERE Discrete.Type IN ('TD', 'RD') AND Discrete.EVT NOT IN ('A','J','M')
		GROUP BY L.schedule_type, L.task_ID, L.SubP
	)

	--LOE and apportioned tasks without at least two predecessors (one SS, one FF) or without immediate discrete predecessor (#1 &