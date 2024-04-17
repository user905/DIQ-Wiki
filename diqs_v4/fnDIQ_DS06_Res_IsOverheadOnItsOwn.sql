/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Task with Overhead EOC Only</title>
  <summary>Is this task resource-loaded with only Overhead EOC resources?</summary>
  <message>Task lacking EOC other than Overhead (task_ID where EOC = Overhead only).</message>
  <grouping>task_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060241</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsOverheadOnItsOwn] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Ovhd as (
		select task_ID, schedule_type
		from DS06_schedule_resources
		where upload_ID = @upload_ID and EOC = 'Overhead'
	), NonO as (
		select task_ID, schedule_type
		from DS06_schedule_resources
		where upload_ID = @upload_ID and EOC <> 'Overhead'
	), Flags as (
		select Ovhd.task_ID, Ovhd.schedule_type
		from Ovhd left outer join NonO on Ovhd.task_ID = NonO.task_ID AND Ovhd.schedule_type = NonO.schedule_type
		where NonO.task_ID is null
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN Flags F 
									ON R.task_ID = F.task_ID 
									AND R.schedule_type = F.schedule_type
	WHERE
			R.upload_id = @upload_ID
		AND R.EOC = 'Overhead'
)