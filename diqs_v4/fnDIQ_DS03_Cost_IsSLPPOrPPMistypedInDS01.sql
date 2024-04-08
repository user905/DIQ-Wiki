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
  <title>SLPP or PP Type Mismatch with DS01 (WBS)</title>
  <summary>Is this SLPP or PP mistyped in DS01 (WBS)?</summary>
  <message>EVT = K but DS01 (WBS) type is not SLPP or PP. (Note: This flag also appears if DS01 type = PP but no WP ID is missing and if type = SLPP but a WP ID was found.)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030096</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsSLPPOrPPMistypedInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This check looks for DS03 data marked with EVT = 'K' (PP or SLPP) where
		the type in DS01 is not of type SLPP or PP.
		
		It does this by creating a cte, ToTest, with DS01 WBS data and type.
		Using this it then looks for the following:
		1. Rows with EVT = K, AND
		2a. Rows where WP ID is blank (ostensibly SLPP rows) AND DS01.type is *not* SLPP, OR 
		2b. Rows where WP ID is *not* blank (ostensibly PP rows) AND DS01.type is *not* PP.
	*/

	with ToTest AS (
		SELECT WBS_ID, type 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE 
			upload_ID = @upload_ID
		AND EVT = 'K'
		AND (
			(ISNULL(WBS_ID_WP,'') = '' AND WBS_ID_CA IN (Select WBS_ID FROM ToTest WHERE type <> 'SLPP')) OR
			(ISNULL(WBS_ID_WP,'') <> '' AND WBS_ID_WP IN (SELECT WBS_ID FROM ToTest WHERE type <> 'PP'))
		)
)