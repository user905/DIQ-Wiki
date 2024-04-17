/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Log Hours Delta Misaligned With Log Detail Delta</title>
  <summary>Is the hours delta for this CC Log entry misaligned with what is in the CC Log detail table?</summary>
  <message>hours_delta &lt;&gt; SUM(DS10.hours_delta) (by CC_log_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090444</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsHoursDeltaMisalignedWithDS10] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CCLogDetail as (
		SELECT CC_log_ID, SUM(hours_delta) HrsDelt
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_ID
		GROUP BY CC_log_ID
	)
	SELECT 
		L.*
	FROM
		DS09_CC_log L INNER JOIN CCLogDetail D ON L.CC_log_ID = D.CC_log_ID
	WHERE
			upload_ID = @upload_ID  
		AND L.hours_delta <> D.HrsDelt
)