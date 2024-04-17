/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Insufficient Constraint Justification</title>
  <summary>Is a sufficient justification lacking for the constraint on this task?</summary>
  <message>Task is lacking a sufficient justification for its constraint (justification_constraint_hard or justification_constraint_soft are lacking at least two words).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040161</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsConstraintJustificationInsufficient] (
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
		AND (
				(constraint_type IN (SELECT type FROM HardConstraints) AND CHARINDEX(' ',TRIM([justification_constraint_hard])) = 0) OR 
				(constraint_type IN (SELECT type FROM SoftConstraints) AND CHARINDEX(' ',TRIM([justification_constraint_soft])) = 0)
		)
)