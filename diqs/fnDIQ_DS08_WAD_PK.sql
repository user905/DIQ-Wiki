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
  <severity>ERROR</severity>
  <title>Duplicate WAD</title>
  <summary>Is this WAD a duplicate by WAD ID, WBS ID, WP WBS ID, &amp; revision?</summary>
  <message>Count of WAD_ID, WBS_ID, WBS_ID_WP, &amp; revision combo &gt; 1.</message>
  <grouping>WAD_ID, WBS_ID, WBS_ID_WP, revision</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080441</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for PK violations on WADs.
		PK is defined as: WAD_ID, revision, WBS_ID, & WBS_ID_WP
	*/
	with Dupes as (
		SELECT WAD_ID, WBS_ID, ISNULL(WBS_ID_WP,'') WPWBS, ISNULL(revision,'') revision
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID
		GROUP BY WAD_ID, WBS_ID, ISNULL(WBS_ID_WP,''), ISNULL(revision,'')
		HAVING COUNT(*) > 1
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Dupes D ON W.WBS_ID = D.WBS_ID
									 AND ISNULL(W.WBS_ID_WP,'') = D.WPWBS
									 AND W.revision = D.revision
									 AND W.wad_id = D.wad_id
	WHERE
		upload_ID = @upload_ID
)