/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>AUW Transaction Dollars Misaligned With Project Level AUW</title>
  <summary>Are the dollars delta for AUW-related transactions misaligned with the AUW dollar value in the IPMR header?</summary>
  <message>Sum of dollars_delta where AUW = Y &lt;&gt; DS07.AUW_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100450</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_AreAUWDollarDeltasMisalignedWithDS07AUW] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with AUW as (
		SELECT ISNULL(AUW_dollars,0) AUW
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	), AUWTransactions as (
		SELECT SUM(ISNULL(dollars_delta,0)) DollarsDelta
		FROM DS10_CC_log_detail 
		WHERE upload_ID = @upload_ID AND AUW = 'Y'
	)
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_ID
	AND AUW = 'Y'
	AND (SELECT AUW FROM AUW) <> (SELECT DollarsDelta FROM AUWTransactions)
)