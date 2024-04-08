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
  <severity>ERROR</severity>
  <title>Duplicate EOCs within CA</title>
  <summary>Is the same EOC represented more than once within a CA by period date?</summary>
  <message>CA found with duplicate EOCs by period date.</message>
  <grouping>WBS_ID_CA,EOC,period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030053</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreEOCsDuplicatedWithinCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		Finds CAs with duplicate EOCs by period_date.
		It uses a sub-select to group by WBS_ID_CA, EOC, and period_date and finds
		any row that is repeated (HAVING COUNT(EOC) > 1).
		Sample set: https://www.db-fiddle.com/f/vqBVjpYNfmQin1GSfbKNj8/1
	*/
	SELECT 
		C.* 
	FROM 
		DS03_Cost C
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		AND WBS_ID_CA IN (
			SELECT WBS_ID_CA 
			FROM DS03_cost 
			WHERE 
				upload_ID = @upload_ID 
			AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
			GROUP BY WBS_ID_CA, EOC, period_date
			HAVING COUNT(EOC) > 1
		)
)