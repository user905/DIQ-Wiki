/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>MR Transaction Dollars Misaligned With Project Level MR</title>
  <summary>Are the dollars delta for MR-related transactions misaligned with the MR dollar value in the IPMR header?</summary>
  <message>Sum of dollars_delta where category = MR &lt;&gt; DS07.MR_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100457</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_AreMRDollarDeltasMisalignedWithDS07MR] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with MRBgt as (
		select ISNULL(MR_bgt_dollars,0) MR
		from DS07_IPMR_header
		where upload_ID = @upload_ID
	), CCLogDetail as (
		select dollars_delta, category
		from DS10_CC_log_detail
		where upload_ID = @upload_ID
	), MRDelta as (
		select SUM(dollars_delta) MR
		from CClogDetail
		where category = 'MR'
	)
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_ID
	AND category = 'MR'
	AND (SELECT MR FROM MRDelta) <> (SELECT MR FROM MRBgt)
	AND (SELECT COUNT(*) FROM CCLogDetail) > 0 -- run only if there are rows in DS10
)