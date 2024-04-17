/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Task with Indirect EOC Only</title>
  <summary>Is this task resource-loaded with only Indirect EOC resources?</summary>
  <message>Task lacking EOC other than Indirect (task_ID where EOC = Indirect only).</message>
  <grouping>task_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060241</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsIndirectOnItsOwn] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Ind as (
		select task_ID, schedule_type, TRIM(ISNULL(subproject_ID,'')) SubP
		from DS06_schedule_resources
		where upload_ID = @upload_ID and EOC = 'Indirect'
	), NonI as (
		select task_ID, schedule_type, TRIM(ISNULL(subproject_ID,'')) SubP
		from DS06_schedule_resources
		where upload_ID = @upload_ID and EOC <> 'Indirect' AND EOC IS NOT NULL
	), Flags as (
		select Ind.task_ID, Ind.schedule_type, Ind.SubP
		from Ind left outer join NonI on Ind.task_ID = NonI.task_ID AND Ind.schedule_type = NonI.schedule_type AND Ind.SubP = NonI.SubP
		where NonI.task_ID is null
	)
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN Flags F ON R.task_ID = F.task_ID AND R.schedule_type = F.schedule_type AND TRIM(ISNULL(R.subproject_ID,'')) = F.SubP
	WHERE R.upload_id = @upload_ID AND R.EOC = 'Indirect'
)