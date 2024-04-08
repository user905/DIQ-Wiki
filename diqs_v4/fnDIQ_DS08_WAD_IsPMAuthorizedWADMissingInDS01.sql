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
  <title>WAD Missing In WBS Dictionary</title>
  <summary>Is this PM-authorized WAD missing in the WBS Dictionary (by either WP WBS ID if it exists, or the CA WBS ID)?</summary>
  <message>WBS_ID_CA or WBS_ID_WP missing from DS01.WBS_ID list (where DS08.auth_PM_date is populated).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080610</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthorizedWADMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs that have been signed by the PM, 
		but that are not in the WBS Dictionary. 

		First, get a list of WBS IDs in DS01. (This is cte WBSDict)

		Then, use these to compare to DS08 where an auth_PM_date exists.

		If the DS08.WBS_ID_WP is not null, it is a WP/PP-level WAD, which means we need to compare the WBS_ID_WP to WBSDict.
		
		Whether it is a WP or CA level WAD, we also need to WBS_ID to WBSDict.
	*/
	with WBSDict as (
		SELECT WBS_ID
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID  
		AND auth_PM_date IS NOT NULL
		AND (
				TRIM(ISNULL(WBS_ID_WP,'')) <> '' AND WBS_ID_WP NOT IN (SELECT WBS_ID FROM WBSDict) 
			OR 	WBS_ID NOT IN (SELECT WBS_ID FROM WBSDict)
		)
)