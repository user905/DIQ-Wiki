/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Post-CD3 Project Milestone Not Coded As Finish Milestone</title>
  <summary>Is this major post-CD3 milestone not coded as a finish milestone?</summary>
  <message>Post-CD3 milestone (milestone_level = 160 - 800) is not coded as a finish milestone (type = FM).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040204</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPostCD3MSNotCodedAsFM] (
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
		AND	milestone_level BETWEEN 160 AND 800
		AND type <> 'FM'
)