/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Non-WP, PP, or SLPP Type Found in Schedule</title>
  <summary>Is this WBS ID typed as something other than WP, PP, or SLPP in the WBS Dictionary?</summary>
  <message>WBS_ID is not WP, PP, or SLPP type in DS01.type.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040225</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsWBSTypeDisallowed] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Disallowed as (
		SELECT WBS_ID 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND type NOT IN ('WP','PP','SLPP'))
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Disallowed D ON S.WBS_ID = D.WBS_ID
	WHERE
		upload_id = @upload_ID
)