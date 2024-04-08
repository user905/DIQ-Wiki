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
		NOTE: DIQ WAS UPDATED ON 5 MAY 2023. DIQ no longer checks the second condition.
		This function looks for LOE tasks that are either:
		1. lacking at least two discrete predecessors (minimally one FF & one SS), or
		2. have a successor

		It does this first by creating a cte, Logic, with the logic types concatenated 
		into a single, comma-separated cell for each task ID (by schedule type).

		Using the cte, we then join to schedule (by schedule type and task ID),
		filter for LOE tasks, and look at the concatenated logic field
		for any combination of SS or FF.

		This is #1 above.

		We then union those results to a select that joins LOE rows to the 
		DS05 *predecessor task id* field (and schedule type), the results of which would
		represent LOE rows that have successors.

		This is #2 above.

		The union returns only distinct rows.
	*/
	with Tasks as (
		-- get all tasks
		SELECT schedule_type, task_ID, type, EVT
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), LOELogic as (
		-- get logic for all LOE tasks
		SELECT L.*
		FROM DS05_schedule_logic L INNER JOIN Tasks LOE ON L.schedule_type = LOE.schedule_type
													 	AND L.task_ID = LOE.task_ID
		WHERE upload_ID = @upload_ID AND (LOE.[type] = 'LOE' OR LOE.EVT = 'A')		
	), Logic as (
		-- filter for discrete predecessors 
		SELECT L.*
		FROM LOELogic L INNER JOIN Tasks Discrete ON L.schedule_type = Discrete.schedule_type
												 AND L.predecessor_task_ID = Discrete.task_ID
		WHERE upload_ID = @upload_ID AND Discrete.type <> 'LOE' AND Discrete.EVT NOT IN ('A','K','M')
	), LogicAgg as (
		-- aggregate logic types into a single cell
		SELECT schedule_type, task_ID, STRING_AGG(type, ',') WITHIN GROUP (ORDER BY type) Type
		FROM Logic
		GROUP BY schedule_type, task_ID
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN LogicAgg L ON S.schedule_type = L.schedule_type
											 AND S.task_ID = L.task_ID
	WHERE
			upload_id = @upload_ID
		AND (L.[Type] NOT LIKE '%SS%FF%' OR	L.[Type] NOT LIKE '%FF%SS%')
	-- UNION
	-- SELECT
	-- 	S.*
	-- FROM
	-- 	DS04_schedule S INNER JOIN Logic L ON S.schedule_type = L.schedule_type 
	-- 									  AND S.task_ID = predecessor_task_ID
	-- W