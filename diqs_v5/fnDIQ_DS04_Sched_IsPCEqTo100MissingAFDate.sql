/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Completed Task Missing Actual Finish</title>
  <summary>Is this completed task (physical, units, or duration % complete = 100%) missing an Actual Finish?</summary>
  <message>Task with a physical, units, or duration % complete = 1 (pc_physical, pc_units, pc_duration) missing Actual Finish (AF_Date).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040199</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPCEqTo100MissingAFDate] (
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
		AND (PC_duration = 1 OR PC_physical = 1 OR PC_units = 1)
		AND AF_date IS NULL
)