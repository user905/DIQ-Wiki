/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Hard Constraint Found</title>
  <summary>Is there a hard constraint on this task?</summary>
  <message>Hard constraint found (constraint_type = CS_MANDSTART, CS_MSO, CS_MSOB, CS_MANDFIN, CS_MEO, or CS_MEOB).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040125</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesHardConstraintExist] (
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
		AND constraint_type in ('CS_MANDSTART','CS_MSO', 'CS_MSOB', 'CS_MANDFIN', 'CS_MEO', 'CS_MEOB')
)