/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Duration % Complete Type On Non-LOE Task</title>
  <summary>Is this non-LOE task using a Duration % Complete type?</summary>
  <message>Duration % Complete type (PC_type = Duration) on non-LOE task (EVT = A and type = LOE).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040168</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsDurationPCTypeOnNonLOETask] (
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
		AND PC_type = 'Duration'
		AND EVT <> 'A'
		AND type <> 'LOE'
)