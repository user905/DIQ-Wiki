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
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP or PP Missing In BL Schedule</title>
  <summary>Is this WP or PP missing in the BL Schedule?</summary>
  <message>WBS_ID_WP missing from DS04.WBS_ID list (where schedule_type = BL).</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030102</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPOrPPMissingInDS04BL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



    -- Insert statements for procedure here

	/*
		The below returns any rows where the WP WBS ID is missing in the BL schedule.
		Assumption: WP WBS IDs are unique across all CA IDs.
	*/
	SELECT C.*
	FROM DS03_Cost C
	LEFT JOIN DS04_schedule S ON C.WBS_ID_WP = S.WBS_ID AND S.upload_ID = @upload_ID AND S.schedule_type = 'BL'
	WHERE C.upload_ID = @upload_ID AND S.WBS_ID IS NULL
		
)