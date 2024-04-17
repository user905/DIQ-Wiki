/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Hard Constraint Missing Justification</title>
  <summary>Does this task have a hard constraint without a justification?</summary>
  <message>Task found with a hard constraint (constraint_type = CS_MANDSTART,CS_MSO, CS_MSOB, CS_MANDFIN, CS_MEO, or CS_MEOB) but no justification (justification_constraint_hard is null or empty).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040181</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsHardConstraintMissingJustification] (
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
		AND constraint_type in (SELECT type FROM HardConstraints)
		AND TRIM(ISNULL(justification_constraint_hard,'')) = ''
)