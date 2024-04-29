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
  <table>DS18 Sched EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Schedule EU Justification Missing</title>
  <summary>Is the EU justification missing to explain why the min EU days equal the likely, the likely equal the max, or the min equal the max?</summary>
  <message>justification_EU is missing or blank &amp; EU_min_days = EU_likely_days, EU_likely_days = EU_max_days, or EU_max_days = EU_min_days.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1180585</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS18_Sched_EU_IsEUJustificationMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for schedule EU rows where 
		(EU_min_days = EU_likely_days OR 
		EU_likely_days = EU_max_days OR 
		EU_max_days = EU_min_days) and
		justification_EU = null/blank
	*/
	SELECT 
		*
	FROM 
		DS18_schedule_EU
	WHERE 
			upload_ID = @upload_ID
		AND (
			EU_min_days = EU_likely_days OR 
			EU_likely_days = EU_max_days OR 
			EU_max_days = EU_min_days) 
		AND TRIM(ISNULL(justification_EU,'')) = ''


)