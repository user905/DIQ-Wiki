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
  <title>Planned/Estimated Completion Misaligned with End of PMB</title>
  <summary>Are the start/finish dates between the Planned/Estimated Completion and End of PMB milestones misaligned?</summary>
  <message>ES_date &amp; EF_date misaligned between Planned/Estimated Completion and End of PMB milestones (milestone_level = 170 and milestone_level = 175, respectively).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040202</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPlannedCompletionAlignedWithEndOfPMB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for discrepancies btw the start/finish dates of two milestones:
		1. Planned/Estimated Completion without UB (ms_level = 170) and
		2. End of PMB (ms_level = 175)

		It creates 3 ctes:
		1. one for the Planned Completion MSs (ms level 170),
		2. one for the End of PMB MSs (ms level 175),
		3. one joining the two and returning the discrepancies.

		The last we join back to DS04 using two left joins —
		one for the ms level 170 tasks and one for the ms level 175 tasks —
		and return any rows where the ToFlag fields are not null, i.e. a join occured.
	*/
	with PCompl as (
		SELECT task_ID, ES_date, EF_date, schedule_type 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 170
	), EOPMB as (
		SELECT task_ID, ES_date, EF_date, schedule_type 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 175
	), ToFlag as (
		SELECT P.task_ID 'CompTask', P.task_ID 'EOPTask', P.schedule_type
		FROM PCompl P INNER JOIN EOPMB E ON P.schedule_type = E.schedule_type
		WHERE P.ES_date <> E.ES_date OR P.EF_date <> E.EF_date
	)

	SELECT
		S.*
	FROM
		DS04_schedule S LEFT JOIN ToFlag F 	ON  S.task_ID = F.CompTask
										   	AND S.schedule_type = F.schedule_type
						LEFT JOIN ToFlag F2 ON 	S.task_ID = F2.EOPTask
										 	AND S.schedule_type = F2.schedule_type
	WHERE
			upload_id = @upload_ID
		AND F.CompTask IS NOT NULL
		AND F2.EOPTask IS NOT NULL

)