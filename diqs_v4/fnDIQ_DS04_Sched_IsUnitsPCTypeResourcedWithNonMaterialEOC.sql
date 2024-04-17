/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Task With Units % Complete Not Materially Resource Loaded</title>
  <summary>Does this task with units % complete have resources with an EOC other than material?</summary>
  <message>Task with units % complete type (PC_type = units) has non-material EOC resources (DS06.EOC &lt;&gt; material).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040219</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsUnitsPCTypeResourcedWithNonMaterialEOC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonMatRes as (
		SELECT schedule_type, task_ID 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND EOC <> 'material'
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN NonMatRes R 	ON S.task_ID = R.task_ID
												AND S.schedule_type = R.schedule_type
	WHERE
			upload_id = @upload_ID
		AND PC_type = 'units'
)