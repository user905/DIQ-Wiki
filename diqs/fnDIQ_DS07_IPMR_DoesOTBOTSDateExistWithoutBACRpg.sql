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
  <title>OTB / OTS Without BAC Reprogramming</title>
  <summary>Is there an OTB/OTS date without BAC reprogramming?</summary>
  <message>OTB_OTS_date is not null/blank &amp; SUM(DS03.BAC_rpg) = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070338</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_DoesOTBOTSDateExistWithoutBACRpg] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		Checks to see whereh OTB_OTS_date exists without BAC RPG in DS03
	*/
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (SELECT SUM(ISNULL(BAC_rpg,0)) FROM DS03_cost WHERE upload_ID = @upload_ID) = 0
		AND OTB_OTS_date IS NOT NULL
)