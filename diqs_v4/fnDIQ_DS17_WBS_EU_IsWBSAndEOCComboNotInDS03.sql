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
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WBS &amp; EOC Combo Missing in Cost</title>
  <summary>Is this WBS_ID / EOC combo missing in the cost processor?</summary>
  <message>Combo of WBS_ID_WP &amp; EOC missin in DS03.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9170579</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsWBSAndEOCComboNotInDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for WBS & EOC combinations that are in the WBS EU table 
		but not in the cost table.
	*/

	with CostWBS as (
		SELECT CONCAT(WBS_ID_WP,'-', EOC) WBSEOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY CONCAT(WBS_ID_WP,'-', EOC) 
	)

	SELECT 
		*
	FROM 
		DS17_WBS_EU
	WHERE 
			upload_ID = @upload_ID
		AND CONCAT(WBS_ID,'-', EOC) NOT IN (SELECT WBSEOC FROM CostWBS)


)