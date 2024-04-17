/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Actual Start Misaligned With Cost (CA)</title>
  <summary>Is the actual start for this WBS misaligned with what is in cost? (Note: Comparison is at the CA WBS level, where ACWP has been collected)</summary>
  <message>Min AS_Date &lt;&gt; min period_date where DS03.ACWPi or DS03.BCWPi &gt; 0 (dollars, hours, or FTEs) by DS04.WBS_ID, DS01.WBS_ID, DS01.parent_WBS_ID, &amp; DS03.WBS_ID_CA.</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040150</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsASMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostAS as (
		SELECT WBS_ID_CA, MIN(period_date) CostAS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			ACWPi_dollars > 0 OR ACWPi_FTEs > 0 OR ACWPi_hours > 0 OR
			BCWPi_dollars > 0 OR BCWPi_FTEs > 0 OR BCWPi_hours > 0
		)
		GROUP BY WBS_ID_CA
	),
	SchedWPAS as (
		SELECT WBS_ID, MIN(AS_Date) SchedAS 
		FROM DS04_schedule 
		WHERE 
				upload_ID = @upload_ID 
			AND schedule_type = 'FC' 
			AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA') 
			AND type NOT IN ('WS','SM','FM') 
		GROUP BY WBS_ID
	),
	SchedCAAS as (
		SELECT A.Ancestor_WBS_ID CAWBS, MIN(S.SchedAS) SchedAS
		FROM SchedWPAS S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.WBS_ID
		WHERE A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		GROUP BY A.Ancestor_WBS_ID
	),
	CASails as (
		SELECT S.CAWBS
		FROM SchedCAAS S INNER JOIN CostAS C ON S.CAWBS = C.WBS_ID_CA
		WHERE ABS(DATEDIFF(d,C.CostAS,S.SchedAS))>31 
	),
	WPFails as (
		SELECT A.WBS_ID
		FROM CASails C INNER JOIN AncestryTree_Get(@upload_ID) A ON C.CAWBS = A.Ancestor_WBS_ID
		WHERE A.[Type] = 'WP'
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
		AND WBS_ID IN (SELECT WBS_ID FROM WPFails)
)