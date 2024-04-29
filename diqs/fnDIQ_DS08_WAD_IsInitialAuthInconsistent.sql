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
  <title>Inconsistent Initial Authorization Date</title>
  <summary>Is the initial authorization date consistent across revisions?</summary>
  <message>initial_auth_date differs across revisions (by WAD_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080412</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsInitialAuthInconsistent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs where initial auth date changed across revisions.

		To do this, compare DS08 to itself by CA WBS ID (WBS_ID) and WP WBS ID (WBS_ID_WP),
		excluding rows with the same revision.

		Use ISNULL on WP WBS ID in case WADs are the CA level.
	*/

	SELECT 
		W1.*
	FROM
		DS08_WAD W1 INNER JOIN DS08_WAD W2 	ON W1.WBS_ID = W2.WBS_ID
											AND ISNULL(W1.WBS_ID_WP,'') = ISNULL(W2.WBS_ID_WP,'')
											AND W1.revision <> W2.revision
											AND W1.initial_auth_date <> W2.initial_auth_date
	WHERE
			W1.upload_ID = @upload_ID  
		AND	W2.upload_ID = @upload_ID  
)