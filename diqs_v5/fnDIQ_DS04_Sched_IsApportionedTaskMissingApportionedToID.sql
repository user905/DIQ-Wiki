/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Missing Apportioned To Task ID</title>
  <summary>Is this apportioned task missing an apportioned to task ID?</summary>
  <message>Apportioned task (EVT = J or M) missing ID in EVT_J_to_task_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040141</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsApportionedTaskMissingApportionedToID] (
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
		AND ISNULL(EVT_J_to_task_ID,'')=''
		AND EVT IN ('J','M')
)