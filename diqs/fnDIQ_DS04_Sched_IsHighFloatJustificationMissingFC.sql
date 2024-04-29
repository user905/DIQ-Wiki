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
  <title>High Float Missing Justification (FC)</title>
  <summary>Is this FC task with high float missing a justification in the forecast schedule?</summary>
  <message>justification_high_float is blank where task schedule_type = FC and float_total_days &gt; 10% of project remaining duration.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040184</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsHighFloatJustificationMissingFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for FC tasks with high float but no high float justification.

		High float is defined as >= 10% of the project's remaining duration, which
		is calculated by finding the delta between the EF_date from ms_level = 175 and the CPP SD.
		(Note: Because of the possibility of multiple subprojects, we take the MAX(EF_Date).)

		Note: If the project remaining duration is <= 0, we forgo this test,
		since the project is already past the End of the PMB.
	*/
	with RemDur as (
		SELECT MAX(DATEDIFF(d,CPP_status_date,EF_date)) RemDur
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND milestone_level = 175
	)

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'FC' --FC tasks only
		AND float_total_days / NULLIF((SELECT TOP 1 RemDur FROM RemDur),0) >= .1 --float > 10% of remaining duration
		AND TRIM(ISNULL(justification_float_high,''))='' --no justification
		AND (SELECT TOP 1 RemDur FROM RemDur) > 0 -- remaining duration > 0 days

	
)