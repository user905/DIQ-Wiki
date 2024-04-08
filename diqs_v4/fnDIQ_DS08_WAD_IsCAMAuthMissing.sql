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
  <title>CAM Authorization Missing</title>
  <summary>Is a CAM authorization date missing for this non-SLPP WAD?</summary>
  <message>auth_CAM_date is null / blank where DS01.type &lt;&gt; SLPP (by WBS_ID or WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080406</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsCAMAuthMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for non-SLPP WADs lacking a CAM authorization date.
		Because WADs can be at the CA or WP level, we need to check for the existence of the values in
		both DS08.WBS_ID & DS08.WBS_ID_WP against DS01 (where type <> SLPP)
	*/

	with NoSLPP as (
		SELECT WBS_ID 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND [type] <> 'SLPP'
	)

	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID
		AND (
			WBS_ID_WP IN (SELECT WBS_ID FROM NoSLPP) OR
			WBS_ID IN (SELECT WBS_ID FROM NoSLPP)
		)
		AND auth_CAM_date IS NULL
)