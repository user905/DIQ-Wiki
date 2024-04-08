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
  <title>BCP Milestones Without Reprogramming</title>
  <summary>Has a BCP occurred without reprogramming tasks? (BL)</summary>
  <message>BCP milestone(s) found (milestone_level = 131 - 135) without accompanying RPG tasks (RPG = Y). (BL)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040229</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesBCPExistWithoutRPGBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for missing RPG in a BL schedule when BCP milestones exist (ms_level 131-135)
	*/
	with BCPCount as (
		SELECT COUNT(*) BCPcnt
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level BETWEEN 131 AND 135 AND schedule_type = 'BL'
	), RPGCount as (
		SELECT COUNT(*) RPGcnt
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND RPG = 'Y' AND schedule_type = 'BL'
	)

	SELECT
		*
	FROM
		DummyRow_Get(@upload_ID)
	WHERE
			(SELECT TOP 1 BCPcnt FROM BCPCount) > 0 
		AND (SELECT TOP 1 RPGcnt FROM RPGCount) = 0
)