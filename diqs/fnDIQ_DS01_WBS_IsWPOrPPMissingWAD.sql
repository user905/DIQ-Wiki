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
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP / PP Missing WAD</title>
  <summary>Is this WP / PP missing a WAD?</summary>
  <message>WBS_ID not in DS08.WBS_ID_WP list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010002</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWPOrPPMissingWAD] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for missing WP/PP WADs (applies only if there is a WAD on at least one WP/PP)
	*/
	SELECT	*
    FROM	DS01_WBS
    WHERE	upload_ID = @upload_id
			AND [external] = 'N'
			AND type IN ('PP','WP')
			AND EXISTS (
				SELECT	1
				FROM	DS08_WAD
				WHERE	upload_ID = @upload_id
						AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
			)
			AND WBS_ID NOT IN (
				SELECT	WBS_ID_WP
				FROM	DS08_WAD
				WHERE	upload_ID = @upload_id
			)
)