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
  <title>SLPP or PP WAD with Inappropriate EVT</title>
  <summary>Is EVT for this SLPP or WP-level WAD something other than K?</summary>
  <message>EVT &lt;&gt; K for SLPP or PP WAD (by DS01.WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080401</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_DoesSLPPorPPHaveNonKEVT] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for SLPP or PP WADs with an EVT <> K.
		
		Because SLPPs don't have WP WBS IDs and PPs *do* have WPs IDs,
		we need to use two filters, in combination with an or, in the WHERE clause to collect our rows.
		The first filters WBS_ID where DS01.type = SLPP;
		the second filters WBS_ID_WP where DS01.type = PP.
	*/

	with PPs as (
		SELECT WBS_ID, type
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID AND type IN ('SLPP','PP')
	)

	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID   
		AND (
			WBS_ID IN (SELECT WBS_ID FROM PPs WHERE type = 'SLPP') OR
			WBS_ID_WP IN (SELECT WBS_ID FROM PPs WHERE type = 'PP') 
		)
		AND ISNULL(EVT,'') <> 'K'
)