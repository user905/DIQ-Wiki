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
  <title>Actual Start Misaligned With Cost (WP)</title>
  <summary>Is the actual start for this WP misaligned with last recorded ACWP or BCWP in cost?</summary>
  <message>Min AS_Date &lt;&gt; min period_date where DS03.ACWPi or DS03.BCWPi &gt; 0 (dollars, hours, or FTEs) by DS04.WBS_ID &amp; DS03.WBS_ID_WP.</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040144</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsASMisalignedWithDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WPs where the AS date does not align btw cost & schedule.

		To do this, first collect the min AS in DS03, which is the first period_date where 
		ACWP or BCWP > 0, by WP WBS.
	*/

	with CostAS as (
		SELECT WBS_ID_WP, MIN(period_date) CostAS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			ACWPi_dollars > 0 OR ACWPi_FTEs > 0 OR ACWPi_hours > 0 OR
			BCWPi_dollars > 0 OR BCWPi_FTEs > 0 OR BCWPi_hours > 0
		)
		GROUP BY WBS_ID_WP
	),
	
	/*
		Then get the min AS_Date by WBS_ID in the FC schedule, excluding Start/Finish milestones, 
		WBS Summaries, SVTs, and ZBAs.
	*/
	SchedAS as (
		SELECT WBS_ID, MIN(AS_Date) SchedAS 
		FROM DS04_schedule 
		WHERE 
				upload_ID = @upload_ID 
			AND schedule_type = 'FC' 
			AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA') 
			AND type NOT IN ('WS','SM','FM') 
		GROUP BY WBS_ID
	),

	/*
		Then join by WBS_ID to CostAS to compare, looking for any discrepancies > 31 days.
		WBS IDs returned by this CTE are fails.
	*/

	WBSFails as (
		SELECT S.WBS_ID
		FROM SchedAS S INNER JOIN CostAS C ON S.WBS_ID = C.WBS_ID_WP
		WHERE ABS(DATEDIFF(d,C.CostAS,S.SchedAS))>31 
	)

	/*
		Use the above to filter DS04 to return rows.
	*/

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