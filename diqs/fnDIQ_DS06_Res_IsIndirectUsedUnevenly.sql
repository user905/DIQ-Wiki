/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Uneven Use of Indirect</title>
  <summary>Is Indirect EOC used for some tasks but not all?</summary>
  <message>Task lacking Indirect EOC despite Indirect use elsewhere (if Indirect is used on tasks, it must be used for all tasks).</message>
  <grouping>task_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060262</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsIndirectUsedUnevenly] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Ovhd as (
		SELECT task_ID, schedule_type, TRIM(ISNULL(subproject_ID,'')) SubP
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND EOC = 'Indirect'
	)
	SELECT R.*
	FROM DS06_schedule_resources R LEFT OUTER JOIN Ovhd O ON R.task_ID = O.task_ID AND R.schedule_type = O.schedule_type AND TRIM(ISNULL(R.subproject_ID,'')) = O.SubP
	WHERE upload_id = @upload_ID
        AND EXISTS (SELECT 1 FROM Ovhd)
		AND O.task_ID IS NULL
		AND R.EOC <> 'Indirect'
)