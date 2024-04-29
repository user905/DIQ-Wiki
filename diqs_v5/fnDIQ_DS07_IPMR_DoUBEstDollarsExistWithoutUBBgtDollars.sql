/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>UB Estimated without UB Budget (Dollars)</title>
  <summary>Are there UB estimated dollars but no UB budget dollars?</summary>
  <message>UB_est_dollars &lt;&gt; 0 &amp; UB_bgt_dollars = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070348</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_DoUBEstDollarsExistWithoutUBBgtDollars] (
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
		AND UB_est_dollars <> 0
		AND ISNULL(UB_bgt_dollars,0) = 0
)