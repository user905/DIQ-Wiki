/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>UB Without UB Change Control</title>
  <summary>Are there UB dollars without UB transactions in the change control log?</summary>
  <message>UB_bgt_dollars &lt;&gt; 0 &amp; no rows found in DS10 where category = UB.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070363</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_DoesUBExistWithoutDS10Transactions] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CCLogDetail as (
		SELECT category
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (SELECT COUNT(*) FROM CCLogDetail WHERE category = 'UB') = 0
		AND (SELECT COUNT(*) FROM CCLogDetail) > 0 --test only if there are any CC log detail rows
		AND UB_bgt_dollars <> 0
)