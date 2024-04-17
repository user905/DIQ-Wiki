/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Milestone with Non-Zero Duration</title>
  <summary>Does this milestone have a non-zero duration?</summary>
  <message>Milestone with original, actual, or remaining duration &gt; 0 (duration_original_days, duration_actual_days, or duration_remaining_days), or where Start and Finish dates are not aligned (ES_date/EF_date, LS_date/LF_date, AS_date/AF_date).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040127</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesMSHaveNonZeroDur] (
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
		AND type IN ('SM','FM')
		AND (
				duration_original_days <> 0 
			OR duration_actual_days <> 0
			OR duration_remaining_days <> 0
			OR ES_date <> EF_date
			OR LS_date <> LF_date
			OR AS_date <> AF_date
		)
)