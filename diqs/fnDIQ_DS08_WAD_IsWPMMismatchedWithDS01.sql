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
  <title>WPM Mismatched With WBS Dictionary</title>
  <summary>Is the WPM name for this WAD mismatched with what is in the WBS Dictionary?</summary>
  <message>WPM &lt;&gt; DS01.WPM (by DS08.WBS_ID_WP &amp; DS01.WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080621</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsWPMMismatchedWithDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs where WPM <> DS01.WPM for the MAX(pm_auth_date)
	*/
	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN LatestWPWADRev_Get(@upload_ID) R ON W.WBS_ID_WP = R.WBS_ID_WP AND W.auth_PM_date = R.PMauth
					INNER JOIN DS01_WBS WBS ON W.WBS_ID_WP = WBS.WBS_ID
	WHERE
			W.upload_ID = @upload_ID
		AND WBS.upload_ID = @upload_ID
		AND R.WBS_ID_WP <> ''
		AND W.WPM <> WBS.WPM
)