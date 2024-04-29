/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Task ID Missing in Labor Resources</title>
  <summary>Is this task id missing in the forecast labor resources?</summary>
  <message>task_ID not in DS06.task_ID where EOC = Labor &amp; schedule_type = FC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130538</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsTaskIDMissingInDS06Labor] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS13_subK
	WHERE 
			upload_ID = @upload_ID 
		AND task_ID NOT IN  (
			SELECT task_ID
			FROM DS06_schedule_resources
			WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND EOC = 'Labor'
		)
)