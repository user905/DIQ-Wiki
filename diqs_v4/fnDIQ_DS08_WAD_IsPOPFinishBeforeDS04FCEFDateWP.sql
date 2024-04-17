/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>POP Finish Before Forecast Early Finish (WP)</title>
  <summary>Is the POP finish for this Work Package WAD before the forecast early finish date?</summary>
  <message>pop_finish &lt; DS04.EF_date where schedule_type = FC (by DS08.WBS_ID_WP &amp; DS04.WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080606</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPFinishBeforeDS04FCEFDateWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WPFinish as (
		SELECT WBS_ID WBS, MAX(EF_date) EF
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
		GROUP BY WBS_ID
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN WPFinish C ON W.WBS_ID_WP = C.WBS	
										  AND W.POP_finish_date < C.EF
					INNER JOIN LatestWPWADRev_Get(@upload_ID) R ON W.WBS_ID_WP = R.WBS_ID_WP
																AND W.auth_PM_date = R.PMAuth
	WHERE
		upload_ID = @upload_ID  
)