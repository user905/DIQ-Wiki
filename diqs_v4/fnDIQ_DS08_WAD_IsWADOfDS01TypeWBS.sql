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
  <title>WBS Type WAD</title>
  <summary>Is this WAD a WBS type WBS element in the WBS dictionary?</summary>
  <message>WBS_ID or WBS_ID_WP in DS01.WBS_ID list where DS01.type = WBS.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080620</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsWADOfDS01TypeWBS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs where WBS_ID or WBS_ID_WP IN DS01.WBS_ID & type = WBS
	*/

	with WBSTypes as (
		SELECT WBS_ID 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND type = 'WBS'
	)

	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID
		AND (
				WBS_ID_WP IN (SELECT WBS_ID FROM WBSTypes) OR
				WBS_ID IN (SELECT WBS_ID FROM WBSTypes)
		)
)