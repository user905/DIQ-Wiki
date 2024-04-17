/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Soft Constraint Missing Date</title>
  <summary>Is this soft constraint missing a constraint date?</summary>
  <message>Soft constraint found (constraint_type = CS_MSOA or CS_MEOA) missing a constraint_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040211</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsSoftConstraintMissingDate] (
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
		AND constraint_date IS NULL
)