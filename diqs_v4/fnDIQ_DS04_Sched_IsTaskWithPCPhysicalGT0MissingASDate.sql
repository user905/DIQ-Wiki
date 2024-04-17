/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Task with Physical % Complete Missing Actual Start</title>
  <summary>Is this task with a physical % complete missing an Actual Start?</summary>
  <message>Task with a % physical complete (PC_type = Physical and PC_physical &gt; 0) missing Actual Start (AS_Date).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040218</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsTaskWithPCPhysicalGT0MissingASDate] (
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
		AND PC_type = 'Physical'
		AND PC_physical > 0
		AND AS_date IS NULL
)