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
  <title>QRA Confidence Level Low for Schedule Following BCP</title>
  <summary>Is the QRA Confidence Level below 90% for schedule following a BCP?</summary>
  <message>QRA_CL_schedule_pct &lt; .9 count where DS09.type = BCP or where DS04.milestone_level between 131 &amp; 135 &gt; 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070368</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsQRACLSchedLowFollowingBCP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function checks if the Quantitative Risk Assessment Confidence Level for Schedule is 
		low when there has been a BCP.
		
		Do this by checking if there are any BCPs in DS09 (type = BCP) 
		or DS04 (milestone level btw 131 and 135), 
		and if so, returning DS07 if QRA_CL_schedule_pct < .9
	*/
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (
				(SELECT COUNT(*) FROM DS09_CC_log WHERE upload_ID = @upload_ID AND type = 'BCP') > 0
			OR (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_id AND milestone_level BETWEEN 131 AND 135) > 0
		)
		AND QRA_CL_schedule_pct < .9
)