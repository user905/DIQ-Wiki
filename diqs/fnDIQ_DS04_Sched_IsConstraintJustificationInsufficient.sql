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
  <title>Insufficient Constraint Justification</title>
  <summary>Is a sufficient justification lacking for the constraint on this task?</summary>
  <message>Task is lacking a sufficient justification for its constraint (justification_constraint_hard or justification_constraint_soft are lacking at least two words).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040161</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsConstraintJustificationInsufficient] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for soft/hard constraint justifications without at least two words.
		Check depends on what's populated in the constraint_type field.
		Solution was found here: https://stackoverflow.com/questions/17171186/sql-query-that-only-contain-one-word
	*/

	SELECT 
		*
	FROM
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND (
				(constraint_type IN (SELECT type FROM HardConstraints) AND CHARINDEX(' ',TRIM([justification_constraint_hard])) = 0) OR 
				(constraint_type IN (SELECT type FROM SoftConstraints) AND CHARINDEX(' ',TRIM([justification_constraint_soft])) = 0)
		)

)