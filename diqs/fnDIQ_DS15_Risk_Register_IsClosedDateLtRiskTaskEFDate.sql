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
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Risk Closed Before Risk Tasks Have Completed</title>
  <summary>Is the closed date before all the risk's tasks have finished?</summary>
  <message>closed_date &lt; FC DS04.EF_date (by DS15.risk_ID &amp; DS16.risk_ID, and DS16.task_ID &amp; DS04.task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9150551</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_IsClosedDateLtRiskTaskEFDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for risks where closed_date is before all the risk tasks have finished. 
		
		Risk tasks are in DS16 and tie to DS15 by risk_ID. 
		Risk tasks are also in the schedule (DS04), accessible by task_ID.

		To get the event tasks' EF_date we join to DS04 by task_ID, and then filter for FC.
		Take the minimum EF date to get the earliest only.

		Then join back to DS15 to compare.
	*/
	with RiskEF as (
		SELECT risk_ID, MIN(EF_date) EF
		FROM DS16_risk_register_tasks R INNER JOIN DS04_schedule S ON R.task_ID = S.task_ID
		WHERE R.upload_ID = @upload_ID AND S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY risk_ID
	)

	SELECT 
		RR.*
	FROM 
		DS15_risk_register RR INNER JOIN RiskEF R ON RR.risk_ID = R.risk_ID
	WHERE 
			upload_ID = @upload_ID 
		AND RR.closed_date < R.EF
)