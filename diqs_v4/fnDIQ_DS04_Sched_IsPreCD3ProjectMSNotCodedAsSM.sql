/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Pre-CD3 Project Milestone Not Coded As Start Milestone</title>
  <summary>Is this major pre-CD3 milestone not coded as a start milestone?</summary>
  <message>Project-level pre-CD3 milestone (milestone_level &lt;= 150) is not coded as a start milestone (type = SM).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040205</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPreCD3ProjectMSNotCodedAsSM] (
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
		AND	milestone_level BETWEEN 100 AND 150
		AND type <> 'SM'
)