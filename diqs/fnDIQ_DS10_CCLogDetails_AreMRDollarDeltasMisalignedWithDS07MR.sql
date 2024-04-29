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
  <severity>WARNING</severity>
  <title>MR Transaction Dollars Misaligned With Project Level MR</title>
  <summary>Are the dollars delta for MR-related transactions misaligned with the MR dollar value in the IPMR header?</summary>
  <message>Sum of dollars_delta where category = MR &lt;&gt; DS07.MR_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100457</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_AreMRDollarDeltasMisalignedWithDS07MR] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks to see whether the MR transaction dollars sum to the DS07.MR_dollars value.
	*/
	with MRBgt as (
		select ISNULL(MR_bgt_dollars,0) MR
		from DS07_IPMR_header
		where upload_ID = @upload_ID
	), CCLogDetail as (
		select dollars_delta, category
		from DS10_CC_log_detail
		where upload_ID = @upload_ID
	), MRDelta as (
		select SUM(dollars_delta) MR
		from CClogDetail
		where category = 'MR'
	)
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_ID
	AND category = 'MR'
	AND (SELECT MR FROM MRDelta) <> (SELECT MR FROM MRBgt)
	AND (SELECT COUNT(*) FROM CCLogDetail) > 0 -- run only if there are rows in DS10
)