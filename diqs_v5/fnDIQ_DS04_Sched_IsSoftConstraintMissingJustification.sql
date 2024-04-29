/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Soft Constraint Missing Justification</title>
  <summary>Does this task have a soft constraint without a justification?</summary>
  <message>Task found with a soft constraint (constraint_type = CS_MSOA or CS_MEOA) but no justification (justification_constraint_soft is null or empty).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040230</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsSoftConstraintMissingJustification] (
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
		AND constraint_type in (SELECT type FROM SoftConstraints)
		AND ISNULL(justification_constraint_soft,'') = ''
)