/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Profit Fee Misaligned With CC Log Detail</title>
  <summary>Is profit fee misaligned with the dollars delta for profit fee transactions in the CC log detail?</summary>
  <message>profit_fee_dollars &lt;&gt; sum of DS10.dollars_delta where category = profit-fee.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070366</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsProfitFeeAlignedWithDS10] (
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
		AND profit_fee_dollars <> (
			SELECT SUM(dollars_delta)
			FROM DS10_CC_log_detail
			WHERE upload_ID = @upload_ID AND category = 'profit-fee'
		)
)