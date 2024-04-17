/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Reprogramming Missing in CC Log Detail (WP)</title>
  <summary>Is this Work or Planning Planning with reprogramming missing in the CC Log detail?</summary>
  <message>WBS_ID where RPG = Y not found in DS10.WBS_ID list.</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040280</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsRPGWBSMissingInDS10WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		S.*
	FROM
		DS04_schedule S LEFT JOIN DS10_CC_log_detail C ON S.WBS_ID = C.WBS_ID
	WHERE
			S.upload_ID = @upload_ID
		AND C.upload_ID = @upload_ID
		AND S.RPG = 'Y'
		AND C.WBS_ID IS NULL
)