/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>LOE with FF Successor</title>
  <summary>Is the predecessor for this FF relationship an LOE task?</summary>
  <message>task_ID with DS05.type = FF &amp; DS04.type = LOE or DS04.EVT = A (by DS04.task_ID &amp; DS05.predecessor_task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9050283</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsLOESuccessorRelEqToFF] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Tasks as (
      SELECT schedule_type, task_ID, ISNULL(EVT,'') EVT, Type
      FROM DS04_schedule
      WHERE upload_ID = @upload_ID
	), LOEPred as (
      SELECT schedule_type, task_ID
      FROM Tasks
      WHERE [type] = 'LOE' OR EVT = 'A'
    ), NonLOESucc as (
      SELECT schedule_type, task_ID
      FROM Tasks
      WHERE [type] <> 'LOE' AND EVT <> 'A'
    )
	SELECT L.*
	FROM DS05_schedule_logic L  INNER JOIN NonLOESucc Succ ON L.schedule_type = Succ.schedule_type AND L.task_ID = Succ.task_ID
                              INNER JOIN LOEPred Pred   ON L.schedule_type = Pred.schedule_type AND L.predecessor_task_ID = Pred.task_ID
	WHERE L.upload_ID = @upload_ID AND L.type = 'FF'
)