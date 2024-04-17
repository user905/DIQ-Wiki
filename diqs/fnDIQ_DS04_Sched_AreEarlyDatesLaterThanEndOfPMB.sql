/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Task Starts or Finishes after End of PMB</title>
  <summary>Is this task forecasted to start or finish after the end of the PMB?</summary>
  <message>ES_date or EF_date is later than the ES_date or EF_Date for the End of PMB milestone (milestone_level = 175).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040113</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreEarlyDatesLaterThanEndOfPMB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ToTest as (
		SELECT schedule_type, ES_date, EF_date
		FROM DS04_schedule			
		WHERE upload_ID = @upload_ID AND milestone_level = 175
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN ToTest T ON S.schedule_type = T.schedule_type
	WHERE
			S.upload_ID = @upload_ID
		AND ISNULL(S.subtype,'') NOT IN ('SVT','ZBA')
		AND type NOT IN ('SM','FM')
		AND (S.ES_date > T.ES_date OR S.EF_date > T.EF_date)
)