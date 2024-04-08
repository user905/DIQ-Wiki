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
  <title>Post-CD3 Project Milestone Not Coded As Finish Milestone</title>
  <summary>Is this major post-CD3 milestone not coded as a finish milestone?</summary>
  <message>Post-CD3 milestone (milestone_level = 160 - 800) is not coded as a finish milestone (type = FM).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040204</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPostCD3MSNotCodedAsFM] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether post-CD3 milestones are coded as finish milestones.
	*/

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND	milestone_level BETWEEN 160 AND 800
		AND type <> 'FM'
)