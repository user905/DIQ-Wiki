/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>QRA Confidence Level Low for Schedule Following BCP</title>
  <summary>Is the QRA Confidence Level below 90% for schedule following a BCP?</summary>
  <message>QRA_CL_schedule_pct &lt; .9 count where DS09.type = BCP or where DS04.milestone_level between 131 &amp; 135 &gt; 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070368</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsQRACLSchedLowFollowingBCP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (
				(SELECT COUNT(*) FROM DS09_CC_log WHERE upload_ID = @upload_ID AND type = 'BCP') > 0
			OR (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_id AND milestone_level BETWEEN 131 AND 135) > 0
		)
		AND QRA_CL_schedule_pct < .9
)