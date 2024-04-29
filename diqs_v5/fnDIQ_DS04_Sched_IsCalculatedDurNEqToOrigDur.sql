/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>Calculated &amp; Original Durations Misaligned</title>
  <summary>Is the calculated duration substantially different from the original duration?</summary>
  <message>|(EF_days - ES_days) / duration_original_days| &gt; .25.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040604</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCalculatedDurNEqToOrigDur] (
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
			upload_ID = @upload_ID
		AND (
				ISNULL(duration_original_days,0) = 0 AND DATEDIFF(day, ES_date, EF_date) > 5 
			OR ABS(
					(DATEDIFF(day, ES_date, EF_date) - ISNULL(duration_original_days,0)) / 
					NULLIF(duration_original_days,0)
				) > 0.25
		)
)