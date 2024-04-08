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
  <severity>ERROR</severity>
  <title>Non-Unique Cost Row</title>
  <summary>Is this row duplicated by period date, CA WBS ID, WP WBS ID, EOC, &amp; EVT?</summary>
  <message>Count of period_date, WBS_ID_CA, WBS_ID_WP, EOC, EVT combo &gt; 1.</message>
  <grouping>period_date, WBS_ID_CA, WBS_ID_WP, EOC, EVT</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030108</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		Checks to see that the combo of period_date, WBS_ID_CA, WBS_ID_WP, EOC, EVT is unique.
	*/

	with Dupes as (
		SELECT period_date, WBS_ID_CA, ISNULL(WBS_ID_WP,'') WBS_ID_WP, EOC, ISNULL(EVT,'') EVT
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY period_date, WBS_ID_CA, ISNULL(WBS_ID_WP,''), EOC, ISNULL(EVT,'')
		HAVING COUNT(*) > 1
	)

	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Dupes D 	ON C.period_date = D.period_date 
										AND C.WBS_ID_CA = D.WBS_ID_CA 
										AND ISNULL(C.WBS_ID_WP,'') = D.WBS_ID_WP 
										AND C.EOC = D.EOC 
										AND ISNULL(C.EVT,'') = D.EVT
	WHERE
		upload_ID = @upload_ID

		
)