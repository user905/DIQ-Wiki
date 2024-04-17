/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>LOE Type With Mismatched EVT</title>
  <summary>Is the LOE type mismatched with the EVT for this task?</summary>
  <message>Task of type = LOE has a mismatched EVT (EVT should be A or blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040189</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsLOETypeMismatchedWithEVT] (
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
		AND type = 'LOE'
		AND TRIM(ISNULL(EVT,'')) NOT IN ('A','')
)