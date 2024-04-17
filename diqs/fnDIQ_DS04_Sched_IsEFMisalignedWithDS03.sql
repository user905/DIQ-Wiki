/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Finish Date Misaligned With Cost</title>
  <summary>Is the early finish date for this WBS misaligned with what is in cost (DS03)?</summary>
  <message>EF_date for this WBS_ID does not align with the last period where BCWSi &gt; 0 in DS03 cost (dollars/hours/FTEs).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040170</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsEFMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostFinish as (
		SELECT WBS_ID_WP, MAX(period_date) CostEF
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
		GROUP BY WBS_ID_WP
	), SchedFinish as (
		SELECT WBS_ID, MAX(EF_Date) SchedEF
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA') and type NOT IN ('WS','SM','FM') 
		GROUP BY WBS_ID
	),WBSFails as (
		SELECT S.WBS_ID
		FROM SchedFinish S INNER JOIN CostFinish C ON C.WBS_ID_WP = S.WBS_ID
		WHERE ABS(DATEDIFF(d,C.CostEF,S.SchedEF))>31 
	)
	SELECT
		*
	FROM
		DS04_schedule S
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'FC'
		AND ISNULL(subtype,'') NOT IN ('SVT', 'ZBA') 
		AND type NOT IN ('WS','SM','FM')
		AND WBS_ID IN (SELECT WBS_ID FROM WBSFails)
)