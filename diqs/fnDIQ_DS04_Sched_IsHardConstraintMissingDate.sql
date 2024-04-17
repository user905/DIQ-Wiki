/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Hard Constraint Missing Date</title>
  <summary>Is this hard constraint missing a constraint date?</summary>
  <message>Hard constraint found (constraint_type = CS_MANDSTART, CS_MSO, CS_MSOB, CS_MANDFIN, CS_MEO, or CS_MEOB) missing a constraint_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040180</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsHardConstraintMissingDate] (
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
		AND constraint_date IS NULL
)