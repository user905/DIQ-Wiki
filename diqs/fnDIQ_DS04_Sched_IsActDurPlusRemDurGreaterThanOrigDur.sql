/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Actual &amp; Remaining Durations Sum to More Than Original</title>
  <summary>Do the actual and remaining durations sum to more than the original?</summary>
  <message>duration_actual_days + duration_remaining_days &gt; duration_original_days.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040138</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsActDurPlusRemDurGreaterThanOrigDur] (
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
		AND (duration_remaining_days + duration_actual_days) > duration_original_days
)