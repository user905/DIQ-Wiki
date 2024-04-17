/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Activity Missing EVT</title>
  <summary>Is this activity missing an EVT?</summary>
  <message>activity where EVT = null or blank (Note: If task is a milestone, then type must be either FM or SM. Otherwise, it will be treated as an activity.).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040139</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsActivityMissingEVT] (
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
		AND type NOT IN ('SM','FM','WS')
		AND TRIM(ISNULL(EVT,'')) = ''
)