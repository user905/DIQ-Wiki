/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Non-Unique Relationship</title>
  <summary>Is this row duplicated by schedule_type, task_ID, predecessor_task_ID, subproject_ID, and predecessor_subproject_ID?</summary>
  <message>Count of schedule_type, task_ID, predecessor_task_ID, subproject_ID, and predecessor_subproject_ID combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1050236</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT schedule_type, task_ID, predecessor_task_ID, ISNULL(subproject_ID,'') SubP, ISNULL(predecessor_subproject_ID,'') PSubP
		FROM DS05_schedule_logic
		WHERE upload_ID = @upload_ID
		GROUP BY schedule_type, task_ID, predecessor_task_ID, ISNULL(subproject_ID,''), ISNULL(predecessor_subproject_ID,'')
		HAVING COUNT(*) > 1
	)
	SELECT L.*
	FROM DS05_schedule_logic L INNER JOIN Dupes D ON L.schedule_type = D.schedule_type
												 AND L.task_ID = D.task_ID
												 AND L.predecessor_task_ID = D.predecessor_task_ID
												 AND ISNULL(L.subproject_ID,'') = D.SubP
												 AND ISNULL(L.predecessor_subproject_ID,'') = D.PSubP
	WHERE upload_id = @upload_ID
)