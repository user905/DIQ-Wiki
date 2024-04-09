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
  <title>PM Name Inconsistent</title>
  <summary>Is the PM name inconsistent for SLPPs and high-level WBSs?</summary>
  <message>The CAM name for SLPPs and high-level WBSs is not consistent. (Note: At high levels, the value in the CAM field should represent the PM.)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010028</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsPMNameInconsistent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(




	/*
		This check looks for PM name consistency for high-level WBS items. (CAM field = PM at high levels)
		Specifically, the check looks at all SLPP rows and all WBS rows above the Control Account level,
		and then it compares them to the Level 1 CAM (Again, the PM)

		The first step is to load the ancestry tree into a CTE, filtering for SLPPs/CAs.
	*/
	with ToTest as (
		SELECT *
		FROM AncestryTree_Get(@upload_ID)
		WHERE [type] IN ('SLPP', 'WBS')
	), 
	
	/*
		We then use those results to filter for WBS IDs where:
		1. The Ancestor = Level 1
		2. The CAM <> Ancestor CAM 

		We also filter out any WBS IDs of type WBS with a Control Account ancestor.
		We do this because certain type = WBS items can be nested between CA's & WP's,
		and these are not the ones we want to test.
	*/
	
	Flags as (
		SELECT 
			WBS_ID
		FROM
			DS01_WBS
		WHERE
			upload_ID = @upload_ID
		AND WBS_ID IN (SELECT WBS_ID FROM ToTest WHERE Ancestor_Level = 1 AND CAM <> Ancestor_CAM)
		AND WBS_ID NOT IN (SELECT WBS_ID FROM ToTest WHERE Ancestor_Type = 'CA' AND [type] = 'WBS')
	)

	/*
		Return rows using the above, including the Level 1 WBS if flags exist.
	*/
	SELECT 
		*
	FROM
		DS01_WBS
	WHERE
			upload_ID = @upload_ID
		AND (
				WBS_ID IN (SELECT WBS_ID FROM Flags)
			OR (Level = 1 AND (SELECT COUNT(*) FROM Flags) > 0)
		)
		
)