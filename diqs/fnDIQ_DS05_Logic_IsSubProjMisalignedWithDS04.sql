/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>DELETED</status>
  <severity>ALERT</severity>
  <title>Predecessor Subproject ID Mismatched with Schedule</title>
  <summary>Is the subproject ID for this predecessor mismatched with what is in schedule?</summary>
  <message>Predecessor subproject_ID does not align with what is in DS04 schedule (by schedule type, DS05.predecessor_task_ID &amp; DS04.task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9050279</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsSubProjMisalignedWithDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		L.*
	FROM
		DS05_schedule_logic L,
		DS04_schedule S
	WHERE
			L.upload_ID = @upload_ID
		AND S.upload_ID = @upload_ID
		AND L.schedule_type = S.schedule_type
		AND L.predecessor_task_ID = S.task_ID
		AND L.subproject_ID <> S.subproject_ID
)