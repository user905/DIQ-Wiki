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
  <status>DELETED</status>
  <severity>ALERT</severity>
  <title>CD or BCP Early Start or Finish Dates Misaligned Between FC &amp; BL</title>
  <summary>Are the early start or finish dates for this CD/BCP misaligned between FC &amp; BL?</summary>
  <message>ES_date or EF_date do not align for this CD/BCP (milestone_level = 1xx) in the BL &amp; FC schedules (schedule_type = FC &amp; BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040108</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreCDEarlyDatesMisalignedBtwFCAndBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CD/BCP milestones where the early start or finish dates are misaligned
		between FC & BL.

		Using a cte, we join 1xx-level milestones (milestone_level like '1xx') from FC to BL
		by task ID & WBS ID. We then look for misalignment between their early dates.

		The cte uses two sub-selects to pre-filter for the milestones in FC & BL.
		The join of these and comparison of early dates filters for failures.

		Failed rows are then joined to DS04 to get the output (both BL & FC failures are returned)
	*/

	with Fails as (
		SELECT 
			F.WBS_ID, F.task_id
		FROM 
			(SELECT WBS_ID, task_ID, ES_date, EF_date FROM DS04_schedule where upload_ID = @upload_ID AND schedule_type='FC' AND milestone_level BETWEEN 100 AND 199) F,
			(SELECT WBS_ID, task_ID, ES_date, EF_date FROM DS04_schedule where upload_ID = @upload_ID AND schedule_type='BL' AND milestone_level BETWEEN 100 AND 199) B
		WHERE
				F.WBS_ID = B.WBS_ID
			AND F.task_ID = B.task_ID
			AND (F.ES_date <> B.ES_date OR F.EF_date <> B.EF_date)
	)

	SELECT
		S.*
	FROM
		DS04_schedule S,
		Fails F
	WHERE
			S.upload_ID = @upload_ID
		AND S.task_ID = F.task_ID
		AND S.WBS_ID = F.WBS_ID
)