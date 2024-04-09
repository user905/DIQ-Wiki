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
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>UB Without UB Change Control</title>
  <summary>Are there UB dollars without UB transactions in the change control log?</summary>
  <message>UB_bgt_dollars &lt;&gt; 0 &amp; no rows found in DS10 where category = UB.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070363</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_DoesUBExistWithoutDS10Transactions] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		Checks to see whether there is UB without any UB transactions in the CC log detail (DS10)
	*/
	with CCLogDetail as (
		SELECT category
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (SELECT COUNT(*) FROM CCLogDetail WHERE category = 'UB') = 0
		AND (SELECT COUNT(*) FROM CCLogDetail) > 0 --test only if there are any CC log detail rows
		AND UB_bgt_dollars <> 0
)