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
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Lag Missing Justification</title>
  <summary>Is the lag for this task missing a justification?</summary>
  <message>Lag_days &lt;&gt; 0 and lacking a justification in DS04 schedule (justification_lag is null or blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9050280</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsLagMissingJustification] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for logic with lag that is lacking a lag justification in DS04.
		It does this by a simple join by schedule type and task ID, and then filtering
		for any lag and any missing justification_lag.
	*/

	SELECT
		L.*
	FROM
		DS05_schedule_logic L INNER JOIN DS04_schedule S ON L.schedule_type = S.schedule_type 
														AND L.task_ID = S.task_ID
														AND ISNULL(L.subproject_ID,'') = ISNULL(S.subproject_ID,'')
	WHERE
			L.upload_id = @upload_ID
		AND S.upload_ID = @upload_ID
		AND lag_days <> 0
		AND TRIM(ISNULL(justification_lag,''))=''
)