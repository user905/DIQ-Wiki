/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Started Task Missing Actual Start</title>
  <summary>Is this task with a non-zero % Complete missing an Actual Start?</summary>
  <message>Task with a non-zero % Complete (pc_units, pc_duration, or pc_physical &gt; 0) missing Actual Start (AS_Date).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040200</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPCGT0MissingASDate] (
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
		AND (PC_duration > 0 OR PC_units > 0 OR PC_physical > 0)
		AND AS_date IS NULL
)