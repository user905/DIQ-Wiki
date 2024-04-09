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
  <severity>ALERT</severity>
  <title>Budget Missing</title>
  <summary>Is this WP or PP missing budget?</summary>
  <message>WP or PP found with BCWSi = 0 (on Dollars, or Hours / FTEs where EOC = Labor).</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030081</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsBCWSMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This test looks for BCWSi = 0.
		In particular, BCWSi_dollars = 0 is always a problem, while BCWSi_Hours/FTEs = 0 is only a problem when EOC = Labor.

		Update: October 2023. The DID v5 schema change introduced a new is_indirect = Y/N field and replaced 'Overhead' with 'Indirect' in EOC.
		Furthermore, it is now possible to have a scenario where WP-level data has only ACWP when is_indirect = Y & EOC = 'Indirect'.
	*/

	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND ( -- BCWS dollars = 0 or non-indirect labor BSWS FTEs or Hours are missing
			BCWSi_dollars = 0 OR 
			(EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y' AND (BCWSi_FTEs = 0 OR BCWSi_hours = 0))
		)
			-- exclude rows where is_indirect = Y & EOC = 'Indirect' & ACWP > 0. These are rows where only Actuals are collected.
		AND NOT (is_indirect = 'Y' AND EOC = 'Indirect' AND ACWPi_dollars > 0) 
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
)