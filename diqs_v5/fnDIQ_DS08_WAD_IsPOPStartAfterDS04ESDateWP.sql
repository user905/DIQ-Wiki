/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Start After Schedule Forecast Start (WP)</title>
  <summary>Is the POP Start for this Work Package WAD after the schedule forecast start?</summary>
  <message>POP_start_date &gt; DS04.ES_date where schedule_type = BL (compare by DS08.WBS_ID_WP &amp; DS04.WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080619</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterDS04ESDateWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with SchedStart as (
		SELECT WBS_ID, MIN(ES_date) ES
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
		GROUP BY WBS_ID
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN LatestWPWADRev_Get(@upload_ID) R ON W.WBS_ID_WP = R.WBS_ID_WP 
																AND W.auth_PM_date = R.PMauth
					INNER JOIN SchedStart S ON W.WBS_ID_WP = S.WBS_ID
											AND W.POP_start_date > S.ES
	WHERE
		upload_ID = @upload_ID
)