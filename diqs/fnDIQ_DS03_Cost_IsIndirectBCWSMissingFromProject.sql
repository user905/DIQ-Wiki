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
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Indirect Missing From Project</title>
  <summary>Is Indirect missing from this project?</summary>
  <message>No rows found where BCWSi &gt; 0 (Dollars, Hours, or FTEs) and EOC = Indirect or is_indirect = Y.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1030111</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectBCWSMissingFromProject] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This DIQ determines whether Indirect budget is missing from the project.
		To do so, it filters for ANY rows with BCWSi > 0 and (EOC = Indirect or is_indirect = Y).
		If none exist, it returns a dummy row, which is used to indicate a problem at the project level.

		October 2023: Overhead has been replaced with Indirect. This DIQ replaces fnDIQ_DS01_WBS_IsOverheadBCWSMissingFromProject.
	*/	

	with Indirect as (
		SELECT	*
		FROM	DS03_cost
		WHERE	upload_ID = @upload_id
			AND	(BCWSi_Dollars > 0 OR BCWSi_Hours > 0 OR BCWSi_FTEs > 0)
			AND (EOC = 'Indirect' OR is_indirect = 'Y')
	)

	SELECT *
	FROM DummyRow_Get(@upload_id)
	WHERE NOT EXISTS (SELECT * FROM Indirect)
)