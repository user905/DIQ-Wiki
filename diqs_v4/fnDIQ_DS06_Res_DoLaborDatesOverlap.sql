/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Labor Overlap</title>
  <summary>Is this labor resource scheduled to work on multiple tasks at the same time?</summary>
  <message>Labor resource start/finish dates overlap across multiple task_IDs.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060246</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_DoLaborDatesOverlap] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Flags as (
		SELECT R1.task_ID, R1.resource_ID, R1.schedule_type
		FROM DS06_schedule_resources R1 INNER JOIN DS06_schedule_resources R2 ON R1.schedule_type = R2.schedule_type
																			 AND R1.resource_ID = R2.resource_ID
		WHERE
				R1.upload_ID = @upload_ID
			AND R2.upload_ID = @upload_ID
			AND (R1.EOC = 'Labor' OR R1.[type] = 'Labor')
			AND (R2.EOC = 'Labor' OR R2.[type] = 'Labor')
			AND R1.task_ID <> R2.task_ID
			AND R1.start_date <= R2.finish_date
			AND R2.start_date <= R1.finish_date
		GROUP BY R1.task_ID, R1.resource_ID, R1.schedule_type
	)
	SELECT 
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN Flags F ON R.schedule_type = F.schedule_type
													AND R.task_ID = F.task_ID
													AND R.resource_ID = F.resource_ID
	WHERE
		upload_ID = @upload_ID AND (EOC = 'Labor' OR [type] = 'Labor')
)