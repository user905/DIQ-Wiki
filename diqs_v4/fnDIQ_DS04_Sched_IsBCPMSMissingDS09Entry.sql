/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>BCP Missing in Change Control</title>
  <summary>Is this BCP missing an entry in the Change Control log?</summary>
  <message>task with milestone_level = 131 - 135 found without DS09 entry where type = BCP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040151</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsBCPMSMissingDS09Entry] (
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
		AND milestone_level BETWEEN 131 AND 135
		AND (SELECT COUNT(*) FROM DS09_CC_log WHERE upload_ID = @upload_ID AND type = 'BCP') = 0
)