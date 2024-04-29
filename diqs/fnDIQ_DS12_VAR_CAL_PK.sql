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
  <table>DS12 Variance CAL</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate VAR CAL Entry</title>
  <summary>Is this VAR CAL entry duplicated by CAL ID &amp; transaction ID?</summary>
  <message>Count of CAL_ID &amp; transaction_ID combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1120502</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS12_VAR_CAL_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks PK violations.
		PK is defined as a combo of: CAL_ID & transaction_ID (if it exists).
	*/
	with Dupes as (
		SELECT CAL_ID, ISNULL(transaction_ID,'') transaction_ID
		FROM DS12_variance_CAL
		WHERE upload_ID = @upload_ID
		GROUP BY CAL_ID, ISNULL(transaction_ID,'')
		HAVING COUNT(*) > 1
	)

	SELECT
		C.*
	FROM 
		DS12_variance_CAL C INNER JOIN Dupes D ON C.CAL_ID = D.CAL_ID 
											  AND ISNULL(C.transaction_ID,'') = D.transaction_ID
	WHERE 
		upload_ID = @upload_ID
)