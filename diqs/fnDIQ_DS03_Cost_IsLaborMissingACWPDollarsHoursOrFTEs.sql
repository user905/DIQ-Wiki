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
  <title>Labor Missing Actuals</title>
  <summary>Is this Labor missing Actual Dollars, Hours, or FTEs?</summary>
  <message>EOC = Labor with ACWPi &lt;&gt; 0 for either Dollars, Hours, or FTEs, but where at least one other ACWPi = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030088</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsLaborMissingACWPDollarsHoursOrFTEs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		Per discussion with BK & DG, Indirects should have only $ values, which is why is_indirect = Y has been excluded from this DIQ.

		This function looks for Labor where Actuals has been recorded on one of the three ACWPi fields,
		but not the others. (They should all be recorded together.)

		It does this by filtering for any EOC = Labor row with ACWPi Dollars, Hours, or FTEs <> 0,
		and any row with ACWPi Dollars, Hours, or FTEs = 0.

		The ORs between each of the ACWPi types allows this to work for any combination. 
		E.g. ACWPi_Dollars <> 0 & ACWPi_FTEs = 0.
	*/

	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND 
				EOC = 'Labor' 
			AND ISNULL(is_indirect,'') <> 'Y'
			AND (ACWPi_dollars <> 0 OR ACWPi_FTEs <> 0 OR ACWPi_hours <> 0)
			AND (ACWPi_dollars = 0 OR ACWPi_FTEs = 0 OR ACWPi_hours = 0)
)