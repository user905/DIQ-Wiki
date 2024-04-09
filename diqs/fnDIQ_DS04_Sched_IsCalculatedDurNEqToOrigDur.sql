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
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>Calculated &amp; Original Durations Misaligned</title>
  <summary>Is the calculated duration substantially different from the original duration?</summary>
  <message>|(EF_days - ES_days) / duration_original_days| &gt; .25.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040604</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCalculatedDurNEqToOrigDur] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether the calculated duration (ES_days - EF_days) is 
		substantially different from the original duration (duration_original_days).

		Threshold is 25% if duration_original_days is not null or zero.
		Otherwise, look for a difference of more than 5 days.
	*/

	SELECT 
		*
	FROM 
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND (
				ISNULL(duration_original_days,0) = 0 AND DATEDIFF(day, ES_date, EF_date) > 5 
			OR ABS(
					(DATEDIFF(day, ES_date, EF_date) - ISNULL(duration_original_days,0)) / 
					NULLIF(duration_original_days,0)
				) > 0.25
		)
)