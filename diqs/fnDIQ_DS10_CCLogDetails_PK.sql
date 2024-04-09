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
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate CC Log Detail Transaction</title>
  <summary>Is the transaction duplicated by transaction &amp; CC log ID?</summary>
  <message>Count of transaction_ID &amp; CC_log_ID combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100478</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for duplicated transaction IDs / CC Log ID combo.
	*/
	with Dupes as (
		SELECT transaction_id, CC_log_ID
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_ID
		GROUP BY transaction_id, CC_log_ID
		HAVING COUNT(*) > 1
	)

	SELECT 
		C.*
	FROM 
		DS10_CC_log_detail C INNER JOIN Dupes D ON C.transaction_ID = D.transaction_ID
												AND C.CC_log_ID = D.CC_log_ID
	WHERE 
		upload_ID = @upload_ID


	
	
	
	

)