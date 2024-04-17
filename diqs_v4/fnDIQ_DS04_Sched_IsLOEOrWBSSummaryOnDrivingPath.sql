/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>LOE or WBS Summary Task On Driving Path</title>
  <summary>Is this LOE or WBS summary task on the driving path?</summary>
  <message>LOE task (EVT = A or type = LOE) or WBS summary task (type = WS) found on the driving path (driving_path = Y).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040188</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsLOEOrWBSSummaryOnDrivingPath] (
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
		AND [driving_path] = 'y'
		AND (EVT = 'A' OR type IN ('WS', 'LOE'))
)