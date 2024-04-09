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
  <title>MR Entry Missing in CC Log Detail</title>
  <summary>Are there no MR entries in the CC Log detail?</summary>
  <message>Count where category = MR is 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1100479</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsMREntryMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		This function looks to see whether at least one MR entry exists in DS10 and flags if not.
	*/
  with CCLogDetail as (
    SELECT *
    FROM DS10_CC_log_detail 
    WHERE upload_ID = @upload_id
  )

	SELECT 
        *
    FROM 
        DummyRow_Get(@upload_id)
    WHERE 
            NOT EXISTS (SELECT 1 FROM CCLogDetail WHERE category = 'MR')
        AND (SELECT COUNT(*) FROM CCLogDetail) > 0 --run only if rows exist in DS10
)