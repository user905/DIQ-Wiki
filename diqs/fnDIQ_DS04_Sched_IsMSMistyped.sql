/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Milestone Typed Improperly</title>
  <summary>Is this milestone not typed as a start or finish milestone?</summary>
  <message>Milestone level has been provided but tasks type is not either SM or FM.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040195</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMSMistyped] (
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
		AND milestone_level IS NOT NULL
		AND [type] NOT IN ('SM','FM')
)