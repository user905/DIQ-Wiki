/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Uneven Use of Overhead</title>
  <summary>Is Overhead EOC used for some tasks but not all?</summary>
  <message>Task lacking overhead EOC despite overhead use elsewhere (if overhead is used on tasks, it must be used for all tasks).</message>
  <grouping>task_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060240</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsOverheadUsedUnevenly] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Ovhd as (
		SELECT task_ID, schedule_type
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND EOC = 'Overhead'
	)
	SELECT
		*
	FROM
		DS06_schedule_resources
	WHERE
			upload_id = @upload_ID
		AND (
				schedule_type = 'FC' AND task_ID NOT IN (SELECT task_ID from Ovhd WHERE schedule_type = 'FC') OR
				schedule_type = 'BL' AND task_ID NOT IN (SELECT task_ID from Ovhd WHERE schedule_type = 'BL')
		)
)