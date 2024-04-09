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
  <severity>WARNING</severity>
  <title>EVT Mismatch</title>
  <summary>Is this task's EVT mismatched with what is in cost?</summary>
  <message>Task EVT does not match what is in DS03 cost (by WBS ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040278</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsEVTMismatchedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for schedule EVTs that do not align with the EVTs in cost for any given WBS ID.
		
		Note that EVTs exist in groups:
		1. Discrete (B, C, D, E, F, G, H, L, N, O, P) 
		2. LOE (A)
		3. PP (K)
		4. Apportioned (J, M)

		In the schedule, tasks within a given WBS ID might have a variety of these, but they will always exist within the
		same grouping. So Discrete tasks are always with discrete; LOE with LOE; etc.

		In cost, a WBS ID always has a single EVT. There is never mixing.

		So, to run this DIQ, we have three steps:
		1. Collect group EVTs for both cost & schedule
		2. Compare the EVTs between the two by WBS ID
		3. Use the results from the comparison to return rows.

		Now, because we don't necessarily trust the contractor to group appropriately, we don't group the cost or schedule
		rows by WBS_ID, we just convert the EVT value to its group and then compare to cost.
		This allows us more granularity in returning tasks rather than whole WBSs (we can see which *task* EVTs don't match across
		cost & schedule, rather than which WBSs.)

		Example: http://sqlfiddle.com/#!18/ab3672/5/0
	*/

	--Step 1. Collect EVTs by their groupings in cost (group by WBS ID) & schedule (at task level) 
	--into temp tables.
	with ScheduleWBS as (
		SELECT 
			schedule_type, 
			WBS_ID,
			task_ID,
			CASE 
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT = 'K' THEN 'PP'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
			END AS EVTCat
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), CostWBS as (
		SELECT
			WBS_ID_WP,
			CASE 
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT = 'K' THEN 'PP'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
			END AS EVTCat
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	),
	--2. Compare the EVT groupings and insert into a cte, ToFlag.
	ToFlag as (
		SELECT
			S.schedule_type,
			S.WBS_ID,
			S.task_ID
		FROM
			ScheduleWBS S INNER JOIN CostWBS C ON S.WBS_ID = C.WBS_ID_WP AND S.EVTCat <> C.EVTCat
		GROUP BY S.schedule_type, S.WBS_ID, S.task_ID
		
	)

	--3. Use the output from above to gather results.