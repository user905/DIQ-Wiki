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
  <title>PM EAC Likely Date After CD-4</title>
  <summary>Is the PM EAC Likely date later than the CD-4 milestone?</summary>
  <message>EAC_PM_Likely_date &gt; minimum DS04.EF_date where milestone_level = 190 (FC only).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070308</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMLikelyGtCD4] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function checks to see if the EAC PM likely > the DS04.EF_date for the 
		contract completion milestone (ms_level = 190).
		Use only FC.
	*/

	with CD4 as (
		SELECT MIN(EF_date) MinEF
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND milestone_level = 190 AND schedule_type = 'FC'
	)

	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND EAC_PM_likely_date > (SELECT TOP 1 MinEF FROM CD4)
)