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
  <severity>ALERT</severity>
  <title>Profit Fee Misaligned With CC Log Detail</title>
  <summary>Is profit fee misaligned with the dollars delta for profit fee transactions in the CC log detail?</summary>
  <message>profit_fee_dollars &lt;&gt; sum of DS10.dollars_delta where category = profit-fee.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070366</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsProfitFeeAlignedWithDS10] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		Checks to see whether profit_fee_dollars != SUM(DS10.dollars_delta) where category = profit-fee
	*/
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND profit_fee_dollars <> (
			SELECT SUM(dollars_delta)
			FROM DS10_CC_log_detail
			WHERE upload_ID = @upload_ID AND category = 'profit-fee'
		)

)