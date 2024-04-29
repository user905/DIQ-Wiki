/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Multiple Reprogramming Milestones In Current Period</title>
  <summary>Do multiple reprogramming milestones exist in the current period?</summary>
  <message>Multiple reprogramming milestones (milestone_level = 138) found in the current period (ES_date within 35 days of CPP Status Date).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040137</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoMultipleRpgMSsExistInTheCurrentPeriod] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    WITH RPGMS AS (
		SELECT schedule_type, task_ID
		FROM DS04_schedule
		WHERE upload_ID = @upload_id AND milestone_level = 138 
		AND DATEDIFF(d, COALESCE(ES_date,EF_date), CPP_status_date) < 35
		AND DATEDIFF(d, COALESCE(ES_date,EF_date), CPP_status_date) >= 0 --ignore if the MS is after the status date
	), RPGMSCount AS (
        SELECT schedule_type, COUNT(*) AS cnt
        FROM RPGMS
        GROUP BY schedule_type
		HAVING COUNT(*) > 1
    ), Flags as (
        SELECT R.schedule_type, R.task_ID
        FROM RPGMS R INNER JOIN RPGMSCount Cnt ON R.schedule_type = Cnt.schedule_type
        WHERE Cnt.cnt > 1
    )
    SELECT
       S.*
    FROM
        DS04_schedule S INNER JOIN Flags F ON S.schedule_type = F.schedule_type AND S.task_ID = F.task_ID
    WHERE
        upload_ID = @upload_id
)