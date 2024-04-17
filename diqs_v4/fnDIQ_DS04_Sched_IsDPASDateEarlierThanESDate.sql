/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Actual Start Prior to Early Start Along the Driving Path</title>
  <summary>Does this task along the Driving Path have an Actual Start earlier than the Early Start? (BL)</summary>
  <message>AS_date &lt; ES_date along the driving path (driving_path = Y). (BL)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040167</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsDPASDateEarlierThanESDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		F.*
	FROM
		DS04_schedule F,
		(SELECT task_ID, ES_Date FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND driving_path = 'Y') B
	WHERE
			upload_id = @upload_ID
		AND F.task_ID = B.task_ID
		AND schedule_type = 'FC'
		AND F.AS_date < B.ES_date
)