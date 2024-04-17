/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>UB Transaction Dollars Misaligned With Project Level UB</title>
  <summary>Are the dollars delta for UB-related transactions misaligned with the UB dollar value in the IPMR header?</summary>
  <message>Sum of dollars_delta where category = UB &lt;&gt; DS07.UB_bgt_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100459</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_AreUBDollarDeltasMisalignedWithDS07UB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with UBBgt as (
		SELECT ISNULL(UB_bgt_dollars,0) UB
		FROM DS07_IPMR_header
		WHERE upload_ID = @upload_id
	), UBDelta as (
		SELECT SUM(ISNULL(dollars_delta,0)) DDelt
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_id AND category = 'UB'
	)
	SELECT 
        *
    FROM 
        DS10_CC_log_detail
    WHERE 
        upload_ID = @upload_id
        AND category = 'UB'
        AND (SELECT UB FROM UBBgt) <> (SELECT DDelt FROM UBDelta)
)