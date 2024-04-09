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
  <title>Actual Finish Misaligned With Cost (CA)</title>
  <summary>Is the actual finish for this WBS misaligned with what is in cost? (Note: Comparison is at the CA WBS level, where ACWP has been collected)</summary>
  <message>Max AF_Date &lt;&gt; max period_date where DS03.ACWPi or DS03.BCWPi &gt; 0 (dollars, hours, or FTEs) by DS04.WBS_ID, DS01.WBS_ID, DS01.parent_WBS_ID, &amp; DS03.WBS_ID_CA.</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040149</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsAFMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CAs where the AF date does not align btw cost & schedule.

		To do this, first collect the max AF in DS03, which is the last period_date where 
		ACWP or BCWP > 0, by CA WBS.
	*/

	with CostAF as (
		SELECT WBS_ID_CA, MAX(period_date) CostAF
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			ACWPi_dollars > 0 OR ACWPi_FTEs > 0 OR ACWPi_hours > 0 OR
			BCWPi_dollars > 0 OR BCWPi_FTEs > 0 OR BCWPi_hours > 0
		)
		GROUP BY WBS_ID_CA
	),
	
	/*
		Then get the max AF_Date by WBS_ID in the FC schedule, excluding Start/Finish milestones, 
		WBS Summaries, SVTs, and ZBAs.
	*/
	SchedWPAF as (
		SELECT WBS_ID, MAX(AF_Date) SchedAF 
		FROM DS04_schedule 
		WHERE 
				upload_ID = @upload_ID 
			AND schedule_type = 'FC' 
			AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA') 
			AND type NOT IN ('WS','SM','FM') 
		GROUP BY WBS_ID
	),

	/*
		Then join to AncestryTree_Get to get the rollup to the CA WBS level.
	*/

	SchedCAAF as (
		SELECT A.Ancestor_WBS_ID CAWBS, MAX(S.SchedAF) SchedAF
		FROM SchedWPAF S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.WBS_ID
		WHERE A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		GROUP BY A.Ancestor_WBS_ID
	),

	/*
		Then join to CostAF to compare, looking for any discrepancies > 31 days.
		CA WBS IDs returned by this CTE are fails.
	*/

	CAFails as (
		SELECT S.CAWBS
		FROM SchedCAAF S INNER JOIN CostAF C ON S.CAWBS = C.WBS_ID_CA
		WHERE ABS(DATEDIFF(d,C.CostAF,S.SchedAF))>31 
	),

	/*
		Then join back to AncestryTree_Get to get the children WBS IDs of the failed CAs.
		This is required because DS04 is at the WP level.
		
		The returned rows here are the WPs that failed the test, which we will use to 
		get our final results.
	*/
	WPFails as (
		SELECT A.WBS_ID
		FROM CAFails C INNER JOIN AncestryTree_Get(@upload_ID) A ON C.CAWBS = A.Ancestor_WBS_ID
		WHERE A.[Type] = 'WP'
	)

	/*
		Use the above to filter DS04 to return rows.
	*/
	SELECT
		*
	FROM
		DS04_schedule
	WHERE