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
  <title>Repeat PM Authorization Date Across Revisions</title>
  <summary>Do multiple revisions share the same PM authorization date?</summary>
  <message>auth_PM_date repeated where revisions are not the same (by WBS_ID &amp; WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080428</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthRepeatedAcrossRevisions] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WAD revisions with the same PM auth date.
		To do this we join DS08 to itself by WBS ID & WP WBS ID,
		filter for rows where the revisions differ,
		and then look for rows with the same PM auth date.

		Finally, return the left side of the join to get the flagged rows.
	*/

	SELECT 
		W1.*
	FROM
		DS08_WAD W1 INNER JOIN DS08_WAD W2 	ON W1.WBS_ID = W2.WBS_ID
											AND ISNULL(W1.WBS_ID_WP,'') = ISNULL(W2.WBS_ID_WP,'')
											AND W1.revision <> W2.revision
											AND W1.auth_PM_date = W2.auth_PM_date
	WHERE
			W1.upload_ID = @upload_ID
		AND	W2.upload_ID = @upload_ID
)