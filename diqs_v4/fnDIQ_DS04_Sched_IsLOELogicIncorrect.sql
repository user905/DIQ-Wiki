/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>LOE Task With Improper Logic</title>
  <summary>Is this LOE task missing at least one FF and SS predecessor (both discrete)?</summary>
  <message>DS04.type = LOE or DS04.EVT = A without DS05.type = FF and SS relationships.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040187</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsLOELogicIncorrect] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Tasks as (
		SELECT schedule_type, task_ID, type, EVT
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), LOELogic as (
		SELECT L.*
		FROM DS05_schedule_logic L INNER JOIN Tasks LOE ON L.schedule_type = LOE.schedule_type
													 	AND L.task_ID = LOE.task_ID
		WHERE upload_ID = @upload_ID AND (LOE.[type] = 'LOE' OR LOE.EVT = 'A')		
	), Logic as (
		SELECT L.*
		FROM LOELogic L INNER JOIN Tasks Discrete ON L.schedule_type = Discrete.schedule_type
												 AND L.predecessor_task_ID = Discrete.task_ID
		WHERE upload_ID = @upload_ID AND Discrete.type <> 'LOE' AND Discrete.EVT NOT IN ('A','K','M')
	), LogicAgg as (
		SELECT schedule_type, task_ID, STRING_AGG(type, ',') WITHIN GROUP (ORDER BY type) Type
		FROM Logic
		GROUP BY schedule_type, task_ID
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN LogicAgg L ON S.schedule_type = L.schedule_type
											 AND S.task_ID = L.task_ID
	WHERE
			upload_id = @upload_ID
		AND (L.[Type] NOT LIKE '%SS%FF%' OR	L.[Type] NOT LIKE '%FF%SS%')
)