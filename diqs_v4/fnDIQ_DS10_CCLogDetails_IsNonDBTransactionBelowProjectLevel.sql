/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>UB, MR, or CNT Transaction Below Project Level</title>
  <summary>Is this UB, MR, or CNT transaction being applied below the project level?</summary>
  <message>category = UB, MR, or CNT &amp; DS01.level &lt;&gt; 1 (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100468</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsNonDBTransactionBelowProjectLevel] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		L.*
	FROM 
		DS10_CC_log_detail L INNER JOIN DS01_WBS W ON L.WBS_ID = W.WBS_ID
	WHERE 
		L.upload_ID = @upload_ID
	AND W.upload_ID = @upload_ID
	AND category IN ('UB','MR','CNT')
	AND W.[level] <> 1
)