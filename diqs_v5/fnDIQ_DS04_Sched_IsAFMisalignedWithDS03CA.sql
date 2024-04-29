/*
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
	with CostAF as (
		SELECT WBS_ID_CA, MAX(period_date) CostAF
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			ACWPi_dollars > 0 OR ACWPi_FTEs > 0 OR ACWPi_hours > 0 OR
			BCWPi_dollars > 0 OR BCWPi_FTEs > 0 OR BCWPi_hours > 0
		)
		GROUP BY WBS_ID_CA
	),
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
	SchedCAAF as (
		SELECT A.Ancestor_WBS_ID CAWBS, MAX(S.SchedAF) SchedAF
		FROM SchedWPAF S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.WBS_ID
		WHERE A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		GROUP BY A.Ancestor_WBS_ID
	),
	CAFails as (
		SELECT S.CAWBS
		FROM SchedCAAF S INNER JOIN CostAF C ON S.CAWBS = C.WBS_ID_CA
		WHERE ABS(DATEDIFF(d,C.CostAF,S.SchedAF))>31 
	),
	WPFails as (
		SELECT A.WBS_ID
		FROM CAFails C INNER JOIN AncestryTree_Get(@upload_ID) A ON C.CAWBS = A.Ancestor_WBS_ID
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