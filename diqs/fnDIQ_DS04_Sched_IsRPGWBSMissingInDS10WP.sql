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
  <title>Reprogramming Missing in CC Log Detail (WP)</title>
  <summary>Is this Work or Planning Planning with reprogramming missing in the CC Log detail?</summary>
  <message>WBS_ID where RPG = Y not found in DS10.WBS_ID list.</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040280</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsRPGWBSMissingInDS10WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WP WBSs with RPG that are not logged in DS10. 
		It returns rows only if the DS10 WBS IDs are at the WP/PP level.

		Use a left join to accomplish this, where any missed join is a problem WBS.
		Filter for RPG = Y.
	*/
	SELECT
		S.*
	FROM
		DS04_schedule S LEFT JOIN DS10_CC_log_detail C ON S.WBS_ID = C.WBS_ID
	WHERE
			S.upload_ID = @upload_ID
		AND C.upload_ID = @upload_ID
		AND S.RPG = 'Y'
		AND C.WBS_ID IS NULL

)