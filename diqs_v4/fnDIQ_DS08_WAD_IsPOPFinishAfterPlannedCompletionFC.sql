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
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>POP Finish After Project Planned Completion Milestone (FC)</title>
  <summary>Is the POP finish later than the planned completion milestone in the forecast scheduel?</summary>
  <message>pop_finish &gt; DS04.ES_date/EF_date where milestone_level = 170 &amp; schedule_type = FC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080429</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPFinishAfterPlannedCompletionFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs where the POP finish > Planned / Estimated Completion milestone 
		(ms level = 170) in the FC schedule
	*/

	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID  
		AND POP_finish_date > (
			SELECT COALESCE(ES_Date, EF_Date)
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND milestone_level = 170 AND schedule_type = 'FC'
		)
)