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
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Apportionment IDs Mismatch Between Cost and Schedule</title>
  <summary>Is the WBS ID to which this work is apportioned mismatched in cost and schedule?</summary>
  <message>EVT = J or M where EVT_J_to_WBS_ID does not equal the WBS ID in Schedule.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030078</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsApportionedWBSIDMismatchedWithDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This procedure looks for Apportioned work where the WBS ID of the work being apportioned TO
		does not match between Cost & Schedule.

		To do this, it first uses a CTE that joins the FC Schedule to itself.
		On the left side of the join are tasks that DO apportion work (EVT_J_to_task_ID IS NOT NULL).
		On the right side of the join are the tasks that are being apportioned TO.
		
		The output is the WBS ID of tasks that apportion TO, 
		and the WBS IDs of the tasks to which we apportion.	
	*/

	with ScheduleApportioned AS (
		SELECT S1.WBS_ID WBSID, S2.WBS_ID ApportionedToWBSId
		FROM DS04_schedule S1 INNER JOIN DS04_schedule S2 ON S1.EVT_J_to_task_ID = S2.task_ID
		WHERE 
			S1.upload_ID = @upload_ID 
		AND S2.upload_ID = @upload_ID
		AND S1.schedule_type = 'FC'
		AND S2.schedule_type = 'FC'
		AND S1.EVT_J_to_task_ID IS NOT NULL
	)

	/*
		From the above, we left join to cost data WP WBS ID to the WBS ID from the above.
		We then compare the WBS IDs of the work being apportioned TO in cost to the right side of the above.
		Any mismatch is a flag.
	*/

	SELECT 
		C.* 
	FROM 
		DS03_Cost C LEFT OUTER JOIN ScheduleApportioned S ON C.WBS_ID_WP = S.WBSID
	WHERE
			upload_ID = @upload_ID
		AND	EVT IN ('J','M')
		AND C.EVT_J_to_WBS_ID IS NOT NULL
		AND (
				TRIM(ISNULL(C.EVT_J_to_WBS_ID,'')) <> TRIM(ISNULL(S.ApportionedToWBSId,''))
			OR S.ApportionedToWBSId IS NULL -- If the WBS ID is NULL, then the task is not apportioned to anything.
		)
)