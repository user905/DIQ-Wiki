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
  <title>Milestone % Complete Not Equal To 0 Or 100%</title>
  <summary>Does this milestone have a % Complete other than 0 or 100%?</summary>
  <message>Milestone (type = SM or FM) with a % complete other than 0 or 100% (pc_duration, pc_units, pc_physical).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040128</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesMSHavePCNEqTo0Or1] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for Start/Finish milestones with a % complete that is not either 0 or 100%.
	*/

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND type IN ('SM','FM')
		AND (
			(PC_duration <> 0 AND PC_duration <> 1) OR 
			(PC_physical <> 0 AND PC_physical <> 1) OR
			(PC_units <> 0 AND PC_units <> 1)
		) 
)