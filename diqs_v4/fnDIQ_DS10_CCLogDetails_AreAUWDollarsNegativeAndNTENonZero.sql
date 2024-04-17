/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Negative AUW Dollar Delta with Non-Zero NTE</title>
  <summary>Does this negative AUW dollar change also have an NTE?</summary>
  <message>AUW = Y &amp; dollars_delta &lt; 0 &amp; NTE_dollars_delta &lt;&gt; 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100452</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_AreAUWDollarsNegativeAndNTENonZero] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_ID
	  AND AUW = 'Y'
	  AND dollars_delta < 0
	  AND NTE_dollars_delta IS NOT NULL
	  AND NTE_dollars_delta <> 0
)