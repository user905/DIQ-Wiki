/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Log Dollars Delta Misaligned With Log Detail Delta</title>
  <summary>Is the dollars delta for this CC Log entry misaligned with what is in the CC Log detail table?</summary>
  <message>dollars_delta &lt;&gt; SUM(DS10.dollars_delta) (by CC_log_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090443</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsDollarsDeltaMisalignedWithDS10] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CCLogDetail as (
		SELECT CC_log_ID, SUM(dollars_delta) DollDelt
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
		AND L.dollars_delta <> D.DollDelt
)