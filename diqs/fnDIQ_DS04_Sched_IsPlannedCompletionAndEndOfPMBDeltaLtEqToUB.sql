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
  <title>Planned/Estimated Completion &amp; End of PMB Delta Misaligned with UB</title>
  <summary>Is the delta between the Planned/Estimated Completion &amp; End of PMB milestones not equal to UB days?</summary>
  <message>Delta between Planned/Estimated Completion ES_date (milestone_level = 170) &amp; End of PMB EF_date (milestone_level = 175) &lt;&gt; UB bgt days (DS07.UB_bgt_days).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040203</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPlannedCompletionAndEndOfPMBDeltaLtEqToUB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether the DS07 UB bgt days field is <> 
		the delta between the start/finish dates of the following two milestones:
		1. Planned/Estimated Completion without UB (ms_level = 170) and
		2. End of PMB (ms_level = 175)

		To do this, it pulls the ms_level 170 ES_date, ms_level 175 EF_date, and the DS07 UB bgt days fields,
		and compares to see if the diff between the two dates is <= the UB bgt days.

		If the result is <> UB_Bgt_Days, then then flag the tasks defining those two milestones. 
	*/
	with BLSched as (
		SELECT COALESCE(ES_date, EF_date) MSDate, milestone_level
		FROM DS04_schedule
		WHERE upload_id = @upload_ID AND schedule_type = 'BL' AND milestone_level IN (170, 175)
	), Delta as (
		SELECT DATEDIFF(d, MS170.MSDate, MS175.MSDate) Delta
		FROM BLSched MS170 INNER JOIN BLSched MS175 ON MS170.milestone_level <> MS175.milestone_level
		WHERE MS170.milestone_level = 170 AND MS175.milestone_level = 175
	), UBBgtDays as (
		SELECT UB_bgt_days UB 
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	)

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'BL'
		AND milestone_level IN (170, 175)
		AND (SELECT TOP 1 Delta FROM Delta) <> (SELECT TOP 1 UB FROM UBBgtDays)
)