/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>% Complete Duration Missing Actual Start</title>
  <summary>Is this task with a non-zero % Complete Duration missing an Actual Start?</summary>
  <message>Task with a non-zero % Complete Duration (PC_type = Duration and PC_duration &gt; 0) missing Actual Start (AS_Date missing).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040606</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsTaskWithPCDurationMissingASDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'FC'
		AND PC_type = 'Duration'
		AND PC_duration > 0 
		AND AS_date IS NULL
)