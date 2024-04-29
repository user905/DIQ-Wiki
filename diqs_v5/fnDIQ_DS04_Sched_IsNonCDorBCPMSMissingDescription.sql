/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Non-CD or BCP Milestone Missing Description</title>
  <summary>Is this non-CD or BCP milestone missing a description?</summary>
  <message>Non-CD or BCP milestone (milestone_level = 138 or 200-800) is missing a description.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040197</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsNonCDorBCPMSMissingDescription] (
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
		AND (milestone_level BETWEEN 200 AND 800 OR milestone_level = 138)
		AND TRIM(ISNULL([milestone_level_description],'')) = ''
)