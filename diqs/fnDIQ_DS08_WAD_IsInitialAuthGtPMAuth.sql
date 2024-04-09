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
  <title>Initial Authorization After PM Authorization</title>
  <summary>Is the initial authorization date for this WAD after the PM date?</summary>
  <message>initial_auth_date &gt; auth_PM_date (for earliest WAD revision).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080411</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsInitialAuthGtPMAuth] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs where the first revision's initial auth date
		is after the PM's auth date.

		Note: A WAD's first revision is defined as the revision with the earliest PM auth date.
		This is what we collect by CA WBS ID (WBS_ID) & WP WBS ID (WBS_ID_WP) in EarliestWPWADRev_Get,
		which we then join back to DS08 for comparison.

		Use ISNULL on WP WBS_ID in case WADs are at the CA level.
	*/
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN EarliestWPWADRev_Get(@upload_ID) R ON W.WBS_ID = R.WBS_ID
																 AND ISNULL(W.WBS_ID_WP,'') = R.WBS_ID_WP
																 AND W.auth_PM_date = R.PMAuth
																 AND W.initial_auth_date > R.PMAuth
	WHERE
		upload_ID = @upload_ID  
)