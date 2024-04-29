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
  <title>SLPP or PP with Actuals</title>
  <summary>Does this SLPP or PP have actuals?</summary>
  <message>SLPP or PP found with ACWPi &lt;&gt; 0 (Dollars, Hours, or FTEs).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030071</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesSLPPOrPPHaveACWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This DIQ looks for SLPPs/PPs with Actuals (ACWP).
		To do so, it first collects DS01 WBS_IDs of the above two types in a cte ToTest.
		It then returns rows from DS03 where:
		1. Some ACWP exists AND
		2a. The WBS_ID_WP exists (WP/PP rows) and the WBS_ID_WP exists in ToTest, OR
		2b. The WBS_ID_WP does NOT exist (SLPP/CA rows) and the WBS_ID_CA exists in ToTest, OR
		2c. EVT = K (i.e. PP or SLPP).
	*/

	with ToTest (WBSID) AS (
		SELECT WBS_ID
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID AND type in ('SLPP','PP')
	)


	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND (ACWPi_dollars <> 0 OR ACWPi_FTEs <> 0 OR ACWPi_hours <> 0)
		AND (
			(TRIM(ISNULL(WBS_ID_WP,'')) <> '' AND WBS_ID_WP IN (SELECT WBSID FROM ToTest)) OR
			(TRIM(ISNULL(WBS_ID_WP,'')) = '' AND WBS_ID_CA IN (SELECT WBSID FROM ToTest)) OR
			EVT = 'K'
		)
		
)