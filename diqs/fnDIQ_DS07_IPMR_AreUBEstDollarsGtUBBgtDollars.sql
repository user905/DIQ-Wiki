/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>UB Estimated Greater Than UB Budgeted (Dollars)</title>
  <summary>Is the UB estimated dollar amount greater than UB budgeted?</summary>
  <message>UB_est_dollars &gt; UB_est_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070336</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_AreUBEstDollarsGtUBBgtDollars] (
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
		AND UB_est_dollars > ISNULL(UB_bgt_dollars,0)
)