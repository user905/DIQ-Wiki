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
  <title>12 Months Since OTB-OTS Without BCP</title>
  <summary>Has it been twelve months since an OTB-OTS date without a BCP?</summary>
  <message>Minimum 12 month delta between CPP status date &amp; OTB_OTS_date without DS09.type = BCP or DS04.milestone_level between 131 &amp; 135.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070365</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsOTBOTSDateOverdue] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		Checks to see whether twelve months have passed since the OTB_OTS_date without a BCP.
		
		To do this, check if there are no BCP log entries in DS09 (CC_log_ID where type = BCP)
		and no DS04 entries with milestone_level btw 131 & 135.
		
		If not, return DS07 if it's been 12 months since the OTB/OTS 
		[DATEDIFF(m,cpp_status_date,OTB_OTS_date) < -12; this will be null if no OTB OTS date exists]
	*/
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (
				(SELECT COUNT(*) FROM DS09_CC_log WHERE upload_ID = @upload_ID AND type = 'BCP') = 0
			OR (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_id AND milestone_level BETWEEN 131 AND 135) = 0
		)
		AND DATEDIFF(m,CPP_status_date,OTB_OTS_date) < -12

)