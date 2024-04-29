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
		SELECT schedule_type, task_ID, type, ISNULL(EVT,'') EVT, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), Logic as (
		SELECT schedule_type, task_ID, predecessor_task_ID, type, ISNULL(subproject_ID,'') SubP, ISNULL(predecessor_subproject_ID,'') PSubP FROM DS05_schedule_logic WHERE upload_ID = @upload_id
	), LOELogic as (
		SELECT L.*
		FROM Logic L INNER JOIN Tasks LOE ON L.schedule_type = LOE.schedule_type
										AND L.task_ID = LOE.task_ID
										AND L.SubP = LOE.SubP
		WHERE LOE.[type] = 'LOE' OR LOE.EVT IN ('A', 'J', 'M')
	), LOEsWithDisPreds as (
		SELECT L.schedule_type, L.task_ID, L.SubP, STRING_AGG(L.type, ',') WITHIN GROUP (ORDER BY L.type) Type
		FROM LOELogic L INNER JOIN Tasks Discrete ON L.schedule_type = Discrete.schedule_type
												 AND L.predecessor_task_ID = Discrete.task_ID --join to predecessor task id
												 AND L.PSubP = Discrete.SubP -- join to predecessor subproject id
		WHERE Discrete.Type IN ('TD', 'RD') AND Discrete.EVT NOT IN ('A','J','M')
		GROUP BY L.schedule_type, L.task_ID, L.SubP
	)
	SELECT S.*
	FROM DS04_schedule S LEFT OUTER JOIN LOEsWithDisPreds L 	ON S.schedule_type = L.schedule_type
																AND S.task_ID = L.task_ID
																AND ISNULL(S.subproject_ID,'') = L.SubP
	WHERE upload_id = @upload_ID 
		AND (S.type = 'LOE' or S.EVT IN ('A', 'J', 'M'))
		AND (
		L.[Type] NOT LIKE '%SS%FF%' AND L.[Type] NOT LIKE '%FF%SS%' OR --#1
		L.task_ID IS NULL --#3
	)
	UNION 
	SELECT S.*
	FROM DS04_schedule S INNER JOIN LOELogic L ON S.schedule_type = L.schedule_type
											  AND S.task_ID = L.predecessor_task_ID
											  AND ISNULL(S.subproject_ID,'') = L.PSubP
	WHERE S.upload_id = @upload_ID AND (S.[type] = 'LOE' OR S.EVT IN ('A', 'J', 'M'))
)