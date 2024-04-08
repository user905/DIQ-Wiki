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
  <severity>WARNING</severity>
  <title>POP Start After Initial Auth Date</title>
  <summary>Is the POP start later than the initial auth date for the latest WAD revision?</summary>
  <message>pop_start_date &gt; initial_auth_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080433</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterInitialAuth] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs where the pop_start >= initial_auth_date.
		It does this only for the last WAD revision.

		To do this, join LatestWPWADRev_Get to DS08 by WBS ID & PM auth date.
		Use ISNULL for the DS08 WBS_ID_WP, in case WADs are at the CA level
		(ISNULL is used on the WBS_ID_WP field for LatestWPWADRev_Get for this reason already)

		Then compare the pop start to initial auth dates.
	*/

	SELECT 
		W.*
	FROM 
		DS08_WAD W INNER JOIN LatestWPWADRev_Get(@upload_ID) R 	ON W.WBS_ID = R.WBS_ID
																AND ISNULL(W.WBS_ID_WP,'') = R.WBS_ID_WP
																AND W.auth_PM_date = R.PMAuth
	WHERE 
			upload_ID = @upload_ID
		AND pop_start_date >= initial_auth_date
)