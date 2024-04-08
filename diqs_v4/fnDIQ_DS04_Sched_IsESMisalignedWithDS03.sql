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
  <severity>WARNING</severity>
  <title>Start Date Misaligned With Cost</title>
  <summary>Is the early start date for this WBS misaligned with what is in cost (DS03)?</summary>
  <message>ES_date for this WBS_ID does not align with the first period where BCWSi &gt; 0 (dollars/hours/FTEs).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040175</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsESMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for WBS_IDs where the ES date does not align btw cost & schedule.

		It first collects the ES in cost by finding the first recorded period_date where BCWS > 0.

		It then collects schedule FC data by WBS ID (non-MS, non-SVT/ZBA, non-WBS summary).
		
		Then it joins the two tables by WBSID and compares the dates, allowing for a 31 day cushion.

		Finally, it returns the schedule data for the WBS_IDs that failed the check.
	*/

	with CostStart as (
		SELECT WBS_ID_WP, MIN(period_date) CostES
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
		GROUP BY WBS_ID_WP
	), SchedStart as (
		SELECT WBS_ID, MIN(ES_Date) SchedES 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA') and type NOT IN ('WS','SM','FM') 
		GROUP BY WBS_ID
	), WBSFails as (
		SELECT S.WBS_ID
		FROM SchedStart S INNER JOIN CostStart C ON C.WBS_ID_WP = S.WBS_ID
		WHERE ABS(DATEDIFF(d,C.CostES,S.SchedES))>31 
	)


	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'FC'
		AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA') 
		AND type NOT IN ('WS','SM','FM')
		AND WBS_ID IN (SELECT WBS_ID FROM WBSFails)
	

)