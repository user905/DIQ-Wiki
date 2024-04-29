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
  <title>RPG Without Approve Repgrogramming Milestone</title>
  <summary>Does RPG exist without an an approve repgrogramming milestone?</summary>
  <message>Task designated as RPG (RPG = Y) is either marked as the approve RPG MS (miletone_level = 138) or no such milestone found.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040130</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesRpgExistWithoutAppRpgMS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for RPG where the task with RPG = Y is the approve reprogramming MS (ms_level 138)
		or RPG = Y and there is no approve reprogramming MS at all.

		Using a union, two selects — one for BL, one for FC — pull the distinct set of results.
	*/

	with RpgMS as (
		SELECT schedule_type
		FROM DS04_schedule 
		WHERE upload_ID=@upload_ID AND milestone_level = 138
	)

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND RPG = 'Y'
		AND schedule_type = 'FC'
		AND (
			milestone_level = 138 OR (SELECT COUNT(*) FROM RpgMS WHERE schedule_type = 'FC') = 0
		)
	UNION
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND RPG = 'Y'
		AND schedule_type = 'BL'
		AND (
			milestone_level = 138 OR (SELECT COUNT(*) FROM RpgMS WHERE schedule_type = 'BL') = 0
		)
)