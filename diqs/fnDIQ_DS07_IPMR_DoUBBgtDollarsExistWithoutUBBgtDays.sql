/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>UB Budget Dollars without UB Budget Days</title>
  <summary>Are there UB budget dollars but no UB budget dayss?</summary>
  <message>UB_bgt_dollars &lt;&gt; 0 &amp; UB_bgt_days = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070344</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_DoUBBgtDollarsExistWithoutUBBgtDays] (
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
		AND ISNULL(UB_bgt_days,0) = 0
		AND UB_bgt_dollars > 0
)