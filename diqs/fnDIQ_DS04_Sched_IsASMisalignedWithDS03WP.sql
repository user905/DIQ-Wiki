/*
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
	with CostAS as (
		SELECT WBS_ID_WP, MIN(period_date) CostAS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			ACWPi_dollars > 0 OR ACWPi_FTEs > 0 OR ACWPi_hours > 0 OR
			BCWPi_dollars > 0 OR BCWPi_FTEs > 0 OR BCWPi_hours > 0
		)
		GROUP BY WBS_ID_WP
	),
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
	WBSFails as (
		SELECT S.WBS_ID
		FROM SchedAS S INNER JOIN CostAS C ON S.WBS_ID = C.WBS_ID_WP
		WHERE ABS(DATEDIFF(d,C.CostAS,S.SchedAS))>31 
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